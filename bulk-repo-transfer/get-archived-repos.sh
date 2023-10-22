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
  url="https://api.github.com/user/repos?per_page=100&type=$2"
  curl -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" -H "Authorization: Bearer $GITHUB_SECRET" "$url" -o /tmp/get-repos.json

  cat /tmp/get-repos.json \
     | jq -r ".[] | if (.archived == true) and (.full_name | startswith(\"$1/\")) then(.name) else \"\" end" \
     | sed '/^$/d' /dev/stdin \
     | cp /dev/stdin "$3"
}

get_org_repos() {
  # $1: ORGNAME
  # $2: TYPE
  # $3: OUTPUT_FILENAME
  url="https://api.github.com/orgs/$1/repos?per_page=100&type=$2"
  curl -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $GITHUB_SECRET" "$url" -o /tmp/get-repos.json

  cat /tmp/get-repos.json \
     | jq -r ".[] | if (.archived == true) and (.full_name | startswith(\"$1/\")) then(.name) else \"\" end" \
     | sed '/^$/d' /dev/stdin \
     | cp /dev/stdin "$3"
}

cleanup() {
  rm -rf /tmp/get-repos.json
}

show_help() {
  cat <<EOF
get-archived-repos - Gets Archived Github Repos [version 2.0]

Usage:    get-archived-repos.sh [-n USERNAME] [-f OUTPUTFILE]
          get-archived-repos.sh [-n ORGNAME] [-f OUTPUTFILE] --org

Other options:
          -h     This help
	  -c     No cleanup
EOF
}

# DEBUG
# echo -e "PARAMETERS\nONE: [$1]; TWO: [$2]; THREE: [$3]\n"

name=""
filename=""
org_mode="false"
no_clean="false"

while getopts "hcn:f:o::" option
do
    case $option in
        h|--help)
                show_help
                exit 0;;
	n|--name)
		name=$OPTARG;;
	f|--file)
		filename=$OPTARG;;
	o|--org)
		org_mode="true";;
	c|--no-clean)
		no_clean="true";;
	*)
		show_help
		exit 0;;
    esac
done

if [[ -z "$GITHUB_SECRET" ]]; then
  echo -e "Error: Please set GITHUB_SECRET Environment Variable\n\nExample: export GITHUB_SECRET=\"<your_token>\"\n\nGet your Token here: https://github.com/settings/tokens"
  exit 1

elif [[ -n $name && -n $filename && ($org_mode == "true") ]]; then
  echo "Getting Repos of organization $name, saving to $filename."
  get_org_repos "$name" "all" "$filename"

elif [[ -n $name && -n $filename ]]; then
  echo "Getting Repos of user $name, saving to $filename."
  get_user_repos "$name" "all" "$filename"

fi

if [[ "$no_clean" = "false" ]]; then
	echo "Cleanup"
	cleanup
	exit 0
fi
