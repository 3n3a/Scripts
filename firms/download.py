import json
import os
import requests

# Constants
BASE_URL = "https://www.zefix.ch/ZefixREST/api/v1/firm/search.json"
HEADERS = {
    "Host": "www.zefix.ch",
    "Accept": "application/json",
    "Sec-Fetch-Site": "cross-site",
    "Accept-Encoding": "gzip, deflate, br",
    "Zefix-App-Version": "2.1.4",
    "Sec-Fetch-Mode": "cors",
    "Accept-Language": "en-GB,en;q=0.9",
    "Origin": "ionic://localhost",
    "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 18_1_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148",
    "Content-Type": "application/json",
    "Connection": "keep-alive",
}
OUTPUT_DIR = "firms"
COMBINED_OUTPUT_FILE = "firm.list.json"

# Ensure output directory exists
os.makedirs(OUTPUT_DIR, exist_ok=True)

def download_firms():
    offset = 0
    iteration = 1
    combined_results = []

    while True:
        # Prepare the body for the POST request
        payload = {
            "offset": offset,
            "maxEntries": 1000,
            "searchType": "exact",
            "registryOffices": [
                400, 310, 300, 36, 280, 270, 217, 660, 160, 350, 670, 100,
                645, 150, 140, 320, 290, 241, 130, 440, 501, 120, 550, 626,
                621, 600, 170, 20
            ],
            "deletedFirms": False,
            "formerNames": False,
        }

        # Make the POST request
        response = requests.post(BASE_URL, headers=HEADERS, json=payload)
        response.raise_for_status()  # Raise exception for HTTP errors

        data = response.json()
        
        # Save current response to a JSON file
        output_file = os.path.join(OUTPUT_DIR, f"firm.{iteration}.json")
        with open(output_file, "w", encoding="utf-8") as file:
            json.dump(data, file, ensure_ascii=False, indent=2)
        
        # Collect "list" values for final combined JSON
        combined_results.extend(data.get("list", []))
        
        # Check if there are more results
        if not data.get("hasMoreResults", False):
            break
        
        # Update offset for the next iteration
        offset = data.get("maxOffset", 0)
        iteration += 1

    # Save combined results to a final JSON file
    with open(COMBINED_OUTPUT_FILE, "w", encoding="utf-8") as file:
        json.dump(combined_results, file, ensure_ascii=False, indent=2)

    print(f"Download complete. Combined file saved as '{COMBINED_OUTPUT_FILE}'.")

if __name__ == "__main__":
    download_firms()