# Bulk Transfer of Github Repos

## Guide

1. Get an Access Token from Github
2. Set `GITHUB_SECRET` to access token
3. Install bash, jq, and curl
4. Download archived repos with `get-archived-repos.sh`, into `repos.txt`
5. Run the `bulk-transfer.sh` Script to transfer you repos

## Run the Commands

### Download your Archived Repos

**For User**

```bash
bash get-archived-repos.sh <USERNAME> repos.txt
```

**For Organization**

```bash
bash get-archived-repos.sh <ORGANIZATION> repos.txt --org
```

### Transfer Repos

```bash
bash transfer-bulk.sh <OWNER> <NEW_OWNER>
```

**Dry Run**

```bash
bash transfer-bulk.sh <OWNER> <NEW_OWNER> --dry-run
```
