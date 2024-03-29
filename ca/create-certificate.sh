#!/bin/bash

SRC=$(pwd)

if [ ! -d $IMAGE_DATA/ca/intermediate ]; then
  echo run create-root.sh and create-intermediate.sh first
  exit
fi

usage() {
  echo 'usage: create-certificate.sh [-v | --verbose] [--renew] --server domain[,domain,...]' 2>&1
  echo '    or create-certificate.sh [-v | --verbose] [--renew] --client name' 2>&1
  exit 1
}

cd $IMAGE_DATA/ca/intermediate

args=()
TYPE=''

while (($#)); do
  case "$1" in
  --server) TYPE=server ;;
  --client) TYPE=client ;;
  --renew) RENEW=1 ;;
  -v | --verbose) VERBOSE=1 ;;
  -*) usage ;;
  --)
    shift
    args+=("$@")
    set --
    ;;
  *) args+=("$1") ;;
  esac
  shift
done

set -- "${args[@]}"

if [ -z "$1" ]; then
  usage
fi

case "$TYPE" in
server)
  EXT=server_cert
  COMMON_NAME="${1%%,*}"
  SAN="DNS:${1//,/,DNS:}"
  CERT_FILENAME="${COMMON_NAME/\*/star}"
  m4 -D ROOT_DIR=$(pwd) -D CERT=intermediate \
    -D SAN=$SAN $SRC/openssl.cnf.m4 >openssl.cnf
  ;;
client)
  EXT=usr_cert
  COMMON_NAME="$1"
  CERT_FILENAME="${COMMON_NAME}"
  m4 -D ROOT_DIR=$(pwd) -D CERT=intermediate $SRC/openssl.cnf.m4 >openssl.cnf
  ;;
*) usage ;;
esac

if [ ! -e "private/$CERT_FILENAME.key.pem" ]; then
  openssl genrsa -out "private/$CERT_FILENAME.key.pem" 2048
  chmod 400 "private/$CERT_FILENAME.key.pem"
fi

if [ -n "$RENEW" ]; then
  openssl ca -config openssl.cnf -updatedb
fi

if [ -n "$RENEW" -o ! -e "csr/$CERT_FILENAME.csr.pem" ]; then
  if [ -n "$SAN" ]; then
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

if [ -n "$RENEW" -o ! -e "certs/$CERT_FILENAME.cert.pem" ]; then
  [ -n "$RENEW" ] && rm -f "certs/$CERT_FILENAME.cert.pem"
  if [ -n "$SAN" ]; then
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

if [ -n "$VERBOSE" ]; then
  openssl x509 -noout -text -in "certs/$CERT_FILENAME.cert.pem"
fi

if [ -n "$RENEW" -o ! -e "dist/$CERT_FILENAME.full.pem" ]; then
  cat "private/$CERT_FILENAME.key.pem" \
    "certs/$CERT_FILENAME.cert.pem" \
    certs/ca-chain.cert.pem >"dist/$CERT_FILENAME.full.pem"
fi

if [ -n "$RENEW" -o ! -e "dist/$CERT_FILENAME.full.pfx" ]; then
  openssl pkcs12 -export \
    -inkey "private/$CERT_FILENAME.key.pem" \
    -in "certs/$CERT_FILENAME.cert.pem" \
    -certfile certs/ca-chain.cert.pem \
    -out "dist/$CERT_FILENAME.full.pfx"
fi
