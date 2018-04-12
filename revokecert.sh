#!/bin/bash

# ********
# * INIT *
# ********

RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m'

if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi
if [ ! -f "rootpath" ]; then
  echo "Run setup first"
  exit 1
fi
rootpath=`cat rootpath`
cd $rootpath

echo "Enter domain name of certificate you wish to revoke"
read cert

echo "Are you sure you wish to revoke the following certificate?"
openssl x509 -noout -serial -subject -issuer -email -dates -in intermediate/certs/$cert.cert.pem
if [ $? -ne 0 ]; then
    printf "${RED}openssl failed with code $? (could not load certificate)${NC}\n"
    exit 1
fi
printf "${YELLOW}y/n? >${NC}"
read CONT
echo ""
if [ "$CONT" = "y" ]; then
  openssl ca -config intermediate/openssl.cnf -revoke intermediate/certs/$cert.cert.pem
  if [ $? -ne 0 ]; then
      printf "${RED}openssl failed with code $?${NC}\n"
      exit 1
  fi
  printf "\n${GREEN}Certificate revoked${NC}\n"
else
  echo "Aborting . . "
fi


