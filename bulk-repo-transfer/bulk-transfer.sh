
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

# $1 => REPO
# $2 => OWNER
# $3 => NEW_OWNER

function git_repo_transfer(){ 
  curl -vL \
    -H "Authorization: Bearer ${GITHUB_SECRET}" \
    -H "Accept: application/vnd.github+json" \
    -X POST https://api.github.com/repos/$2/$1/transfer \
    -d '{"new_owner":"'$3'"}' \
    | jq .
}

repos=$( cat ./repos.txt) 
for repo in $repos; do (git_repo_transfer "$repo" "$1" "$2"); done
