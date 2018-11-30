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


# ************
# * GET CERT *
# ************

echo ""
printf "${YELLOW}Enter domain name of the certificate${NC}\n"
read domain
echo ""
printf "${YELLOW}Do you want to output the certificate as PEM or PKCS12?${NC}\n"
read format
echo ""  
if [ "$format" == "PEM" ] || [ "$format" == "pem" ]; then
  cat intermediate/certs/$domain.cert.pem
  cat intermediate/private/$domain.key.pem
elif [ "$format" == "pkcs12" ] || [ "$format" == "PKCS12" ] || [ "$format" == "pkcs" ]; then
  openssl pkcs12 -export -in intermediate/certs/$domain.cert.pem -inkey intermediate/private/$domain.key.pem
else
  echo "Type pkcs12 or pem."
fi
