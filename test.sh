#!/bin/bash

set -x

# Authenticated HTTPS request to whoami

curl --cacert $IMAGE_DATA/ca/intermediate/certs/ca-chain.cert.pem \
  https://whoami.h.$DOMAIN/
