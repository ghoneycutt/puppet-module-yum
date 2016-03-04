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
  $baseurl              = 'UNSET',
  $enabled              = '1',
  $gpgcheck             = '1',
  $gpgkey               = 'UNSET',
  $use_gpgkey_uri       = true,
  $yum_repos_d_path     = 'UNSET',
  $gpgkey_local_path    = 'UNSET',
  $priority             = 'UNSET',
  $repo_server          = "yum.${::domain}",
  $repo_server_protocol = 'http',
  $repo_server_basedir  = '/',
  $repo_file_mode       = '0400',
  $yum_repos_d_path     = '/etc/yum.repos.d',
  $gpgkey_url_proto     = 'http',
  $gpgkey_url_server    = $repo_server,
  $gpgkey_url_path      = 'keys',
  $gpgkey_file_prefix   = 'RPM-GPG-KEY',
  $gpgkey_local_path    = '/etc/pki/rpm-gpg',
  $username             = undef,
  $password             = undef,
  $description          = undef,
  $environment          = $::environment,
) {

  validate_string($username)
  validate_string($password)

  if $description == undef {
    $description_real = $name
  } else {
    $description_real = $description
  }

  # $baseurl is used in template and takes a form such as
  # http://yum.domain.tld/customrepo/5/8/dev/x86_64
  if $baseurl == 'UNSET' {
    if $username != undef and $password != undef {
      $my_baseurl = "${repo_server_protocol}://${username}:${password}@${repo_server}/${repo_server_basedir}/${name}/${::lsbmajdistrelease}/${::lsbminordistrelease}/${environment}/\$basearch"
    } else {
      $my_baseurl = "${repo_server_protocol}://${repo_server}/${repo_server_basedir}/${name}/${::lsbmajdistrelease}/${::lsbminordistrelease}/${environment}/\$basearch"
    }
  } else {
    $my_baseurl = $baseurl
  }

  # uppercase name of repo
  $upcase_name = upcase($name)

  # URL of gpgkey used in template and takes a form such as
  # http://yum.domain.tld/keys/RPM-GPG-KEY-CUSTOMREPO-5
  if $gpgkey == 'UNSET' {
    if $use_gpgkey_uri == true {
      $my_gpgkey = "${gpgkey_url_proto}://${gpgkey_url_server}/${gpgkey_url_path}/${gpgkey_file_prefix}-${upcase_name}-${::lsbmajdistrelease}"
    } else {
      $my_gpgkey = $gpgkey
    }
  }

  # Where to place .repo files
  if $yum_repos_d_path == 'UNSET' {
    $my_yum_repos_d_path = $yum_repos_d_path
  } else {
    $my_yum_repos_d_path = $yum_repos_d_path
  }

  # repo file
  # ie: /etc/yum.repos.d/customrepo.repo
  file { "${name}.repo":
    ensure  => file,
    path    => "${my_yum_repos_d_path}/${name}.repo",
    owner   => 'root',
    group   => 'root',
    mode    => $repo_file_mode,
    content => template('yum/repo.erb'),
    notify  => Exec['clean_yum_cache'],
  }

  # Only need to deal with importing GPG keys, if we have gpgcheck enabled
  if ($gpgcheck == '1') and ($use_gpgkey_uri == true) {

    # Where to place GPG keys
    if $gpgkey_local_path == 'UNSET' {
      $my_gpgkey_local_path = $gpgkey_local_path
    } else {
      $my_gpgkey_local_path = $gpgkey_local_path
    }

    yum::rpm_gpg_key { $upcase_name:
      gpgkey_url => $my_gpgkey,
      gpgkey     => "${my_gpgkey_local_path}/${gpgkey_file_prefix}-${upcase_name}-${::lsbmajdistrelease}",
      before     => File["${name}.repo"],
    }
  }
}
