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

if [ $# -eq 0 ]; then
  echo ""
  printf "${YELLOW}Enter domain name of the certificate${NC}\n"
  read domain
  echo ""
else
  domain=$1
fi

cat intermediate/certs/$domain.cert.pem
cat intermediate/private/$domain.key.pem
