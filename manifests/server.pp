# == Class: yum::server
#
# Manage a yum repository service
#
class yum::server (
  $contact_email             = 'root@localhost',
  $docroot                   = '/opt/repos',
  # gpg_keys_path is relative to $docroot
  # ${docroot}/${gpg_keys_path}
  $gpg_keys_path             = 'keys',
  $gpg_user_name             = 'Root',
  $yum_server                = 'yum',
  $yum_server_http_listen_ip = $::ipaddress,
) {

  include ::apache

  # validate contact_email
  validate_absolute_path($docroot)
  validate_string($gpg_keys_path)
  validate_string($gpg_user_name)
  validate_string($yum_server)
  validate_string($yum_server_http_listen_ip)

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
