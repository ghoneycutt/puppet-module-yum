# == Class: yum
#
# Manages yum
#
class yum (
  $config_path         = '/etc/yum.conf',
  $config_owner        = 'root',
  $config_group        = 'root',
  $config_mode         = '0644',
  $manage_repos        = false,
  $repos_d_owner       = 'root',
  $repos_d_group       = 'root',
  $repos_d_mode        = '0755',
  $repos_hiera_merge   = true,
  $repos               = undef,
  $distroverpkg        = false,
  $pkgpolicy           = undef,
  $proxy               = undef,
  $installonly_limit   = undef,
  $exclude             = undef,
  $exclude_hiera_merge = false,
) {

  include ::yum::updatesd

  validate_absolute_path($config_path)

  case $distroverpkg {
    true, 'true':   { $distroverpkg_bool = true }  # lint:ignore:quoted_booleans
    false, 'false': { $distroverpkg_bool = false } # lint:ignore:quoted_booleans
    default:        { fail("yum::distroverpkg is not a boolean. It is <${distroverpkg}>.") }
  }

  validate_string(
    $config_owner,
    $config_group,
    $repos_d_owner,
    $repos_d_group,
  )

  if $proxy != undef {
    validate_string($proxy)
  }

  if $pkgpolicy != undef {
    validate_re("${$pkgpolicy}", '^(newest|last)$', # lint:ignore:only_variable_string
      "yum::pkgpolicy must be <newest> or <last>. It is <${pkgpolicy}>.")
  }

  validate_re("${config_mode}", '^[0-7]{4}$', # lint:ignore:only_variable_string
    "yum::config_mode is not a file mode in octal notation. It is <${config_mode}>.")

  validate_re("${repos_d_mode}", '^[0-7]{4}$', # lint:ignore:only_variable_string
    "yum::repos_d_mode is not a file mode in octal notation. It is <${config_mode}>.")


  if $installonly_limit != undef {
    case type3x($installonly_limit) {
      'integer': { $installonly_limit_int = $installonly_limit }
      'string':  { $installonly_limit_int = floor($installonly_limit) }
      default:   { fail("yum::installonly_limit is not an integer nor stringified integer. It is <${installonly_limit}>.")}
    }
  }

  $exclude_hiera_merge_bool = str2bool($exclude_hiera_merge)
  validate_bool($exclude_hiera_merge_bool)

  if $exclude != undef {
    case type3x($exclude) {
      'array':  { $exclude_array = $exclude }
      'string': { $exclude_array = any2array($exclude) }
      default:  { fail("yum::exclude is <${exclude}> and must be either a string or an array.") }
    }

    case $exclude_hiera_merge_bool {
      true:    { $exclude_array_real = hiera_array('yum::exclude') }
      default: { $exclude_array_real = $exclude_array }
    }
  }

  case $manage_repos {
    true, 'true': { # lint:ignore:quoted_booleans
      $repos_d_purge   = true
      $repos_d_recurse = true
    }
    false, 'false': { # lint:ignore:quoted_booleans
      $repos_d_purge   = false
      $repos_d_recurse = false
    }
    default: {
      fail("yum::manage_repos is not a boolean. It is <${manage_repos}>.")
    }
  }

  case $repos_hiera_merge {
    true, 'true':   { $repos_hiera_merge_bool = true }  # lint:ignore:quoted_booleans
    false, 'false': { $repos_hiera_merge_bool = false } # lint:ignore:quoted_booleans
    default:        { fail("yum::repos_hiera_merge is not a boolean. It is <${repos_hiera_merge}>.") }
  }

  if $repos != undef {
    case $repos_hiera_merge_bool {
      true:    { $repos_real = hiera_hash('yum::repos') }
      default: { $repos_real = $repos }
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
