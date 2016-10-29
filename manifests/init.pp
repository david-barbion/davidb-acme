class acme(
$account_key_file = $::acme::params::account_key_file,
$letsencrypt_dir  = $::acme::params::letsencrypt_dir,
$letsencrypt_acme_dir = $::acme::params::letsencrypt_acme_dir,
$letsencrypt_private_keys_dir = $::acme::params::letsencrypt_private_keys_dir,
$letsencrypt_requests_dir = $::acme::params::letsencrypt_requests_dir,
$letsencrypt_certs_dir = $::acme::params::letsencrypt_certs_dir,
) inherits ::acme::params {

  include "acme::ca"

  file { $letsencrypt_dir:
    ensure => directory,
  }
  file { "$letsencrypt_dir/accounts":
    ensure => directory,
    mode   => "0700",
  }
  file { "$letsencrypt_dir/$letsencrypt_acme_dir":
    ensure => directory,
    mode   => "0755",
  }
  file { "$letsencrypt_dir/$letsencrypt_acme_dir/$letsencrypt_private_keys_dir":
    ensure => directory,
    mode   => "0700",
    require => File["$letsencrypt_dir/$letsencrypt_acme_dir"],
  }
  file { "$letsencrypt_dir/$letsencrypt_acme_dir/$letsencrypt_requests_dir":
    ensure => directory,
    mode   => "0755",
    require => File["$letsencrypt_dir/$letsencrypt_acme_dir"],
  }
  file { "$letsencrypt_dir/$letsencrypt_acme_dir/$letsencrypt_certs_dir":
    ensure => directory,
    mode   => "0755",
    require => File["$letsencrypt_dir/$letsencrypt_acme_dir"],
  }

  class { '::acme::key::account':
    key_file => "$letsencrypt_dir/accounts/$account_key_file",
    require  => File["$letsencrypt_dir/accounts"],
  }

  file { "/usr/bin/acme_tiny.py":
    source => "puppet:///modules/acme/acme_tiny.py",
    mode   => "0755"
  }
  file { "/usr/bin/cert-expiry.sh":
    source => "puppet:///modules/acme/cert-expiry.sh",
    mode   => "0755"
  }

}
