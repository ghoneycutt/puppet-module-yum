# @summary Manage a yum repository service
#
# @param contact_email
#   Set email address for server administration contact.
#   Will be used for ServerAdmin in Apache vhost configuration.
#
# @param docroot
#   Set absolute path to document root. Will be used for DocumentRoot
#   Apache vhost configuration.
#
# @param gpg_keys_path
#   Set relative path to GPG keys directory which will be in $docroot
#   directory. $docroot/$gpg_keys_path will be created and used.
#
# @param gpg_user_name
#    Set user who signs the packages. Will be used as %_gpg_name in
#    /root/.rpmmacros.
#
# @param servername
#   Set servername for yum repository. Will be used for ServerName in
#   Apache vhost configuration.
#
# @param serveraliases
#   Set serveraliases for yum repository. Will be used for ServerAlias Apache
#   vhost configuration.
#
# @param http_listen_ip
#   Set listen IP for yum repository server. Will be used for VirtualHost
#   in Apache vhost configuration.
#
class yum::server (
  String $contact_email                 = 'root@localhost',
  Stdlib::Absolutepath $docroot         = '/opt/repos',
  String $gpg_keys_path                 = 'keys', # gpg_keys_path is relative to $docroot, ${docroot}/${gpg_keys_path}
  String $gpg_user_name                 = 'Root',
  String $servername                    = 'yum',
  Array[String, 1]  $serveraliases      = [ $::fqdn, $::hostname ],
  IP::Address::NoSubnet $http_listen_ip = $::ipaddress,
) {

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
    require => "Exec[mkdir_p-${docroot}]",
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

  exec { "mkdir_p-${docroot}":
    command => "mkdir -p ${docroot}",
    unless  => "test -d ${docroot}",
    path    => '/bin:/usr/bin',
  }

  apache::vhost { 'yumrepo':
    docroot       => $docroot,
    port          => '80',
    vhost_name    => $http_listen_ip,
    servername    => $servername,
    serveraliases => $serveraliases,
    serveradmin   => $contact_email,
    options       => ['Indexes','FollowSymLinks','MultiViews'],
    override      => ['AuthConfig'],
    require       => "Exec[mkdir_p-${docroot}]",
  }
}
