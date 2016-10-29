#!/bin/bash

# return true (0) is certificate expired
# else return false (1). also return false if arguments are missing

if [ -z "$1" -o -z "$2" ]; then
  exit 1
fi

CERT=$1
MINDAYS=$2

CERTDATE=$(date --date "`openssl x509 -noout -enddate -in \"$CERT\" | cut -d= -f 2`" +%s)
NOW=$(date +%s)

let DAYS="($CERTDATE-$NOW)/86400 - $MINDAYS"

if [ $DAYS -le 0 ]; then
  exit 0
fi
  
exit 1

