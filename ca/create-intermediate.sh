#!/bin/bash

SRC=$(pwd)

if [ ! -d $IMAGE_DATA/ca ]; then
  echo run create-root.sh first
  exit
fi

cd $IMAGE_DATA/ca

if [ -d intermediate ]; then
  echo $IMAGE_DATA/ca/intermediate already exists
  exit
fi
mkdir intermediate
cd intermediate

m4 -D ROOT_DIR=$(pwd) -D CERT=intermediate $SRC/openssl.cnf.m4 >openssl.cnf

mkdir certs crl csr dist newcerts private
chmod 700 private
touch index.txt
echo 1000 >serial
echo 1000 >crlnumber

openssl genrsa -aes256 -out private/intermediate.key.pem 4096
chmod 400 private/intermediate.key.pem

openssl req -config openssl.cnf -new -sha256 \
  -key private/intermediate.key.pem \
  -subj "$CA_SUBJECT/CN=$CN_PREFIX Intermediate" \
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

cat certs/intermediate.cert.pem \
  ../certs/ca.cert.pem >certs/ca-chain.cert.pem

chmod 444 certs/ca-chain.cert.pem
