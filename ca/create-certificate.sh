#!/bin/bash

if [ ! -d $IMAGE_DATA/ca/intermediate ]
then
  echo run create-root.sh and create-intermediate.sh first
  exit
fi

case "$1" in
--server)
  EXT=server_cert
  shift
  ;;
--client)
  EXT=usr_cert
  shift
  ;;
*)
  echo 'usage: create-certificate.sh [--server|--client] common_name'
  exit
esac

COMMON_NAME="$1"

cd $IMAGE_DATA/ca/intermediate

openssl genrsa -out private/$COMMON_NAME.key.pem 2048
chmod 400 private/$COMMON_NAME.key.pem

openssl req -config openssl.cnf \
      -key private/$COMMON_NAME.key.pem \
      -new -sha256 -out csr/$COMMON_NAME.csr.pem

openssl ca -config openssl.cnf \
      -extensions $EXT \
      -days 365 -notext -md sha256 \
      -in csr/$COMMON_NAME.csr.pem \
      -out certs/$COMMON_NAME.cert.pem
chmod 444 certs/$COMMON_NAME.cert.pem

openssl x509 -noout -text -in certs/$COMMON_NAME.cert.pem

cat private/$COMMON_NAME.key.pem \
      certs/$COMMON_NAME.cert.pem \
      certs/ca-chain.cert.pem > dist/$COMMON_NAME.full.pem

openssl pkcs12 -export \
      -inkey private/$COMMON_NAME.key.pem \
      -in certs/$COMMON_NAME.cert.pem \
      -certfile certs/ca-chain.cert.pem \
      -out dist/$COMMON_NAME.full.pfx
