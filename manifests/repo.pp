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
  $baseurl              = undef,
  $enabled              = '1',
  $gpgcheck             = '1',
  $gpgkey               = undef,
  $use_gpgkey_uri       = true,
  $priority             = undef,
  $repo_server          = "yum.${::domain}",
  $repo_server_protocol = 'http',
  $repo_server_basedir  = '/',
  $repo_file_mode       = '0400',
  $yum_repos_d_path     = '/etc/yum.repos.d',
  $gpgkey_url_proto     = 'http',
  $gpgkey_url_server    = undef,
  $gpgkey_url_path      = 'keys',
  $gpgkey_file_prefix   = 'RPM-GPG-KEY',
  $gpgkey_local_path    = '/etc/pki/rpm-gpg',
  $username             = undef,
  $password             = undef,
  $description          = undef,
  $environment          = $::environment,
  $mirrorlist           = undef,
  $failovermethod       = undef,
) {

  validate_string($username)
  validate_string($password)
  validate_string(
    $mirrorlist,
    $failovermethod,
  )

  if is_domain_name($repo_server) == false or is_string($repo_server) == false {
    fail("yum::repo::repo_server is not a domain name. It is <${repo_server}>.")
  }

  if is_string($gpgkey_url_server) == true and is_domain_name($gpgkey_url_server) == true {
    $gpgkey_url_server_real = $gpgkey_url_server
  }
  elsif $gpgkey_url_server == undef {
    $gpgkey_url_server_real = $repo_server
  }
  else {
    fail("yum::repo::gpgkey_url_server is not a domain name. It is <${gpgkey_url_server}>.")
  }

  if $description == undef {
    $description_real = $name
  } else {
    $description_real = $description
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
    $gpgkey_real = "${gpgkey_url_proto}://${gpgkey_url_server_real}/${gpgkey_url_path}/${gpgkey_file_prefix}-${upcase_name}-${::lsbmajdistrelease}"
  }
  else {
    $gpgkey_real = $gpgkey
  }

  # repo file
  # ie: /etc/yum.repos.d/customrepo.repo
  file { "${name}.repo":
    ensure  => file,
    path    => "${yum_repos_d_path}/${name}.repo",
    owner   => 'root',
    group   => 'root',
    mode    => $repo_file_mode,
    content => template('yum/repo.erb'),
    notify  => Exec['clean_yum_cache'],
  }

  # Only need to deal with importing GPG keys, if we have gpgcheck enabled
  if ($gpgcheck == '1') and ($use_gpgkey_uri == true) {

    yum::rpm_gpg_key { $upcase_name:
      gpgkey_url => $gpgkey_real,
      gpgkey     => "${gpgkey_local_path}/${gpgkey_file_prefix}-${upcase_name}-${::lsbmajdistrelease}",
      before     => File["${name}.repo"],
    }
  }
}
