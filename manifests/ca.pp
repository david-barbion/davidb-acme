class acme::ca(
$pem_src         = $::acme::params::pem_src,
$letsencrypt_dir = $::acme::params::letsencrypt_dir,
) inherits acme::params{

  wget::fetch { $pem_src:
    destination => "$letsencrypt_dir/ca.pem",
  }->
  file { "$letsencrypt_dir/ca.pem":
    ensure => 'file',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }
}
