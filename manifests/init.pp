# == Class: yum
#
# Manages yum
#
class yum (
  $config_path       = '/etc/yum.conf',
  $config_owner      = 'root',
  $config_group      = 'root',
  $config_mode       = '0644',
  $manage_repos      = false,
  $repos_d_owner     = 'root',
  $repos_d_group     = 'root',
  $repos_d_mode      = '0755',
  $repos_hiera_merge = true,
  $repos             = undef,
  $distroverpkg      = undef,
  $pkgpolicy         = undef,
  $proxy             = undef,
  $installonly_limit = undef,
) {

  include ::yum::updatesd

  validate_absolute_path($config_path)
  validate_string($config_owner)
  validate_string($config_group)
  validate_re($config_mode, '^[0-7]{4}$',
    "yum::config_mode is <${config_mode}> and must be a valid four digit mode in octal notation.")

  validate_string($repos_d_owner)
  validate_string($repos_d_group)
  validate_re($repos_d_mode, '^[0-7]{4}$',
    "yum::repos_d_mode is <${repos_d_mode}> and must be a valid four digit mode in octal notation.")

  if $proxy != undef {
    validate_string($proxy)
  }

  if $installonly_limit != undef {
    if is_string($installonly_limit) == false and is_integer($installonly_limit) == false {
      $installonly_limit_type = type3x($installonly_limit)
      fail("yum::installonly_limit is <${installonly_limit}> with type ${installonly_limit_type} and must be a string or an integer")
    }
  }

  if type3x($manage_repos) == 'string' {
    $manage_repos_bool = str2bool($manage_repos)
  } else {
    $manage_repos_bool = $manage_repos
  }
  validate_bool($manage_repos_bool)

  case $manage_repos_bool {
    true: {
      $repos_d_purge   = true
      $repos_d_recurse = true
    }
    false: {
      $repos_d_purge   = false
      $repos_d_recurse = false
    }
    default: {
      fail("yum::manage_repos must be true or false and is ${manage_repos}")
    }
  }

  if type3x($repos_hiera_merge) == 'string' {
    $repos_hiera_merge_real = str2bool($repos_hiera_merge)
  } else {
    $repos_hiera_merge_real = $repos_hiera_merge
  }
  validate_bool($repos_hiera_merge_real)

  if $repos != undef {
    if $repos_hiera_merge_real == true {
      $repos_real = hiera_hash('yum::repos')
    } else {
      $repos_real = $repos
    }
    validate_hash($repos_real)
    create_resources('yum::repo',$repos_real)
  }

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
    purge   => $repos_d_purge,
    recurse => $repos_d_recurse,
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
