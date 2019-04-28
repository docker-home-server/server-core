#!/bin/bash

if [ ! -e root-config.txt ]
then
  m4 -D ROOT_DIR=`pwd` root-config.txt.m4 >root-config.txt
  vi root-config.txt
  chmod 400 root-config.txt
fi

mkdir certs crl newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial

openssl genrsa -aes256 -out private/ca.key.pem 4096
chmod 400 private/ca.key.pem

openssl req -config root-config.txt \
      -key private/ca.key.pem \
      -new -x509 -days 7300 -sha256 -extensions v3_ca \
      -out certs/ca.cert.pem
chmod 444 certs/ca.cert.pem

openssl x509 -noout -text -in certs/ca.cert.pem
