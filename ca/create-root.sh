#!/bin/bash

SRC=`pwd`

if [ -d $IMAGE_DATA/ca ]
then
  echo $IMAGE_DATA/ca already exists
  exit
fi

mkdir -p $IMAGE_DATA/ca
cd $IMAGE_DATA/ca

m4 -D ROOT_DIR=`pwd` -D CERT=root $SRC/openssl.cnf.m4 >openssl.cnf

mkdir certs crl newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial

openssl genrsa -aes256 -out private/ca.key.pem 4096
chmod 400 private/ca.key.pem

openssl req -config openssl.cnf \
      -key private/ca.key.pem \
      -new -x509 -days 7300 -sha256 -extensions v3_ca \
      -subj "$CA_SUBJECT/CN=Root" \
      -out certs/ca.cert.pem
chmod 444 certs/ca.cert.pem

openssl x509 -noout -text -in certs/ca.cert.pem
