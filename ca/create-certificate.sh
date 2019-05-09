#!/bin/bash

SRC=`pwd`

if [ ! -d $IMAGE_DATA/ca/intermediate ]
then
  echo run create-root.sh and create-intermediate.sh first
  exit
fi

cd $IMAGE_DATA/ca/intermediate

case "$1" in
--server)
  shift
  EXT=server_cert
  COMMON_NAME="${1%%,*}"
  SAN="DNS:${1//,/,DNS:}"
  CERT_FILENAME="${COMMON_NAME/\*/star}"
  m4 -D ROOT_DIR=`pwd` -D CERT=intermediate \
    -D SAN=$SAN $SRC/openssl.cnf.m4 >openssl.cnf
  ;;
--client)
  shift
  EXT=usr_cert
  COMMON_NAME="$1"
  CERT_FILENAME="${COMMON_NAME}"
  m4 -D ROOT_DIR=`pwd` -D CERT=intermediate $SRC/openssl.cnf.m4 >openssl.cnf
  ;;
*)
  echo 'usage: create-certificate.sh --server domain[,domain,...]' 2>&1
  echo '    or create-certificate.sh --client name' 2>&1
  exit
esac

if [ ! -e "private/$CERT_FILENAME.key.pem" ]
then
  openssl genrsa -out "private/$CERT_FILENAME.key.pem" 2048
  chmod 400 "private/$CERT_FILENAME.key.pem"
fi

if [ ! -e "csr/$CERT_FILENAME.csr.pem" ]
then
  if [ -n "$SAN" ]
  then
    openssl req -config openssl.cnf \
        -key "private/$CERT_FILENAME.key.pem" \
        -new -sha256 -extensions san \
        -subj "$CA_SUBJECT/CN=$COMMON_NAME" \
        -out "csr/$CERT_FILENAME.csr.pem"
  else
    openssl req -config openssl.cnf \
        -key "private/$CERT_FILENAME.key.pem" \
        -new -sha256 \
        -subj "$CA_SUBJECT/CN=$COMMON_NAME" \
        -out "csr/$CERT_FILENAME.csr.pem"
  fi
fi

if [ ! -e "certs/$CERT_FILENAME.cert.pem" ]
then
  if [ -n "$SAN" ]
  then
    openssl ca -config openssl.cnf \
        -extensions $EXT -extensions san \
        -days 365 -notext -md sha256 \
        -in "csr/$CERT_FILENAME.csr.pem" \
        -out "certs/$CERT_FILENAME.cert.pem"
  else
    openssl ca -config openssl.cnf \
        -extensions $EXT \
        -days 365 -notext -md sha256 \
        -in "csr/$CERT_FILENAME.csr.pem" \
        -out "certs/$CERT_FILENAME.cert.pem"
  fi
  chmod 444 "certs/$CERT_FILENAME.cert.pem"
fi

openssl x509 -noout -text -in "certs/$CERT_FILENAME.cert.pem"

if [ ! -e "dist/$CERT_FILENAME.full.pem" ]
then
  cat "private/$CERT_FILENAME.key.pem" \
      "certs/$CERT_FILENAME.cert.pem" \
      certs/ca-chain.cert.pem > "dist/$CERT_FILENAME.full.pem"
fi

if [ ! -e "dist/$CERT_FILENAME.full.pfx" ]
then
  openssl pkcs12 -export \
      -inkey "private/$CERT_FILENAME.key.pem" \
      -in "certs/$CERT_FILENAME.cert.pem" \
      -certfile certs/ca-chain.cert.pem \
      -out "dist/$CERT_FILENAME.full.pfx"
fi
