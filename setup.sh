#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi
if ! [ -x "$(command -v openssl)" ]; then
  echo 'Error: openssl is not installed.' >&2
  exit 1
fi

echo "###################################"
echo "This script will set up your own CA"
echo "###################################"
echo ""

echo "What folder shall be used for the ca files? (E.g. /root/ca)"
read rootpath
if [ -d "$rootpath" ]; then
  echo "Directory already exists"
  exit 1
fi
mkdir -p $rootpath
echo $rootpath > rootpath

echo "What is your country name (2 letter code, i.e. CH)?"
read countryname
#if [ ${#countryname} -ne 2 ]; then echo "invalid input" ; exit

echo "What is your State or Province Name?"
read state

echo "What is your Organization Name? (i.e. Company)"
read orgname

echo "What is your Organizational Unit Name? (i.e. Company Certificate Authority)"
read unitname

if [ $? -ne 0 ] ; then
  echo "Could not create directory"
  exit 1
fi
echo ""
echo "#########################"
echo "Creating folder structure"
echo "#########################"
echo ""
cp openssl.cnf $rootpath/openssl.cnf
cp openssl_root.cnf $rootpath/openssl_root.cnf
cd $rootpath

mkdir certs crl newcerts private intermediate
chmod 700 private
touch index.txt
echo 1000 > serial

mv openssl.cnf intermediate/
cd intermediate
mkdir certs crl csr newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial
echo 1000 > crlnumber

cd ..
cleanpath="$(echo "$rootpath" | sed 's/\//\\\//g')"
sed -i -e "s/%PATH%/$cleanpath/g" openssl_root.cnf
sed -i -e "s/%COUNTRYNAME%/$countryname/g" openssl_root.cnf
sed -i -e "s/%STATE%/$state/g" openssl_root.cnf
sed -i -e "s/%ORGNAME%/$orgname/g" openssl_root.cnf
sed -i -e "s/%UNITNAME%/$unitname/g" openssl_root.cnf

cd intermediate
cleanpath="$(echo "$rootpath/intermediate" | sed 's/\//\\\//g')"
sed -i -e "s/%PATH%/$cleanpath/g" openssl.cnf
sed -i -e "s/%COUNTRYNAME%/$countryname/g" openssl.cnf
sed -i -e "s/%STATE%/$state/g" openssl.cnf
sed -i -e "s/%ORGNAME%/$orgname/g" openssl.cnf
sed -i -e "s/%UNITNAME%/$unitname/g" openssl.cnf
echo ""
echo "* Done"
echo ""

cd ..
echo "###################"
echo "Generating root key"
echo "###################"
echo ""
echo "Please choose a strong password and save it in a secure manner"
openssl genrsa -aes256 -out private/ca.key.pem 4096
if [ $? -ne 0 ]; then
    printf "${RED}openssl failed with code $?${NC}\n"
    exit 1
fi
chmod 400 private/ca.key.pem
echo ""
echo "* Done"
echo ""

echo "###########################"
echo "Generating root certificate"
echo "###########################"
echo ""
echo "How many days shall your root certificate be valid for? (This should be reasonable, 10 years (3650 days) +)"
read days
openssl req -config openssl_root.cnf \
      -key private/ca.key.pem \
      -new -x509 -days $days -sha256 -extensions v3_ca \
      -out certs/ca.cert.pem
if [ $? -ne 0 ]; then
    printf "${RED}openssl failed with code $?${NC}\n"
    exit 1
fi
chmod 444 certs/ca.cert.pem
echo ""
echo "Root certificate:"
openssl x509 -noout -serial -subject -issuer -email -dates -in certs/ca.cert.pem
echo ""
echo "* Done"
echo ""
echo "###########################"
echo "Generating intermediate key"
echo "###########################"
echo ""
echo "Please choose another strong password and save it in a secure manner"
openssl genrsa -aes256 \
      -out intermediate/private/intermediate.key.pem 4096
if [ $? -ne 0 ]; then
    printf "${RED}openssl failed with code $?${NC}\n"
    exit 1
fi
chmod 400 intermediate/private/intermediate.key.pem
echo ""
echo "* Done"
echo ""
echo "###################################"
echo "Generating intermediate certificate"
echo "###################################"
echo ""
openssl req -config intermediate/openssl.cnf -new -sha256 -key intermediate/private/intermediate.key.pem -out intermediate/csr/intermediate.csr.pem
if [ $? -ne 0 ]; then
    printf "${RED}openssl failed with code $?${NC}\n"
    exit 1
fi

echo "How many days shall your intermediate certificate be valid for? (This should be reasonable, 5 years (1825 days) +)"
read days
openssl ca -config openssl_root.cnf -extensions v3_intermediate_ca -days 3650 -notext -md sha256 -in intermediate/csr/intermediate.csr.pem -out intermediate/certs/intermediate.cert.pem
if [ $? -ne 0 ]; then
    printf "${RED}openssl failed with code $?${NC}\n"
    exit 1
fi

chmod 444 intermediate/certs/intermediate.cert.pem
echo ""
echo "Intermediate certificate:"
openssl x509 -noout -serial -subject -issuer -email -dates -in intermediate/certs/intermediate.cert.pem

echo ""
echo "Creating ca-chain.cert.pem"
cat certs/ca.cert.pem intermediate/certs/intermediate.cert.pem > intermediate/certs/ca-chain.cert.pem

echo ""
echo "* Done"
echo ""
echo "###############"
printf "${GREEN}Setup completed${NC}\n"
echo "###############"
echo ""
