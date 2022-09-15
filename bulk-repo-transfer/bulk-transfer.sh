
#!/bin/bash

: '
BULK TRANSFER GITHUB REPOSTIORIES
=================================

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/
Copyright 2019 J.D. Bean
Modifications by 3n3a, 2022
'

show_help() {
  cat <<EOF
bulk-transfer - Bulk Transfers Github Repos [version 1.0]

Usage:    bulk-transfer.sh [OWNER] [NEW_OWNER] [--dry-run]
EOF
}


function git_repo_transfer(){ 
  # $1 => REPO
  # $2 => OWNER
  # $3 => NEW_OWNER
  # $4 => DRY_RUN_FLAG (--dry-run)
  if [[ -n $4 && $4 == "--dry-run" ]]; then
    cat <<EOF
,-------------------------------------------------------------.
| DRY RUN:                                                     \\
  ========

  HEADERS:
  * "Authorization: Bearer ${GITHUB_SECRET}"
  * "Accept: application/vnd.github+json"
  
  Method: POST

  URL: https://api.github.com/repos/$2/$1/transfer

  BODY: {"new_owner":"$3"}
\\_____________________________________________________________/
EOF
  else
    curl -vL \
      -H "Authorization: Bearer ${GITHUB_SECRET}" \
      -H "Accept: application/vnd.github+json" \
      -X POST https://api.github.com/repos/$2/$1/transfer \
      -d '{"new_owner":"'$3'"}' \
      | jq .
  fi
}


if [[ ($1 == "-h") || ($1 == "--help") || ($1 == "") ]]; then
  show_help

#                                   v--- execute normally when 'dry-run'
elif [[ -z "$GITHUB_SECRET" && -z "$3" ]]; then
  echo -e "Error: Please set GITHUB_SECRET Environment Variable\n\nExample: export GITHUB_SECRET=\"<your_token>\""
  exit 1

else
  repos=$( cat ./repos.txt) 
  for repo in $repos; do (git_repo_transfer "$repo" "$1" "$2" "$3"); done
fi