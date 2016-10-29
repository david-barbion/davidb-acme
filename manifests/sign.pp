# create a private key file
# generate a CSR
# and ask LE to sign it
# need:
#  - python
#  - a configured web server that is accessible from LE
#  - a .well-known/acme-challenge/ web root directory
#  - DNS configured
# 
# example nginx config
# server {
#   [...]
#   location /.well-known/acme-challenge {
#     root      /var/www/letsencrypt;
#   }
#   [...]
# }

define acme::sign(
$letsencrypt_dir = $::acme::letsencrypt_dir,
$letsencrypt_acme_dir = $::acme::letsencrypt_acme_dir,
$letsencrypt_private_keys_dir = $::acme::letsencrypt_private_keys_dir,
$letsencrypt_requests_dir = $::acme::letsencrypt_requests_dir,
$letsencrypt_certs_dir = $::acme::letsencrypt_certs_dir,
$account_key = $::acme::account_key_file,
$altnames = [],
$country = 'FR',
$state   = undef,
$organization = 'dummy',
$acme_dir = '/var/www/letsencrypt/.well-known/acme-challenge/',
$renew_days_before = undef,
$commonname = $title,
) {

  include "acme::ca"

  ssl_pkey { "$letsencrypt_dir/$letsencrypt_acme_dir/$letsencrypt_private_keys_dir/${title}.key":
    ensure  => present,
    require => File["$letsencrypt_dir/$letsencrypt_acme_dir/$letsencrypt_private_keys_dir"],
  }

  file { "$letsencrypt_dir/$letsencrypt_acme_dir/$letsencrypt_requests_dir/${title}.cnf":
    ensure => present,
    content => template("openssl/cert.cnf.erb")
  }

  x509_request { "$letsencrypt_dir/$letsencrypt_acme_dir/$letsencrypt_requests_dir/${title}.csr":
    ensure      => present,
    private_key => "$letsencrypt_dir/$letsencrypt_acme_dir/$letsencrypt_private_keys_dir/${title}.key",
    template    => "$letsencrypt_dir/$letsencrypt_acme_dir/$letsencrypt_requests_dir/${title}.cnf",
    require     => [Ssl_pkey["$letsencrypt_dir/$letsencrypt_acme_dir/$letsencrypt_private_keys_dir/${title}.key"],
                    File["$letsencrypt_dir/$letsencrypt_acme_dir/$letsencrypt_requests_dir/${title}.cnf"]],
    notify      => Exec["remove ${title}.crt"],
  }

  # this will remove the crt if the csr has changed
  exec { "remove ${title}.crt":
    command     => "rm -f '$letsencrypt_dir/$letsencrypt_acme_dir/$letsencrypt_certs_dir/${title}.crt'",
    refreshonly => true,
  }

  if $renew_days_before {
    exec { "remove expired ${title}.crt":
      command => "rm -f '$letsencrypt_dir/$letsencrypt_acme_dir/$letsencrypt_requests_dir/${title}.csr'",
      onlyif  => "bash /usr/bin/cert-expiry.sh \"$letsencrypt_dir/$letsencrypt_acme_dir/$letsencrypt_certs_dir/${title}.crt\" ${renew_days_before}",
      before  => X509_request["$letsencrypt_dir/$letsencrypt_acme_dir/$letsencrypt_requests_dir/${title}.csr"],
      require => File["/usr/bin/cert-expiry.sh"],
    }
  }

  exec { "sign ${title}":
    command => "python /usr/bin/acme_tiny.py  --account-key '${letsencrypt_dir}/accounts/${account_key}' --csr '$letsencrypt_dir/$letsencrypt_acme_dir/$letsencrypt_requests_dir/${title}.csr' --acme-dir '${acme_dir}' | cat $letsencrypt_dir/ca.pem > '$letsencrypt_dir/$letsencrypt_acme_dir/$letsencrypt_certs_dir/${title}.crt'",
    path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin'],
    creates => "$letsencrypt_dir/$letsencrypt_acme_dir/$letsencrypt_certs_dir/${title}.crt",
    require => [File["$letsencrypt_dir/$letsencrypt_acme_dir/$letsencrypt_certs_dir"],
                X509_request["$letsencrypt_dir/$letsencrypt_acme_dir/$letsencrypt_requests_dir/${title}.csr"]],
  }
}
