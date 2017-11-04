# == Define: yum::repo
#
# Manage individual yum repo files in /etc/yum.repos.d
#
# This was used in favor of the yumrepo type, which cannot
# manage files in that directory.
#
# example
#  yum::repo { 'redhat-base':
#    gpgcheck => '1',
#  }
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
