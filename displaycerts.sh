#!/bin/bash

# ********
# * INIT *
# ********

RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m'

#if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi
if [ ! -f "rootpath" ]; then
  echo "Run setup first"
  exit 1
fi
rootpath=`cat rootpath`
cd $rootpath


indexf=$(sed 's/\t\t/\t\-          \t/g' index.txt)
printf "${YELLOW}State\t\tExpiration Date\t\tRevocation Date\t\tSerial\t\tFilename\t\tDistinguished-Name${NC}\n"
while IFS=$'\t' read -r -a arr
do
  printf "${arr[0]}\t\t${arr[1]}\t\t${arr[2]}\t\t${arr[3]}\t\t${arr[4]}\t\t\t${arr[5]}\n"
done <<< "$indexf"


indexif=$(sed 's/\t\t/\t\-          \t/g' intermediate/index.txt)
printf "${YELLOW}State\t\tExpiration Date\t\tRevocation Date\t\tSerial\t\tFilename\t\tDistinguished-Name${NC}\n"
while IFS=$'\t' read -r -a arr
do
  printf "${arr[0]}\t\t${arr[1]}\t\t${arr[2]}\t\t${arr[3]}\t\t${arr[4]}\t\t\t${arr[5]}\n"
done <<< "$indexif"

printf "\n\nLegend: V=valid,R=revoked,E=expired\t\tDate Format: YYMMDDHHMMSSZ${NC}\n"
