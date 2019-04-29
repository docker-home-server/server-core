#!/bin/bash


if [ -d $IMAGE_DATA/ca ]
then
  cd $IMAGE_DATA/ca
  rm -rf certs crl intermediate newcerts private
  rm -f openssl.cnf index.txt{,.attr,.old} serial{,.old}
fi
