# @summary Downloads a public gpg key for a yum repo and installs the key
#   Uses wget and rpimport commands
#
# @param gpgkey_url
#   Specify the source URL for the GPG key to download from.
#
# @param gpgkey
#   Specify the fully qualified destination file name for the GPG key to save to.
#
# @param wget_path
#   Specify the path parameter to be used for the wget command.
#
# @param rpm_path
#   Specify the path parameter to be used for the rpm command.
#
define yum::rpm_gpg_key (
  Stdlib::Httpurl $gpgkey_url,
  Stdlib::Absolutepath $gpgkey,
  String $wget_path = '/bin:/usr/bin:/sbin:/usr/sbin',
  String $rpm_path  = '/bin:/usr/bin:/sbin:/usr/sbin',
) {

  # wget -O in the yum_wget_gpgkey_for_${name}_repo exec will leave an empty
  # file if it does not download one, which causes problems. This exec will
  # remove the key if it exists, but is empty.
  exec { "remove_if_empty-${gpgkey}":
    command => "rm -f ${gpgkey}",
    unless  => "test -f ${gpgkey}; if [ $? == '0' ]; then test -s ${gpgkey}; fi",
    path    => '/bin:/usr/bin:/sbin:/usr/sbin',
  }

  # ie: wget http://yum.domain.tld/keys/RPM-GPG-KEY-CUSTOMREPO-5-8 -O /etc/pki/rpm-gpg/RPM-GPG-KEY-CUSTOMREPO-5-8
  exec { "yum_wget_gpgkey_for_${name}_repo":
    command => "wget ${gpgkey_url} -O ${gpgkey}",
    creates => $gpgkey,
    path    => $wget_path,
    notify  => Exec["yum_rpm_import_${name}_gpgkey"],
    require => Exec["remove_if_empty-${gpgkey}"],
  }

  # import GPG key
  exec { "yum_rpm_import_${name}_gpgkey":
    command     => "rpm --import ${gpgkey}",
    refreshonly => true,
    path        => $rpm_path,
  }
}
