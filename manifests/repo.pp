# @summary Manage individual yum repo files in /etc/yum.repos.d
#   This was used in favor of the yumrepo type, which cannot
#   manage files in that directory.
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
# @param gpgkey_local_path
#   Specify the path where GPG keys should be stored locally.
#
#
#
#
#
# @param enabled
#   enabled setting in the repository file.
#   True enables, false disables this feature. When empty, it will not be present.
#
# @param enablegroups
#   enablegroups setting in the repository file.
#   True enables, false disables this feature. When empty, it will not be present.
#
# @param gpgcheck
#   gpgcheck setting in the repository file.
#   True enables, false disables this feature. When empty, it will not be present.
#
# @param keepalive
#   keepalive setting in the repository file.
#   True enables, false disables this feature. When empty, it will not be present.
#
# @param repo_gpgcheck
#   repo_gpgcheck setting in the repository file.
#   True enables, false disables this feature. When empty, it will not be present.
#
# @param skip_if_unavailable
#   skip_if_unavailable setting in the repository file.
#   True enables, false disables this feature. When empty, it will not be present.
#
# @param ssl_check_cert_permissions
#   ssl_check_cert_permissions setting in the repository file.
#   True enables, false disables this feature. When empty, it will not be present.
#
# @param sslverify
#   sslverify setting in the repository file.
#   True enables, false disables this feature. When empty, it will not be present.
#
# @param bandwidth
#   bandwidth setting in the repository file.
#   Takes any integer. When empty, it will not be present.
#
# @param cost
#   cost setting in the repository file.
#   Takes any integer. When empty, it will not be present.
#
# @param mirrorlist_expire
#   mirrorlist_expire setting in the repository file.
#   Takes any integer. When empty, it will not be present.
#
# @param retries
#   retries setting in the repository file.
#   Takes any integer. When empty, it will not be present.
#
# @param timeout
#   timeout settingg in the repository file.
#   Takes any integer. When empty, it will not be present.
#
# @param description
#   name setting in the repository file.
#   Defaults to the name of the defined type. When empty, it will not be present.
#
# @param password
#   password setting in the repository file. When empty, it will not be present.
#
# @param proxy_password
#   proxy_password setting in the repository file. When empty, it will not be present.
#
# @param proxy_username
#   proxy_username setting in the repository file. When empty, it will not be present.
#
# @param repositoryid
#   repositoryid setting in the repository file. When empty, it will not be present.
#
# @param username
#   username setting in the repository file. When empty, it will not be present.
#
# @param baseurl
#   baseurl setting in the repository file. Accepts HTTP/HTTPS URLs.
#   When empty, it will not be present.
#
# @param gpgcakey
#   gpgcakey setting in the repository file. Accepts HTTP/HTTPS URLs.
#   When empty, it will not be present.
#
# @param gpgkey
#   gpgkey setting in the repository file.  Accepts HTTP/HTTPS URLs.
#   When empty, it will not be present.
#
# @param metalink
#   metalink setting in the repository file. Accepts HTTP/HTTPS URLs.
#   When empty, it will not be present.
#
# @param mirrorlist
#   mirrorlist setting in the repository file. Accepts HTTP/HTTPS URLs.
#   When empty, it will not be present.
#
# @param proxy
#   proxy setting in the repository file. Accepts HTTP/HTTPS URLs and '_none_'.
#   When empty, it will not be present.
#
# @param failovermethod
#   failovermethod setting in the repository file. Valid values are: 'priority' or 'roundrobin'.
#   When empty, it will not be present in yum.conf.
#
# @param http_caching
#   http_caching setting in the repository file. Valid values are: 'all', 'none', or 'packages'.
#   When empty, it will not be present in yum.conf.
#
# @param throttle
#   throttle setting in the repository file.
#   Rate in bytes/sec, allows a suffix of k, M, or G to be appended.
#   When empty, it will not be present.
#
# @param metadata_expire
#   metadata_expire setting in the repository file.
#   Time in seconds, allows a suffix of m, h, or d to specify minutes, hours, or days.
#   Alternatively you can also specify the word never instead.
#   When empty, it will not be present.
#
# @param sslcacert
#   sslcacert setting in the repository file.
#   When empty, it will not be present.
#
# @param sslclientcert
#   sslclientcert setting in the repository file.
#   When empty, it will not be present.
#
# @param sslclientkey
#   sslclientkey setting in the repository file.
#   When empty, it will not be present.
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
  Enum['absent', 'present'] $ensure         = 'present',
  Stdlib::Filemode $repo_file_mode          = '0400',
  Stdlib::Absolutepath $yum_repos_d_path    = '/etc/yum.repos.d',
  Stdlib::Absolutepath $gpgkey_local_path   = '/etc/pki/rpm-gpg',
  # parameters for repo file
  # lint:ignore:empty_string_assignment
  Variant[Enum[''],Boolean] $enabled                      = true,
  Variant[Enum[''],Boolean] $enablegroups                 = '',
  Variant[Enum[''],Boolean] $gpgcheck                     = false,
  Variant[Enum[''],Boolean] $keepalive                    = '',
  Variant[Enum[''],Boolean] $repo_gpgcheck                = '',
  Variant[Enum[''],Boolean] $skip_if_unavailable          = '',
  Variant[Enum[''],Boolean] $ssl_check_cert_permissions   = '',
  Variant[Enum[''],Boolean] $sslverify                    = '',
  Variant[Enum[''],Integer] $bandwidth                    = '',
  Variant[Enum[''],Integer] $cost                         = '',
  Variant[Enum[''],Integer] $mirrorlist_expire            = '',
  Variant[Enum[''],Integer] $retries                      = '',
  Variant[Enum[''],Integer] $timeout                      = '',
  Variant[Enum[''],String] $description                   = $name,
  Variant[Enum[''],String] $password                      = '',
  Variant[Enum[''],String] $proxy_password                = '',
  Variant[Enum[''],String] $proxy_username                = '',
  Variant[Enum[''],String] $repositoryid                  = '',
  Variant[Enum[''],String] $username                      = '',
  Variant[Enum[''],Stdlib::Httpurl] $baseurl              = '',
  Variant[Enum[''],Stdlib::Httpurl] $gpgcakey             = '',
  Variant[Enum[''],Stdlib::Httpurl] $gpgkey               = '',
  Variant[Enum[''],Stdlib::Httpurl] $metalink             = '',
  Variant[Enum[''],Stdlib::Httpurl] $mirrorlist           = '',
  Variant[Enum['','_none_'],Stdlib::Httpurl] $proxy       = '',
  Enum['','priority','roundrobin'] $failovermethod        = '',
  Enum['','all','none','packages'] $http_caching          = '',
  Variant[Enum[''],Integer,Float,Pattern[/^\d+(.\d+|)(k|M|G)*$/]] $throttle = '',
  Variant[Enum[''],Integer,Pattern[/^(\d+(m|h|d)*|never|)$/]] $metadata_expire = '',
  Variant[Enum[''],Stdlib::Absolutepath] $sslcacert       = '',
  Variant[Enum[''],Stdlib::Absolutepath] $sslclientcert   = '',
  Variant[Enum[''],Stdlib::Absolutepath] $sslclientkey    = '',
  Array $exclude                                          = [],
  Array $includepkgs                                      = [],
  # lint:endignore
) {

  $enabled_string = $enabled ? {
    Boolean => bool2str($enabled, '1', '0'),
    default => '',
  }
  $enablegroups_string = $enablegroups ? {
    Boolean => bool2str($enablegroups, '1', '0'),
    default => '',
  }
  $gpgcheck_string = $gpgcheck ? {
    Boolean => bool2str($gpgcheck, '1', '0'),
    default => '',
  }
  $keepalive_string = $keepalive ? {
    Boolean => bool2str($keepalive, '1', '0'),
    default => '',
  }
  $repo_gpgcheck_string = $repo_gpgcheck ? {
    Boolean => bool2str($repo_gpgcheck, '1', '0'),
    default => '',
  }
  $skip_if_unavailable_string = $skip_if_unavailable ? {
    Boolean => bool2str($skip_if_unavailable, '1', '0'),
    default => '',
  }
  $ssl_check_cert_permissions_string = $ssl_check_cert_permissions ? {
    Boolean => bool2str($ssl_check_cert_permissions, '1', '0'),
    default => '',
  }
  $sslverify_string = $sslverify ? {
    Boolean => bool2str($sslverify, '1', '0'),
    default => '',
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

  $_osmajor = $::facts['os']['release']['major']

  # uppercase name of repo
  $upcase_name = upcase($name)

  # Only need to deal with importing GPG keys, if we have gpgcheck enabled
  if ($ensure == 'present') and ($gpgcheck_string == '1') {
    yum::rpm_gpg_key { $upcase_name:
      gpgkey_url => $gpgkey,
      gpgkey     => "${gpgkey_local_path}/RPM-GPG-KEY-${upcase_name}-${_osmajor}",
      before     => File["${name}.repo"],
    }
  }
}
