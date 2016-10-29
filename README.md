# ACME tiny Puppet module

## What is all about

This puppet module is used to generate and maintain Let'Encrypt signed certificates.
It uses ACME tiny (https://github.com/diafygi/acme-tiny) python script to request
signature.

## Why should you use ACME tiny and this module

Well, when using ACME tiny, you can be sure that your private key will not change every time
the certificate must be revalidated (every 2 or 3 months). 

## What the puppet module does

The module will create a Let's encrypt account for you.
The module will generate a private key for your server and will make a CSR (request).
Every time a request file is regenerated, the python script is called to ask the signature.
Then it will check the expiration of certificates and regenerate a CSR if so.


