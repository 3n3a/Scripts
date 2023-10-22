
#!/bin/bash

show_help() {
  cat <<EOF
bulk-transfer - Bulk Transfers Github Repos [version 1.0]

Usage:    bulk-transfer.sh [-f FILE] [-o OWNER] [-n NEW_OWNER] [-d Dry Run]
EOF
}


git_repo_transfer(){ 
  # $1 => REPO
  # $2 => OWNER
  # $3 => NEW_OWNER
    curl -vL \
      -H "Authorization: Bearer ${GITHUB_SECRET}" \
      -H "Accept: application/vnd.github+json" \
      -X POST https://api.github.com/repos/$2/$1/transfer \
      -d '{"new_owner":"'$3'"}' \
      | jq . 
}

owner=""
new_owner=""
is_dry="false"
file="./repos.txt"

while getopts "hdo:n:f::" option
do
    case $option in
	h|--help)
		show_help
		exit 0;;
	f|--file)
		# file
		file=$OPTARG;;
	o|--owner)
		# owner
		owner=$OPTARG;;
	n|--new-owner)
		# new owner
		new_owner=$OPTARG;;
	d|--dry-run)
		# is dry run
		is_dry="true";;
	\?)
		echo "Error: Invalid option!"
		show_help
		exit 1;;
	esac
done

if [ -z "$GITHUB_SECRET" ]; then
  echo -e "Error: Please set GITHUB_SECRET Environment Variable\n\nExample: export GITHUB_SECRET=\"<your_token>\""
  exit 1

else
  if [ "$is_dry" = "true" ]; then
	  echo "IS DRY RUN: Not executing anything";
	  echo "ALL THE OPTIONS:\n\tfile: $file\n\towner: $owner\n\tnew_owner: $new_owner\n\tis_dry: $is_dry\n"
	  exit 0;
  fi
  repos=$( cat "$file") 
  for repo in $repos; do (git_repo_transfer "$repo" "$owner" "$new_owner"); done
fi
