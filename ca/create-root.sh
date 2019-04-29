#!/bin/bash




if [ ! -e openssl.cnf ]
then
  m4 -D ROOT_DIR=`pwd` -D CERT=root openssl.cnf.m4 >openssl.cnf
  vi openssl.cnf
  chmod 400 openssl.cnf
fi

mkdir certs crl newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial

openssl genrsa -aes256 -out private/ca.key.pem 4096
chmod 400 private/ca.key.pem

openssl req -config openssl.cnf \
      -key private/ca.key.pem \
      -new -x509 -days 7300 -sha256 -extensions v3_ca \
      -out certs/ca.cert.pem
chmod 444 certs/ca.cert.pem

openssl x509 -noout -text -in certs/ca.cert.pem
