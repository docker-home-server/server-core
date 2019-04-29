# Home Server Config

These files show how I've set up my home server using Docker.
They may be useful as is, but are probably more useful just to
read through to see how I've tackled things.

## Certificate Authority

The `ca` subdirectory contains configuration files and scripts
to manage a certificate authority using OpenSSL,
based on the guide at
https://jamielinux.com/docs/openssl-certificate-authority/index.html.
I use this to issue client certificates for any device
that will be connecting to the home server from the public internet.
I don't want any URLs on the server to be accessible publicly,
and I don't want clients to have to remember
usernames and passwords to connect,
so client certificates seem like the simplest approach.

1. Create the Certification Authority root key and certificate -
[(guide)](https://jamielinux.com/docs/openssl-certificate-authority/create-the-root-pair.html)

```
cd ca
./create-root.sh
```

The script will generate an initial `openssl.cnf` file and allow you to
edit it using `vi`. The main section that you'll want to configure is
the defaults in the `req_distinguished_name` section,
from `countryName_default` onwards.

It will also prompt (twice) for a pass phrase to encrypt
the Certification Authority root private key.
For production use you should make this password secure.
You can also store the root key offline
(on a USB stick in a safe for example)
as it is not needed for day-to-day certificate operations.

OpenSSL will prompt for information to identify the root certificate.
The guide recommends that the Organizational Unit Name identifies
that this is the certification authority
(for example, `Alice Ltd Certificate Authority`),
and that the Common Name identifies it as the root certificate
(for example, `Alice Ltd Root CA`).

2. Create the intermediate key and certificate -
[(guide)](https://jamielinux.com/docs/openssl-certificate-authority/create-the-intermediate-pair.html)

```
cd ca
./create-intermediate.sh
```

This script operates in a similar manner:
first it will generate an `openssl.cnf` file for creating certificates
signed by the intermediate certificate.
You can customise the generated file using `vi`.

It will also prompt (twice) for a pass phrase to encrypt
the intermediate private key.
Again, choose a secure password for production usage.

The script then generates a certificate signing request
and then signs the CSR using the root certificate and key.
Read the prompts carefully when OpenSSL asks for the pass phrase
so you know whether to enter the root or intermediate pass phrase.
