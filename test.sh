#!/bin/bash

set -x

# Create a client certificate for testing

export TEST_CN=test.sh@$DOMAIN

(
  cd ca
  ./create-certificate.sh --client $TEST_CN
)

# Authenticated HTTPS request to whoami

curl --cacert $IMAGE_DATA/ca/intermediate/certs/ca-chain.cert.pem \
  --cert $IMAGE_DATA/ca/intermediate/dist/$TEST_CN.full.pem \
  https://whoami.$DOMAIN/
