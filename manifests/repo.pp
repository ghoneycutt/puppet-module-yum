# @summary Manage individual yum repo files in /etc/yum.repos.d
#   This was used in favor of the yumrepo type, which cannot
#   manage files in that directory.
#
# @example Using the define.
#   yum::repo { 'redhat-base':
#     gpgcheck => '1',
#   }
#
# @param ensure
#   Set to "present" or "absent". When absent, removes the repository
#   configuration file from the node modeled on the behavior of the
#   File type's ensure parameter.
#
# @param baseurl
#   Trigger to set the baseurl parameter of the repository configuration.
#   Takes a form such as 'http://yum.domain.tld/customrepo/5/8/dev/x86_64'.
#   If $baseurl and $mirrorlist are both unset, it baseurl will become:
#   $repo_server_protocol://$username:$password@$repo_server/$repo_server_basedir/$name/$::lsbmajdistrelease/$::lsbminordistrelease/$environment/$basearch.
#   Passing $username and $password is optional.
#   If only $mirrorlist is set, baseurl will not be used in the repository
#   configuration.
#
# @param enabled
#   Set the enabled parameter of the repository configuration.
#
# @param gpgcheck
#   Set the gpgcheck parameter of a repository configuration.
#
# @param gpgkey
#   Set the gpgkey parameter of the repository configuration. Will only be used
#   when $use_gpgkey_uri is set to true.
#
# @param use_gpgkey_uri
#   Trigger to activate support for using GPG keys. If set to true the module
#   will download GPG keys and add the gpgkey parameter to the repository
#   configuration.
#
# @param priority
#   Trigger to set the priority parameter of the repository configuration.
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
# @param username
#   Specify the optional username part of the default URL for baseurl
#   (see $baseurl). Specifing $baseurl or $mirrlost will override this parameter.
#
# @param password
#   Specify the optional password part of the default URL for baseurl
#   (see $baseurl). Specifing $baseurl or $mirrlost will override this parameter.
#
# @param description
#   Set the name parameter of the repository configuration. Defaults to the name
#   of the defined type.
#
# @param environment
#   Specify the environment part of the default value for baseurl (see $baseurl).
#   Specifying $baseurl or $mirrorlist will override this parameter.
#
# @param mirrorlist
#   Trigger to set the mirrorlist parameter of the repository configuration.
#
# @param failovermethod
#   Trigger to set the failovermethod parameter of the repository configuration.
#
# @param sslcacert
#   If set, will ensure the line sslcacert is present in the repository
#   configuration with the specified value. This is useful when using your own
#   CA bundle.
#
define yum::repo (
  Enum['absent', 'present'] $ensure         = 'present',
  Optional[String] $baseurl                 = undef,
  Boolean $enabled                          = true,
  Boolean $gpgcheck                         = true,
  Optional[String] $gpgkey                  = undef,
  Boolean $use_gpgkey_uri                   = true,
  Optional[Integer] $priority               = undef,
  String $repo_server                       = "yum.${::domain}",
  String $repo_server_protocol              = 'http',
  String $repo_server_basedir               = '/',
  Pattern[/^[0-7]{4}$/] $repo_file_mode     = '0400',
  Stdlib::Absolutepath $yum_repos_d_path    = '/etc/yum.repos.d',
  String $gpgkey_url_proto                  = 'http',
  String $gpgkey_url_server                 = "yum.${::domain}",
  String $gpgkey_url_path                   = 'keys',
  String $gpgkey_file_prefix                = 'RPM-GPG-KEY',
  Stdlib::Absolutepath $gpgkey_local_path   = '/etc/pki/rpm-gpg',
  Optional[String] $username                = undef,
  Optional[String] $password                = undef,
  Optional[String] $description             = $name,
  String $environment                       = $::environment,
  Optional[String] $mirrorlist              = undef,
  Optional[String] $failovermethod          = undef,
  Optional[Stdlib::Absolutepath] $sslcacert = undef,
) {

  $enabled_strg = bool2str($enabled, '1', '0')
  $gpgcheck_strg = bool2str($gpgcheck, '1', '0')

  if is_domain_name($repo_server) == false {
    fail("yum::repo::repo_server is not a domain name. It is <${repo_server}>.")
  }

  if is_domain_name($gpgkey_url_server) == false {
    fail("yum::repo::gpgkey_url_server is not a domain name. It is <${gpgkey_url_server}>.")
  }

  # $baseurl is used in template and takes a form such as
  # http://yum.domain.tld/customrepo/5/8/dev/x86_64
  if $baseurl == undef {
    if $mirrorlist != undef {
      $baseurl_real = undef
    } elsif $username != undef and $password != undef {
      $baseurl_real = "${repo_server_protocol}://${username}:${password}@${repo_server}/${repo_server_basedir}/${name}/${::lsbmajdistrelease}/${::lsbminordistrelease}/${environment}/\$basearch"
    } else {
      $baseurl_real = "${repo_server_protocol}://${repo_server}/${repo_server_basedir}/${name}/${::lsbmajdistrelease}/${::lsbminordistrelease}/${environment}/\$basearch"
    }
  } else {
    $baseurl_real = $baseurl
  }

  # uppercase name of repo
  $upcase_name = upcase($name)

  # URL of gpgkey used in template and takes a form such as
  # http://yum.domain.tld/keys/RPM-GPG-KEY-CUSTOMREPO-5
  if $use_gpgkey_uri == true and $gpgkey == undef {
    $gpgkey_real = "${gpgkey_url_proto}://${gpgkey_url_server}/${gpgkey_url_path}/${gpgkey_file_prefix}-${upcase_name}-${::lsbmajdistrelease}"
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
  if ($ensure == 'present') and ($gpgcheck_strg == '1') and ($use_gpgkey_uri == true) {
    yum::rpm_gpg_key { $upcase_name:
      gpgkey_url => $gpgkey_real,
      gpgkey     => "${gpgkey_local_path}/${gpgkey_file_prefix}-${upcase_name}-${::lsbmajdistrelease}",
      before     => File["${name}.repo"],
    }
  }
}
