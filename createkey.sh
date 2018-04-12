#!/bin/bash
if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi
if [ ! -f "rootpath" ]; then
  echo "Run setup first"
  exit 1
fi
echo "Enter domain name (i.e. webmail.internal.ch - www. will be added automatically)"
read name
echo ""
rootpath=`cat rootpath`
cd $rootpath
echo "Do you want to encrypt the key?"
echo "If encryption is used, you will need to enter the password when starting your service (y/n)"
read CONT
if [ "$CONT" = "y" ]; then
  echo "Using -aes256 flag -> encrypted key"
  openssl genrsa -aes256 -out intermediate/private/$name.key.pem 4096
else
  openssl genrsa -out intermediate/private/$name.key.pem 4096
fi
chmod 400 intermediate/private/$name.key.pem
echo ""
echo "* Done"
echo ""
