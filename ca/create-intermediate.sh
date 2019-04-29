#!/bin/bash

[ -d intermediate ] || mkdir intermediate
cd intermediate

if [ ! -e openssl.cnf ]
then
  m4 -D ROOT_DIR=`pwd` -D CERT=intermediate ../openssl.cnf.m4 >openssl.cnf
  vi openssl.cnf
  chmod 400 openssl.cnf
fi

mkdir certs crl csr newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial
echo 1000 > crlnumber

openssl genrsa -aes256 -out private/intermediate.key.pem 4096
chmod 400 private/intermediate.key.pem

openssl req -config openssl.cnf -new -sha256 \
      -key private/intermediate.key.pem \
      -out csr/intermediate.csr.pem

(
  cd ..
  openssl ca -config openssl.cnf -extensions v3_intermediate_ca \
        -days 3650 -notext -md sha256 \
        -in intermediate/csr/intermediate.csr.pem \
        -out intermediate/certs/intermediate.cert.pem
)

chmod 444 certs/intermediate.cert.pem

openssl x509 -noout -text -in certs/intermediate.cert.pem
