#!/bin/bash
#
# Converts JSON File with all field-names to a csv
# by 3n3a
#
# 1: In File
# 2: out File

jq -r '(map(keys) | add | unique) as $headers | $headers, map([.[]])[] | @csv' $1 > $2
