#!/usr/bin/env python3
"""
Subdomain DNS Batch Query Tool
Finds subdomains by combining user queries with environment keywords

Dependency: pip install dnspython
"""

import dns.resolver
import concurrent.futures
from typing import List, Set, Tuple
import sys
import argparse
from datetime import datetime
import json

# Configuration
SEPARATORS = ["", "-"]
KEYWORDS = [
    "", "prd", "prod", "test", "uat", "tst", "int", "intg",
    "dev", "lab", "snbx", "sbx", "sandbox", "entw",
    "production", "integration", "development"
]

# DNS record types to query
RECORD_TYPES = ["A", "AAAA", "CNAME"]


def generate_subdomains(queries: List[str], domain: str) -> Set[str]:
    """
    Generate all possible subdomain combinations.
    
    Args:
        queries: List of base query strings (e.g., ['api', 'www', 'mail'])
        domain: Main domain (e.g., 'example.com')
    
    Returns:
        Set of generated subdomains
    """
    return generate_subdomains_custom(queries, domain, SEPARATORS, KEYWORDS)


def generate_subdomains_custom(queries: List[str], domain: str, 
                               separators: List[str], keywords: List[str]) -> Set[str]:
    """
    Generate all possible subdomain combinations with custom separators and keywords.
    
    Args:
        queries: List of base query strings
        domain: Main domain
        separators: List of separators to use
        keywords: List of keywords to append
    
    Returns:
        Set of generated subdomains
    """
    subdomains = set()
    
    for query in queries:
        for sep in separators:
            for keyword in keywords:
                if keyword:  # keyword exists
                    subdomain = f"{query}{sep}{keyword}.{domain}"
                else:  # empty keyword
                    subdomain = f"{query}.{domain}"
                subdomains.add(subdomain)
    
    return subdomains


def query_dns(subdomain: str) -> Tuple[str, List[dict]]:
    """
    Query DNS records for a subdomain.
    
    Args:
        subdomain: The subdomain to query
    
    Returns:
        Tuple of (subdomain, list of records found)
    """
    results = []
    
    for record_type in RECORD_TYPES:
        try:
            answers = dns.resolver.resolve(subdomain, record_type, lifetime=2)
            for rdata in answers:
                results.append({
                    "subdomain": subdomain,
                    "type": record_type,
                    "value": str(rdata)
                })
        except (dns.resolver.NXDOMAIN, dns.resolver.NoAnswer, 
                dns.resolver.NoNameservers, dns.exception.Timeout):
            # Domain doesn't exist or no records of this type
            pass
        except Exception as e:
            # Handle other errors silently
            pass
    
    return (subdomain, results)


def batch_query_subdomains(subdomains: Set[str], max_workers: int = 50, 
                          verbose: bool = False) -> List[dict]:
    """
    Query multiple subdomains concurrently.
    
    Args:
        subdomains: Set of subdomains to query
        max_workers: Maximum number of concurrent workers
        verbose: Show all attempts if True
    
    Returns:
        List of found DNS records
    """
    all_results = []
    total = len(subdomains)
    completed = 0
    
    print(f"Querying {total} subdomains...\n")
    
    with concurrent.futures.ThreadPoolExecutor(max_workers=max_workers) as executor:
        future_to_subdomain = {
            executor.submit(query_dns, subdomain): subdomain 
            for subdomain in subdomains
        }
        
        for future in concurrent.futures.as_completed(future_to_subdomain):
            completed += 1
            subdomain, results = future.result()
            
            if results:
                all_results.extend(results)
                print(f"[{completed}/{total}] ✓ Found: {subdomain}")
            elif verbose:
                print(f"[{completed}/{total}] ✗ Not found: {subdomain}")
            else:
                # Show progress for not found
                if completed % 10 == 0:
                    print(f"[{completed}/{total}] Scanning...")
    
    return all_results

def output_results(domain: str, queries: List[str], results: List[dict]):
    """Output results to file in json format"""
    if not results:
        return

    file_name = "results-" + domain + "-" + "-".join(queries) + "-" + datetime.today('%Y-%m-%d-%H-%M-%S') + ".json"
    with open(file_name, 'w') as fp:
        json.dump(results, fp)

    print(f"Saved results to file: {file_name}")
    return


def print_results(results: List[dict]):
    """Print results in a formatted way."""
    if not results:
        print("\n❌ No subdomains found.")
        return
    
    print(f"\n{'='*70}")
    print(f"✓ Found {len(results)} DNS record(s) across {len(set(r['subdomain'] for r in results))} subdomain(s)")
    print(f"{'='*70}\n")
    
    # Group by subdomain
    by_subdomain = {}
    for record in results:
        subdomain = record['subdomain']
        if subdomain not in by_subdomain:
            by_subdomain[subdomain] = []
        by_subdomain[subdomain].append(record)
    
    # Print grouped results
    for subdomain, records in sorted(by_subdomain.items()):
        print(f"📍 {subdomain}")
        for record in records:
            print(f"   {record['type']:6} → {record['value']}")
        print()


def main():
    """Main function."""
    parser = argparse.ArgumentParser(
        description="Batch DNS subdomain finder",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s -d example.com -q api www admin
  %(prog)s -d example.com -q api www -w 100
  %(prog)s -d example.com -q api -s "" "-" "." -k prod dev test
  %(prog)s -d example.com -f queries.txt
  %(prog)s -d example.com -q api --no-keywords
        """
    )
    
    parser.add_argument(
        "-d", "--domain",
        required=True,
        help="Main domain to scan (e.g., example.com)"
    )
    
    parser.add_argument(
        "-q", "--queries",
        nargs="+",
        help="Base query strings (e.g., api www admin)"
    )
    
    parser.add_argument(
        "-f", "--file",
        help="File containing queries (one per line)"
    )
    
    parser.add_argument(
        "-s", "--separators",
        nargs="+",
        default=None,
        help='Separators to use (default: "" and "-"). Use quotes for empty string'
    )
    
    parser.add_argument(
        "-k", "--keywords",
        nargs="+",
        default=None,
        help="Keywords to append (default: built-in list)"
    )
    
    parser.add_argument(
        "--no-keywords",
        action="store_true",
        help="Don't append any keywords (only use base queries)"
    )
    
    parser.add_argument(
        "-w", "--workers",
        type=int,
        default=50,
        help="Number of concurrent workers (default: 50)"
    )
    
    parser.add_argument(
        "-t", "--types",
        nargs="+",
        default=["A", "AAAA", "CNAME"],
        help="DNS record types to query (default: A AAAA CNAME)"
    )
    
    parser.add_argument(
        "-v", "--verbose",
        action="store_true",
        help="Show all attempts, not just found subdomains"
    )

    parser.add_argument(
        "-o", "--output",
        action="store_true",
        help="Output results to file in JSON format"
    )
    
    args = parser.parse_args()
    
    # Validate inputs
    if not args.queries and not args.file:
        parser.error("Must provide either -q/--queries or -f/--file")
    
    # Load queries
    queries = []
    if args.queries:
        queries.extend(args.queries)
    if args.file:
        try:
            with open(args.file, 'r') as f:
                queries.extend([line.strip() for line in f if line.strip()])
        except FileNotFoundError:
            print(f"❌ Error: File '{args.file}' not found")
            sys.exit(1)
    
    if not queries:
        print("❌ Error: No queries provided")
        sys.exit(1)
    
    # Configure separators
    separators = SEPARATORS if args.separators is None else args.separators
    
    # Configure keywords
    if args.no_keywords:
        keywords = [""]
    elif args.keywords is not None:
        keywords = args.keywords
    else:
        keywords = KEYWORDS
    
    # Update global record types
    global RECORD_TYPES
    RECORD_TYPES = [rt.upper() for rt in args.types]
    
    # Display configuration
    print(f"Domain: {args.domain}")
    print(f"Base queries: {len(queries)} ({', '.join(queries[:5])}{'...' if len(queries) > 5 else ''})")
    print(f"Separators: {', '.join(repr(s) if s else '(empty)' for s in separators)}")
    print(f"Keywords: {', '.join(k if k else '(empty)' for k in keywords[:8])}{'...' if len(keywords) > 8 else ''}")
    print(f"Record types: {', '.join(RECORD_TYPES)}")
    print(f"Workers: {args.workers}")
    print()
    
    # Generate all possible subdomains
    subdomains = generate_subdomains_custom(queries, args.domain, separators, keywords)
    
    # Batch query DNS
    results = batch_query_subdomains(subdomains, max_workers=args.workers, verbose=args.verbose)
    
    if args.output:
        output_results(args.domain, queries, results)

    # Print results
    print_results(results)


if __name__ == "__main__":
    # Install required package: pip install dnspython
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n⚠️  Interrupted by user")
        sys.exit(1)
