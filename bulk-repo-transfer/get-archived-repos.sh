#!/bin/bash
#
# GET ARCHIVED REPOS FROM GITHB
# by 3n3a
#
# [2022/09/15]: Init Script
#

# REQUIREMMENTS
# The GITHUB_SECRET Environment Variable needs to be set.
#
# >> Outputs Data for Bulk-Transfer.sh
#

get_user_repos() {
  # $1: USERNAME
  # $2: TYPE // type of repos (all, public...)
  # $3: OUTPUT_FILENAME
  get_repos "users" "$1" "$2" "$3"
}

get_org_repos() {
  # $1: ORGNAME
  # $2: TYPE
  # $3: OUTPUT_FILENAME
  get_repos "orgs" "$1" "$2" "$3"
}

get_repos() {
  # $1: ENDPOINT (users, orgs)
  # $2: NAME (username, orgname)
  # $3: TYPE (all, public...)
  # $4: OUTPUT_FILENAME
  url="https://api.github.com/$1/$2/repos?per_page=100&type=$3"
  curl -s -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $GITHUB_SECRET" "$url" -o- \
     | jq -r ".[] | if (.archived == true) and (.full_name | startswith(\"$2/\")) then(.name) else \"\" end" \
     | sed '/^$/d' /dev/stdin \
     | cp /dev/stdin "$4"
}

show_help() {
  cat <<EOF
get-archived-repos - Gets Archived Github Repos [version 1.0]

Usage:    get-archived-repos.sh [USERNAME] [OUTPUTFILE]
          get-archived-repos.sh [ORGNAME] [OUTPUTFILE] --org
EOF
}

# DEBUG
# echo -e "PARAMETERS\nONE: [$1]; TWO: [$2]; THREE: [$3]\n"

name=$1
filename=$2

if [[ ($1 == "-h") || ($1 == "--help") || ($1 == "") ]]; then
  show_help

elif [[ -z "$GITHUB_SECRET" ]]; then
  echo -e "Error: Please set GITHUB_SECRET Environment Variable\n\nExample: export GITHUB_SECRET=\"<your_token>\""
  exit 1

elif [[ -n $1 && -n $2 && ($3 == "--org") ]]; then
  echo "Getting Repos of organization $name, saving to $filename."
  get_org_repos "$name" "all" "$filename"

elif [[ -n $1 && -n $2 ]]; then
  echo "Getting Repos of user $name, saving to $filename."
  get_user_repos "$name" "all" "$filename"

fi