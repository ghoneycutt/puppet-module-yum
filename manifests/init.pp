# == Class: yum
#
# Manages yum
#
class yum (
  Stdlib::Absolutepath $config_path           = '/etc/yum.conf',
  String $config_owner                        = 'root',
  String $config_group                        = 'root',
  Pattern[/^[0-7]{4}$/] $config_mode          = '0644',
  Boolean $manage_repos                       = false,
  String $repos_d_owner                       = 'root',
  String $repos_d_group                       = 'root',
  Pattern[/^[0-7]{4}$/] $repos_d_mode         = '0755',
  Boolean $repos_hiera_merge                  = true,
  Optional[Hash] $repos                       = undef,
  Boolean $distroverpkg                       = false,
  Optional[Enum['newest', 'last']] $pkgpolicy = undef,
  Optional[String] $proxy                     = undef,
  Variant[Undef,Integer] $installonly_limit   = undef,
  Variant[Undef,String,Array] $exclude        = undef,
  Boolean $exclude_hiera_merge                = false,
) {

  if $exclude != undef {
    case $exclude {
      String:  { $exclude_array = any2array($exclude) }
      default: { $exclude_array = $exclude }
    }
    case $exclude_hiera_merge {
      true:    { $exclude_array_real = hiera_array('yum::exclude') }
      default: { $exclude_array_real = $exclude_array }
    }
  }

  if $repos != undef {
    case $repos_hiera_merge {
      true:    { $repos_real = hiera_hash('yum::repos') }
      default: { $repos_real = $repos }
    }
    validate_hash($repos_real)
    create_resources('yum::repo',$repos_real)
  }

  include ::yum::updatesd

  package { 'yum':
    ensure => installed,
  }

  file { 'yum_config':
    ensure  => file,
    path    => $config_path,
    content => template('yum/yum.conf.erb'),
    owner   => $config_owner,
    group   => $config_group,
    mode    => $config_mode,
    require => Package['yum'],
  }

  file { '/etc/yum.repos.d':
    ensure  => directory,
    purge   => $manage_repos,
    recurse => $manage_repos,
    owner   => $repos_d_owner,
    group   => $repos_d_group,
    mode    => $repos_d_mode,
    require => File['yum_config'],
    notify  => Exec['clean_yum_cache'],
  }

  exec { 'clean_yum_cache':
    command     => 'yum clean all',
    path        => '/bin:/usr/bin:/sbin:/usr/sbin',
    refreshonly => true,
  }
}
