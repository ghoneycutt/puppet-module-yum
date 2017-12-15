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
# @param use_gpgkey_uri
#   Trigger to activate support for using GPG keys. If set to true the module
#   will download GPG keys and add the gpgkey parameter to the repository
#   configuration.
#
# @param repo_server
#   Specify the server part of the default URL for baseurl (see $baseurl).
#   Specifing $baseurl or $mirrlost will override this parameter.
#
# @param repo_server_protocol
#   Specify the protocol part of the default URL for baseurl (see $baseurl).
#   Specifing $baseurl or $mirrlost will override this parameter.
#
# @param repo_server_basedir
#   Specify the basedir part of the default URL for baseurl (see $baseurl).
#   Specifing $baseurl or $mirrlost will override this parameter.
#
# @param repo_file_mode
#   Set the file mode of the repository configuration file.
#
# @param yum_repos_d_path
#   Specify the path of the directory for yum repository files.
#
# @param gpgkey_url_proto
#   Specify the protocol part of the default URL for GPG keys (see $gpgkey).
#   Specifing $gpgkey will override this parameter.
#
# @param gpgkey_url_server
#   Specify the server part of the default URL for GPG keys (see $gpgkey).
#   If unset $repo_server will be used. Specifing $gpgkey will override this
#   parameter.
#
# @param gpgkey_url_path
#   Specify the URL part of the default URL for GPG keys (see $gpgkey).
#   Specifing $gpgkey will override this parameter.
#
# @param gpgkey_file_prefix
#   Specify the prefix part of the default URL for GPG keys (see $gpgkey).
#   Specifing $gpgkey will override this parameter.
#
# @param gpgkey_local_path
#   Specify the path where GPG keys should be stored locally.
#
# @param environment
#   Specify the environment part of the default value for baseurl (see $baseurl).
#   Specifying $baseurl or $mirrorlist will override this parameter.
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
#   Takes a form such as 'http://yum.domain.tld/customrepo/5/8/dev/x86_64'.
#   If $baseurl and $mirrorlist are both unset, it baseurl will become:
#   $repo_server_protocol://$username:$password@$repo_server/$repo_server_basedir/$name/$::facts['os']['release']['major']/$::facts['os']['release']['minor']/$environment/$basearch.
#   Passing $username and $password is optional.
#   If only $mirrorlist is set, baseurl will not be used in the repository configuration.
#
# @param gpgcakey
#   gpgcakey setting in the repository file. Accepts HTTP/HTTPS URLs.
#   When empty, it will not be present.
#
# @param gpgkey
#   gpgkey setting in the repository file.  Accepts HTTP/HTTPS URLs.
#   Will only be used when $use_gpgkey_uri is set to true.
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
  Boolean $use_gpgkey_uri                   = true,
  String $repo_server                       = "yum.${::domain}",
  String $repo_server_protocol              = 'http',
  String $repo_server_basedir               = '/',
  Stdlib::Filemode $repo_file_mode          = '0400',
  Stdlib::Absolutepath $yum_repos_d_path    = '/etc/yum.repos.d',
  String $gpgkey_url_proto                  = 'http',
  String $gpgkey_url_server                 = "yum.${::domain}",
  String $gpgkey_url_path                   = 'keys',
  String $gpgkey_file_prefix                = 'RPM-GPG-KEY',
  Stdlib::Absolutepath $gpgkey_local_path   = '/etc/pki/rpm-gpg',
  String $environment                       = $::environment,
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

  $_osmajor = $::facts['os']['release']['major']
  $_osminor = $::facts['os']['release']['minor']

  if is_domain_name($repo_server) == false {
    fail("yum::repo::repo_server is not a domain name. It is <${repo_server}>.")
  }

  if is_domain_name($gpgkey_url_server) == false {
    fail("yum::repo::gpgkey_url_server is not a domain name. It is <${gpgkey_url_server}>.")
  }

  # $baseurl is used in template and takes a form such as
  # http://yum.domain.tld/customrepo/5/8/dev/x86_64
  if $baseurl == '' {
    if $mirrorlist != '' {
      $baseurl_real = '' # lint:ignore:empty_string_assignment
    } elsif $username != '' and $password != '' {
      $baseurl_real = "${repo_server_protocol}://${username}:${password}@${repo_server}/${repo_server_basedir}/${name}/${_osmajor}/${_osminor}/${environment}/\$basearch"
    } else {
      $baseurl_real = "${repo_server_protocol}://${repo_server}/${repo_server_basedir}/${name}/${_osmajor}/${_osminor}/${environment}/\$basearch"
    }
  } else {
    $baseurl_real = $baseurl
  }

  # uppercase name of repo
  $upcase_name = upcase($name)

  # URL of gpgkey used in template and takes a form such as
  # http://yum.domain.tld/keys/RPM-GPG-KEY-CUSTOMREPO-5
  if $use_gpgkey_uri == true and $gpgkey == '' {
    $gpgkey_real = "${gpgkey_url_proto}://${gpgkey_url_server}/${gpgkey_url_path}/${gpgkey_file_prefix}-${upcase_name}-${_osmajor}"
  }
  else {
    $gpgkey_real = $gpgkey
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

  # Only need to deal with importing GPG keys, if we have gpgcheck enabled
  if ($ensure == 'present') and ($gpgcheck_string == '1') and ($use_gpgkey_uri == true) {
    yum::rpm_gpg_key { $upcase_name:
      gpgkey_url => $gpgkey_real,
      gpgkey     => "${gpgkey_local_path}/${gpgkey_file_prefix}-${upcase_name}-${_osmajor}",
      before     => File["${name}.repo"],
    }
  }
}
