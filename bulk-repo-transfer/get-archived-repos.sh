#!/bin/sh
#
# GET ARCHIVED REPOS FROM GITHB
# by 3n3a
#
# [2022/09/15]: Init Script
#

# The GITHUB_SECRET Environment Variable needs to be set.

get_user_repos() {
  # $1: USERNAME
  # $2: TYPE // type of repos (all, archived, public...)
  # $3: OUTPUT_FILENAME
  get_repos "users" "$1" "$2" | tee "$3"
}

get_org_repos() {
  # $1: ORGNAME
  # $2: TYPE
  # $3: OUTPUT_FILENAME
  get_repos "orgs" "$1" "$2" | tee "$3"
}

get_repos() {
  # $1: ENDPOINT (users, orgs)
  # $2: NAME (username, orgname)
  # $3: TYPE (all, archived, public...)
  return curl -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $GITHUB_SECRET" https://api.github.com/$1/$2/repos\?per_page\=100\&type\=$3 | jq -r '.[].name'
}

show_help() {
  echo << EOF
get-archived-repos - Gets Archived Github Repos [version 1.0]

Usage:    get-archived-repos.sh [USERNAME] [OUTPUTFILE]
    get-archived-repos.sh [ORGNAME] [OUTPUTFILE] --org
  EOF;
}

if ($1 -eq "-h") {
  show_help()
}
