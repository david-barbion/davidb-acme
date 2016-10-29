
# this class create the let's encrypt account key
class acme::key::account(
$key_file,
) {
  include ::openssl

  ssl_pkey { $key_file:
    ensure   => 'present',
  }

}
