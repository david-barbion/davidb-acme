class acme::params {
  $account_key_file = 'puppet-acme.key'
  $letsencrypt_dir = '/etc/letsencrypt'
  $letsencrypt_acme_dir = "acme"
  $letsencrypt_private_keys_dir = "keys"
  $letsencrypt_requests_dir = "csr"
  $letsencrypt_certs_dir = "crt"
  $pem_src = 'https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem.txt'
}
