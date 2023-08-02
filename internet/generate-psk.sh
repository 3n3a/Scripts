#!/bin/sh
#
# Generates a Pre Shared Key
#   - needs openssl
#   - can be passed a different length param
#

len_input=$1
length="${len_input:-24}"

openssl rand -base64 $length
