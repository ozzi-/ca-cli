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


# *************
# * VARIABLES *
# *************

if [ $# -eq 0 ]; then
  echo ""
  printf "${RED}Please provide file path to CSR as command line argument${NC}\n"
  exit 2
else
 csrpath=$1
  if [ ! -f "$csrpath" ]; then
    printf "${RED}Could not find CSR${NC}\n"
    exit 3
  fi
fi

printf "${YELLOW}How many days shall this certificate be valid?${NC}\n"
read days
echo ""

name=$(openssl req -in $csrpath -subject -noout | grep -Po 'CN.*' | cut -c 4- | cut -f1 -d"/")
name=$(echo $name | sed -e 's/[^A-Za-z0-9._-]/_/g')
printf "${YELLOW}CSR CN that will be used as filename "$name"${NC}\n"
echo ""

# ************
# * CERT GEN *
# ************
openssl ca -config <(cd $rootpath; cat intermediate/openssl.cnf) -policy signing_policy -extensions signing_req -notext -md sha256 -days $days -out intermediate/certs/$name.cert.pem -infiles $csrpath
if [ $? -ne 0 ]; then
    printf "${RED}openssl failed with code $?${NC}\n"
    exit 1
fi
chmod 444 intermediate/certs/$name.cert.pem


# ********************
# * CLEANUP,CHK, BYE *
# ********************

echo ""
printf "${YELLOW}Signed CSR${NC}\n"
echo ""
echo "Testing?"
openssl verify -CAfile intermediate/certs/ca-chain.cert.pem intermediate/certs/$name.cert.pem
if [ $? -eq "0" ]; then
   printf "\n${GREEN}Success${NC}\n\n"
   exit 0
else
   printf "\n${RED}Something went wrong, the certificate cannot be validated against the ca-chain${NC}\n\n"
   exit 1
fi
