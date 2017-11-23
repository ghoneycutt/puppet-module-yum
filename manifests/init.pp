# @summary Manage yum (client, server, and key management)
#
# @example Declaring the class
#   include ::yum
#
# @param config_path
#   Set the path to the yum.conf file, representing a fully qualified name.
#
# @param config_owner
#   Set owner access to the yum.conf file, representing a user.
#
# @param config_group
#   Set group access to the yum.conf file, representing a group.
#
# @param config_mode
#   Set access permissions for the yum.conf file, in numeric notation.
#
# @param manage_repos
#   Trigger if files in /etc/yum.repos.d should get managed by Puppet exclusivly.
#   If set to true, all unmanged files in /etc/yum.repos.d (and below) will get
#   removed.
#
# @param repos_d_owner
#   Set owner access to the /etc/yum.repos.d directory, representing a user.
#
# @param repos_d_group
#   Set group access to the /etc/yum.repos.d directory, representing a group.
#
# @param repos_d_mode
#   Set access permissions for the /etc/yum.repos.d directory, in numeric notation.
#
# @param repos_hiera_merge
#   Trigger to merge all found instances of yum::repos in Hiera. This is useful
#   for specifying repositories at different levels of the hierarchy and having
#   them all included in the catalog.
#
# @param repos
#   Hash of repos to pass to yum::repo. See yum::repo for more details.
#
# @param distroverpkg
#   Trigger to add the distroverpkg setting to the main section of yum.conf.
#   Will use the format distroverpk=$::operatingsystem-release (downcase) if active.
#
# @param pkgpolicy
#   Trigger to add the pkgpolicy setting with the given string to the main section
#   of yum.conf. Valid values are: 'newest' or 'last'.
#
# @param proxy
#   Trigger to add the proxy setting with the given string to the main section of
#   yum.conf. Specify a proxy URL.
#
# @param installonly_limit
#   Trigger to add the installonly_limit setting with the given number to the main
#   section of yum.conf. When unset (default) installonly_limit will not be present
#   in yum.conf.
#
# @param exclude
#   Value for the exclude setting in the main section of yum.conf.
#   When undef (default) exclude will not be present in yum.conf.
#
# @param exclude_hiera_merge
#   Trigger to merge all found instances of yum::exclude in Hiera. This is useful
#   for specifying repositories at different levels of the hierarchy and having
#   them all included in the catalog.
#
class yum (
  Stdlib::Absolutepath $config_path           = '/etc/yum.conf',
  String $config_owner                        = 'root',
  String $config_group                        = 'root',
  Stdlib::Filemode $config_mode               = '0644',
  Boolean $manage_repos                       = false,
  String $repos_d_owner                       = 'root',
  String $repos_d_group                       = 'root',
  Stdlib::Filemode $repos_d_mode              = '0755',
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

    $repos_real.each |$key,$value| {
      ::yum::repo { $key:
        * => $value,
      }
    }
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
