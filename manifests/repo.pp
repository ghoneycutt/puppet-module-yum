# @summary Manage individual yum repo files in /etc/yum.repos.d This was used
# in favor of the yumrepo type, which cannot manage files in that directory.
#
# @example Using the define.
#   yum::repo { 'redhat-base':
#     gpgcheck => true,
#   }
#
# @param ensure
#   Set to "present" or "absent". When absent, removes the repository
#   configuration file from the node modeled on the behavior of the
#   File type's ensure parameter.
#
# @param repo_file_mode
#   Set the file mode of the repository configuration file.
#
# @param yum_repos_d_path
#   Specify the path of the directory for yum repository files.
#
#
#
#
#
# @param enabled
#   enabled setting in the repository file.
#   True enables, false disables this feature. When undef, it will not be present.
#
# @param enablegroups
#   enablegroups setting in the repository file.
#   True enables, false disables this feature. When undef, it will not be present.
#
# @param gpgcheck
#   gpgcheck setting in the repository file.
#   True enables, false disables this feature. When undef, it will not be present.
#
# @param keepalive
#   keepalive setting in the repository file.
#   True enables, false disables this feature. When undef, it will not be present.
#
# @param repo_gpgcheck
#   repo_gpgcheck setting in the repository file.
#   True enables, false disables this feature. When undef, it will not be present.
#
# @param skip_if_unavailable
#   skip_if_unavailable setting in the repository file.
#   True enables, false disables this feature. When undef, it will not be present.
#
# @param ssl_check_cert_permissions
#   ssl_check_cert_permissions setting in the repository file.
#   True enables, false disables this feature. When undef, it will not be present.
#
# @param sslverify
#   sslverify setting in the repository file.
#   True enables, false disables this feature. When undef, it will not be present.
#
# @param bandwidth
#   bandwidth setting in the repository file.
#   Takes any integer. When undef, it will not be present.
#
# @param cost
#   cost setting in the repository file.
#   Takes any integer. When undef, it will not be present.
#
# @param mirrorlist_expire
#   mirrorlist_expire setting in the repository file.
#   Takes any integer. When undef, it will not be present.
#
# @param retries
#   retries setting in the repository file.
#   Takes any integer. When undef, it will not be present.
#
# @param timeout
#   timeout settingg in the repository file.
#   Takes any integer. When undef, it will not be present.
#
# @param description
#   name setting in the repository file.
#   Defaults to the name of the defined type. When undef, it will not be present.
#
# @param password
#   password setting in the repository file. When undef, it will not be present.
#
# @param proxy_password
#   proxy_password setting in the repository file. When undef, it will not be present.
#
# @param proxy_username
#   proxy_username setting in the repository file. When undef, it will not be present.
#
# @param repositoryid
#   repositoryid setting in the repository file. When undef, it will not be present.
#
# @param username
#   username setting in the repository file. When undef, it will not be present.
#
# @param baseurl
#   baseurl setting in the repository file. Accepts HTTP/HTTPS/FTP/FILE URLs.
#   When undef, it will not be present.
#
# @param gpgcakey
#   gpgcakey setting in the repository file. Accepts HTTP/HTTPS URLs.
#   When undef, it will not be present.
#
# @param gpgkey
#   gpgkey setting in the repository file.  Accepts HTTP/HTTPS/FTP/FILE URLs.
#   When undef, it will not be present.
#
# @param metalink
#   metalink setting in the repository file. Accepts HTTP/HTTPS URLs.
#   When undef, it will not be present.
#
# @param mirrorlist
#   mirrorlist setting in the repository file. Accepts HTTP/HTTPS URLs.
#   When undef, it will not be present.
#
# @param proxy
#   proxy setting in the repository file. Accepts HTTP/HTTPS URLs and '_none_'.
#   When undef, it will not be present.
#
# @param failovermethod
#   failovermethod setting in the repository file. Valid values are: 'priority' or 'roundrobin'.
#   When undef, it will not be present in yum.conf.
#
# @param http_caching
#   http_caching setting in the repository file. Valid values are: 'all', 'none', or 'packages'.
#   When undef, it will not be present in yum.conf.
#
# @param throttle
#   throttle setting in the repository file.
#   Rate in bytes/sec, allows a suffix of k, M, or G to be appended.
#   When undef, it will not be present.
#
# @param metadata_expire
#   metadata_expire setting in the repository file.
#   Time in seconds, allows a suffix of m, h, or d to specify minutes, hours, or days.
#   Alternatively you can also specify the word never instead.
#   When undef, it will not be present.
#
# @param sslcacert
#   sslcacert setting in the repository file.
#   When undef, it will not be present.
#
# @param sslclientcert
#   sslclientcert setting in the repository file.
#   When undef, it will not be present.
#
# @param sslclientkey
#   sslclientkey setting in the repository file.
#   When undef, it will not be present.
#
# @param exclude
#   exclude setting in the repository file.
#   When empty, it will not be present.
#
# @param includepkgs
#   includepkgs setting in the repository file.
#   When empty, it will not be present.
#
define yum::repo (
  Enum['absent', 'present'] $ensure             = 'present',
  Stdlib::Filemode $repo_file_mode              = '0400',
  Stdlib::Absolutepath $yum_repos_d_path        = '/etc/yum.repos.d',
  # parameters for repo file
  Array $exclude                                = [],
  Array $includepkgs                            = [],
  Optional[Boolean] $enabled                    = true,
  Optional[Boolean] $enablegroups               = undef,
  Optional[Boolean] $gpgcheck                   = false,
  Optional[Boolean] $keepalive                  = undef,
  Optional[Boolean] $repo_gpgcheck              = undef,
  Optional[Boolean] $skip_if_unavailable        = undef,
  Optional[Boolean] $ssl_check_cert_permissions = undef,
  Optional[Boolean] $sslverify                  = undef,
  Optional[Integer] $bandwidth                  = undef,
  Optional[Integer] $cost                       = undef,
  Optional[Integer] $mirrorlist_expire          = undef,
  Optional[Integer] $retries                    = undef,
  Optional[Integer] $timeout                    = undef,
  Optional[String] $description                 = $name,
  Optional[String] $password                    = undef,
  Optional[String] $proxy_password              = undef,
  Optional[String] $proxy_username              = undef,
  Optional[String] $repositoryid                = undef,
  Optional[String] $username                    = undef,
  Optional[Stdlib::Absolutepath] $sslcacert     = undef,
  Optional[Stdlib::Absolutepath] $sslclientcert = undef,
  Optional[Stdlib::Absolutepath] $sslclientkey  = undef,
  Optional[Stdlib::Httpurl] $gpgcakey           = undef,
  Optional[Stdlib::Httpurl] $metalink           = undef,
  Optional[Stdlib::Httpurl] $mirrorlist         = undef,
  Array[Variant[Stdlib::Httpurl,Pattern[/^(file|ftp):\/\//]]] $baseurl          = [],
  Array[Variant[Stdlib::Httpurl,Pattern[/^(file|ftp):\/\//]]] $gpgkey           = [],
  Optional[Enum['priority','roundrobin']] $failovermethod                       = undef,
  Optional[Enum['all','none','packages']] $http_caching                         = undef,
  Optional[Variant[Stdlib::Httpurl,Enum['_none_']]] $proxy                      = undef,
  Optional[Variant[Integer,Float,Pattern[/^\d+(.\d+|)(k|M|G)*$/]]] $throttle    = undef,
  Optional[Variant[Integer,Pattern[/^(\d+(m|h|d)*|never|)$/]]] $metadata_expire = undef,
) {

  $enabled_string = $enabled ? {
    Boolean => bool2str($enabled, '1', '0'),
    default => undef,
  }

  $enablegroups_string = $enablegroups ? {
    Boolean => bool2str($enablegroups, '1', '0'),
    default => undef,
  }

  $gpgcheck_string = $gpgcheck ? {
    Boolean => bool2str($gpgcheck, '1', '0'),
    default => undef,
  }

  $keepalive_string = $keepalive ? {
    Boolean => bool2str($keepalive, '1', '0'),
    default => undef,
  }

  $repo_gpgcheck_string = $repo_gpgcheck ? {
    Boolean => bool2str($repo_gpgcheck, '1', '0'),
    default => undef,
  }

  $skip_if_unavailable_string = $skip_if_unavailable ? {
    Boolean => bool2str($skip_if_unavailable, '1', '0'),
    default => undef,
  }

  $ssl_check_cert_permissions_string = $ssl_check_cert_permissions ? {
    Boolean => bool2str($ssl_check_cert_permissions, '1', '0'),
    default => undef,
  }

  $sslverify_string = $sslverify ? {
    Boolean => bool2str($sslverify, '1', '0'),
    default => undef,
  }

  $file_ensure = $ensure ? {
    'present' => 'file',
    'absent'  => 'absent',
  }

  # repo file
  # ie: /etc/yum.repos.d/customrepo.repo
  file { "${name}.repo":
    ensure  => $file_ensure,
    path    => "${yum_repos_d_path}/${name}.repo",
    owner   => 'root',
    group   => 'root',
    mode    => $repo_file_mode,
    content => template('yum/repo.erb'),
    notify  => Exec['clean_yum_cache'],
  }
}
