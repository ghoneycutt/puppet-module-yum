# == Class: yum::server
#
# Manage a yum repository service
#
class yum::server (
  String $contact_email             = 'root@localhost',
  Stdlib::Absolutepath $docroot     = '/opt/repos',
  String $gpg_keys_path             = 'keys', # gpg_keys_path is relative to $docroot, ${docroot}/${gpg_keys_path}
  String $gpg_user_name             = 'Root',
  String $yum_server                = 'yum',
  String $yum_server_http_listen_ip = $::ipaddress,
) {

  validate_ip_address($yum_server_http_listen_ip)

  include ::apache

  package { 'createrepo':
    ensure => installed,
  }

  package { 'hardlink':
    ensure => installed,
  }

  file { 'gpg_keys_dir':
    ensure  => directory,
    path    => "${docroot}/${gpg_keys_path}",
    recurse => true,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Common::Mkdir_p[$docroot],
  }

  # needed for signing packages
  file { 'dot_rpmmacros':
    ensure  => file,
    path    => '/root/.rpmmacros',
    content => template('yum/rpmmacros.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  common::mkdir_p { $docroot: }

  apache::vhost { 'yumrepo':
    docroot       => $docroot,
    port          => '80',
    vhost_name    => $yum_server_http_listen_ip,
    servername    => $yum_server,
    serveraliases => [ $::fqdn, $::hostname ],
    serveradmin   => $contact_email,
    options       => ['Indexes','FollowSymLinks','MultiViews'],
    override      => ['AuthConfig'],
    require       => Common::Mkdir_p[$docroot],
  }
}
