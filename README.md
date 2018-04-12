# ca-cli
ca-cli is collection of bash scripts helping you to manage your own CA

# Usage
## Setup
First you need to run setup.sh, this script will guide you through the initial setup.

```
sudo ./setup.sh 
###################################
This script will set up your own CA
###################################

What folder shall be used for the ca files? (E.g. /root/ca)
/home/ozzi/myca
What is your country name (2 letter code, i.e. CH)?
ch
What is your State or Province Name?
zuerich
What is your Organization Name? (i.e. Company)
Example Corp
What is your Organizational Unit Name? (i.e. Company Certificate Authority)
Example Corp - CA

#########################
Creating folder structure
#########################

* Done

###################
Generating root key
###################

Please choose a strong password and save it in a secure manner
Generating RSA private key, 4096 bit long modulus
...
Enter pass phrase for private/ca.key.pem:
Verifying - Enter pass phrase for private/ca.key.pem:

* Done

###########################
Generating root certificate
###########################

How many days shall your root certificate be valid for? (This should be reasonable, 10 years (3650 days) +)
3650

Enter pass phrase for private/ca.key.pem:
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [ch]: 
State or Province Name [zuerich]:
Locality Name []:
Organization Name [Example Corp]:
Organizational Unit Name [Example Corp - CA]:
Common Name []:
Email Address []:

Root certificate:
serial=BF65C04B253E3620
subject= /C=ch/ST=zuerich/O=Example Corp/OU=Example Corp - CA
issuer= /C=ch/ST=zuerich/O=Example Corp/OU=Example Corp - CA
notBefore=Apr 12 11:39:05 2018 GMT
notAfter=Apr  9 11:39:05 2028 GMT

* Done

###########################
Generating intermediate key
###########################

Please choose another strong password and save it in a secure manner
Generating RSA private key, 4096 bit long modulus
...
Enter pass phrase for intermediate/private/intermediate.key.pem:
Verifying - Enter pass phrase for intermediate/private/intermediate.key.pem:

* Done

###################################
Generating intermediate certificate
###################################

Enter pass phrase for intermediate/private/intermediate.key.pem:
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [ch]:
State or Province Name [zuerich]:
Locality Name []:
Organization Name [Example Corp]:
Organizational Unit Name [Example Corp - CA]:
Common Name []:intermediate ca
Email Address []:
How many days shall your intermediate certificate be valid for? (This should be reasonable, 5 years (1825 days) +)
1825
Using configuration from openssl_root.cnf
Enter pass phrase for /home/ozzi/myca/private/ca.key.pem:
Check that the request matches the signature
Signature ok
Certificate Details:
        ...
            countryName               = ch
            stateOrProvinceName       = zuerich
            organizationName          = Example Corp
            organizationalUnitName    = Example Corp - CA
            commonName                = intermediate ca
      ...
Certificate is to be certified until Apr  9 11:39:20 2028 GMT (3650 days)
Sign the certificate? [y/n]:y

1 out of 1 certificate requests certified, commit? [y/n] y
Write out database with 1 new entries
Data Base Updated

Intermediate certificate:
serial=1000
subject= /C=ch/ST=zuerich/O=Example Corp/OU=Example Corp - CA/CN=intermediate ca
issuer= /C=ch/ST=zuerich/O=Example Corp/OU=Example Corp - CA
notBefore=Apr 12 11:39:20 2018 GMT
notAfter=Apr  9 11:39:20 2028 GMT

Creating ca-chain.cert.pem

* Done

###############
Setup completed
###############
```

## Creating a certificate

```
 sudo ./createcert.sh 

Enter domain name (i.e. webmail.internal.ch - www. will be added automatically)
test.com

Do you want to encrypt the key?
If encryption is used, you will need to enter the password when starting your service (y/n)
n

How many days shall this certificate be valid?
730

Do you wish to add the 'authorityInfoAccess' OCSP attribute?(y/n)
n

Generating RSA private key, 4096 bit long modulus
...
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [ch]:
State or Province Name [zuerich]:
Locality Name []:
Organization Name [Example Corp]:
Organizational Unit Name [Example Corp - CA]:
Common Name [test.com]:
Email Address []:

Created CSR

Using configuration from /dev/fd/63
Enter pass phrase for /home/ozzi/myca/intermediate/private/intermediate.key.pem:
Check that the request matches the signature
Signature ok
Certificate Details:
        ...
        Subject:
            countryName               = ch
            stateOrProvinceName       = zuerich
            organizationName          = Example Corp
            organizationalUnitName    = Example Corp - CA
            commonName                = test.com
         ...
Certificate is to be certified until Apr 11 11:46:21 2020 GMT (730 days)
Sign the certificate? [y/n]:y


1 out of 1 certificate requests certified, commit? [y/n]y
Write out database with 1 new entries
Data Base Updated

Created Cert

Testing?
intermediate/certs/test.com.cert.pem: OK

Success
```

## Display Certificates

```
$ sudo ./displaycerts.sh 
State		Expiration Date		Revocation Date		Serial		Filename		Distinguished-Name
V		280409113920Z		-          		1000		unknown			/C=ch/ST=zuerich/O=Example Corp/OU=Example Corp - CA/CN=intermediate ca
State		Expiration Date		Revocation Date		Serial		Filename		Distinguished-Name
V		200411114621Z		-          		1000		unknown			/C=ch/ST=zuerich/O=Example Corp/OU=Example Corp - CA/CN=test.com


Legend: V=valid,R=revoked,E=expired		Date Format: YYMMDDHHMMSSZ
```

## Get Certificate

```
$ sudo ./getcert.sh 

Enter domain name of the certificate
test.com

-----BEGIN CERTIFICATE-----
MIIGZzCCBE+gAwIBAgICEAAwDQYJKoZIhvcNAQELBQAwbDELMAkGA1UEBhMCY2gx
...
FZlS0aEuUGxc6k8=
-----END CERTIFICATE-----
-----BEGIN RSA PRIVATE KEY-----
MIIJKgIBAAKCAgEA28sw8h2AbwEgfTuAGnWywAzGHE1HEX9gXOHLln9LkzeTrn4v
e5Qc25xn/pV4cVmq+JSNfcMppjJQg8SLE3Ghp8SqQXLdWzmCmND8tMUXygtomL03
...
8obpqXs/NjSVhk5jjKg/Dq7uCdy+BS9idpqFmM5yiQgX3JyzePZQmjnefVGAdQ==
-----END RSA PRIVATE KEY-----

```

## Revoke Certificate

```
sudo ./revokecert.sh 
Enter domain name of certificate you wish to revoke
test.com
Are you sure you wish to revoke the following certificate?
serial=1000
subject= /C=ch/ST=zuerich/O=Example Corp/OU=Example Corp - CA/CN=test.com
issuer= /C=ch/ST=zuerich/O=Example Corp/OU=Example Corp - CA/CN=intermediate ca
notBefore=Apr 12 11:46:21 2018 GMT
notAfter=Apr 11 11:46:21 2020 GMT
y/n? >y

Using configuration from intermediate/openssl.cnf
Enter pass phrase for /home/ozzi/myca/intermediate/private/intermediate.key.pem:
Revoking Certificate 1000.
Data Base Updated

Certificate revoked
```
