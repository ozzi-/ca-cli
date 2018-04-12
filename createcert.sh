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

echo ""
printf "${YELLOW}Enter domain name (i.e. webmail.internal.ch - www. will be added automatically)${NC}\n"
read domain
echo ""

printf "${YELLOW}Do you want to encrypt the key?${NC}\n"
printf "${YELLOW}If encryption is used, you will need to enter the password when starting your service (y/n)${NC}\n"
read CONT
echo ""

printf "${YELLOW}How many days shall this certificate be valid?${NC}\n"
read days
echo ""

printf "${YELLOW}Do you wish to add the 'authorityInfoAccess' OCSP attribute?(y/n)${NC}\n"
read ocsp
echo ""
if [ "$ocsp" = "y" ]; then
  printf "${YELLOW}Please enter the OCSP url? (i.e. http://ocsp.company.ch)${NC}\n"
  read ocspurl
fi


# ***********
# * KEY GEN *
# ***********

if [ "$CONT" = "y" ]; then
  echo "Using -aes256 flag -> encrypted key"
  openssl genrsa -aes256 -out intermediate/private/$domain.key.pem 4096
else
  openssl genrsa -out intermediate/private/$domain.key.pem 4096
fi
if [ $? -ne 0 ]; then
    printf "${RED}openssl failed with code $?${NC}\n"
    exit 1
fi
chmod 400 intermediate/private/$domain.key.pem

# ***************
# * openssl cnf *
# ***************

cp intermediate/openssl.cnf intermediate/openssl.tmp.cnf
if [ "$ocsp" = "y" ]; then
  sed -i -e "s/\[ server_cert \].*/\[ server_cert \]\nauthorityInfoAccess = OCSP;URI:$ocspurl/g" intermediate/openssl.tmp.cnf
fi
sed -i -e "s/commonName_default.*/commonName_default = $domain/g" intermediate/openssl.tmp.cnf

# ***********
# * CSR GEN *
# ***********

openssl req -config <(cd $rootpath; cat intermediate/openssl.tmp.cnf <(printf "\n[SAN]\nsubjectAltName=DNS:www.$domain,DNS:$domain")) \
  -key intermediate/private/$domain.key.pem -reqexts SAN -new -sha256 -out intermediate/csr/$domain.csr.pem
if [ $? -ne 0 ]; then
    printf "${RED}openssl failed with code $?${NC}\n"
    exit 1
fi
echo ""
printf "${YELLOW}Created CSR${NC}\n"
echo ""

# ************
# * CERT GEN *
# ************

openssl ca -config <(cd $rootpath; cat intermediate/openssl.tmp.cnf <(printf "\n[alt_names]\nDNS.1 = www.$domain\nDNS.2=$domain")) \
  -extensions server_cert -days $days -notext -md sha256 -in intermediate/csr/$domain.csr.pem -out intermediate/certs/$domain.cert.pem
if [ $? -ne 0 ]; then
    printf "${RED}openssl failed with code $?${NC}\n"
    exit 1
fi
chmod 444 intermediate/certs/$domain.cert.pem


# ********************
# * CLEANUP,CHK, BYE *
# ********************

rm -rf intermediate/openssl.tmp.cnf

echo ""
printf "${YELLOW}Created Cert${NC}\n"
echo ""
echo "Testing?"
openssl verify -CAfile intermediate/certs/ca-chain.cert.pem intermediate/certs/$domain.cert.pem
if [ $? -eq "0" ]; then
   printf "\n${GREEN}Success${NC}\n\n"
   exit 0
else
   printf "\n${RED}Something went wrong, the certificate cannot be validated against the ca-chain${NC}\n\n"
   exit 1
fi
