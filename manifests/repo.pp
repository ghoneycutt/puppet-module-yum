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
  $enabled              = true,
  $gpgcheck             = true,
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
  $environment          = "${::environment}", # lint:ignore:only_variable_string # stringification needed for spec testing on Puppet 3.8 & 4.3.0
  $mirrorlist           = undef,
  $failovermethod       = undef,
) {

  validate_absolute_path(
    $gpgkey_local_path,
    $yum_repos_d_path,
  )

  validate_string(
    $baseurl,
    $environment,
    $failovermethod,
    $gpgkey_file_prefix,
    $gpgkey_url_path,
    $gpgkey_url_proto,
    $mirrorlist,
    $password,
    $repo_server_basedir,
    $repo_server_protocol,
    $username,
  )

  validate_re("${repo_file_mode}", '^[0-7]{4}$', # lint:ignore:only_variable_string
    "yum::repo::repo_file_mode is not a file mode in octal notation. It is <${repo_file_mode}>.")

  case type3x($use_gpgkey_uri) {
    'boolean':           { $use_gpgkey_uri_bool = $use_gpgkey_uri }
    'string','integer':  { $use_gpgkey_uri_bool = str2bool("${use_gpgkey_uri}") } # lint:ignore:only_variable_string
    default:             { fail("yum::repo::enabled is not a boolean nor a stringified boolean. It is <${use_gpgkey_uri}>.") }
  }

  case type3x($enabled) {
    'boolean':           { $enabled_strg = bool2str($enabled, '1', '0') }
    'string','integer':  { $enabled_strg = bool2str(str2bool("${enabled}"), '1', '0') } # lint:ignore:only_variable_string
    default:             { fail("yum::repo::enabled is not a boolean nor a stringified boolean. It is <${enabled}>.") }
  }

  case type3x($gpgcheck) {
    'boolean':           { $gpgcheck_strg = bool2str($gpgcheck, '1', '0') }
    'string','integer':  { $gpgcheck_strg = bool2str(str2bool("${gpgcheck}"), '1', '0') } # lint:ignore:only_variable_string
    default:             { fail("yum::repo::gpgcheck is not a boolean nor a stringified boolean. It is <${gpgcheck}>.") }
  }

  if $priority != undef {
    case type3x($priority) {
      'integer': { $priority_int = $priority }
      'string':  { $priority_int = floor($priority) }
      default:   { fail("yum::repo::priority is not an integer nor stringified integer. It is <${priority}>.")}
    }
  }

  if is_string($repo_server) == false or is_domain_name($repo_server) == false {
    fail("yum::repo::repo_server is not a domain name. It is <${repo_server}>.")
  }

  if $gpgkey_url_server == undef {
    $gpgkey_url_server_real = $repo_server
  }
  elsif is_string($gpgkey_url_server) == true and is_domain_name($gpgkey_url_server) == true {
    $gpgkey_url_server_real = $gpgkey_url_server
  }
  else {
    fail("yum::repo::gpgkey_url_server is not a domain name. It is <${gpgkey_url_server}>.")
  }

  if $description == undef {
    $description_real = $name
  }
  elsif type3x($description) == 'string' {
    $description_real = $description
  }
  else {
    fail("yum::repo::description is not a string. It is <${description}>.")
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
  if $use_gpgkey_uri_bool == true and $gpgkey == undef {
    $gpgkey_real = "${gpgkey_url_proto}://${gpgkey_url_server_real}/${gpgkey_url_path}/${gpgkey_file_prefix}-${upcase_name}-${::lsbmajdistrelease}"
  }
  elsif type3x($gpgkey) == 'string' {
    $gpgkey_real = $gpgkey
  }
  else {
    fail("yum::repo::gpgkey is not a string. It is <${gpgkey}>.")
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
  if ($gpgcheck_strg == '1') and ($use_gpgkey_uri_bool == true) {

    yum::rpm_gpg_key { $upcase_name:
      gpgkey_url => $gpgkey_real,
      gpgkey     => "${gpgkey_local_path}/${gpgkey_file_prefix}-${upcase_name}-${::lsbmajdistrelease}",
      before     => File["${name}.repo"],
    }
  }
}
