# == Define: yum::rpm_gpg_key
#
# Downloads a public gpg key for a yum repo and installs the key
#
# Uses wget and rpimport commands
#
define yum::rpm_gpg_key (
  String $gpgkey_url,
  String $gpgkey,
  String $wget_path = '/bin:/usr/bin:/sbin:/usr/sbin',
  String $rpm_path  = '/bin:/usr/bin:/sbin:/usr/sbin',
) {

  # wget -O in the yum_wget_gpgkey_for_${name}_repo exec will leave an empty
  # file if it does not download one, which causes problems. This exec will
  # remove the key if it exists, but is empty.
  common::remove_if_empty { $gpgkey: }

  # ie: wget http://yum.domain.tld/keys/RPM-GPG-KEY-CUSTOMREPO-5-8 -O /etc/pki/rpm-gpg/RPM-GPG-KEY-CUSTOMREPO-5-8
  exec { "yum_wget_gpgkey_for_${name}_repo":
    command => "wget ${gpgkey_url} -O ${gpgkey}",
    creates => $gpgkey,
    path    => $wget_path,
    notify  => Exec["yum_rpm_import_${name}_gpgkey"],
    require => Common::Remove_if_empty[$gpgkey],
  }

  # import GPG key
  exec { "yum_rpm_import_${name}_gpgkey":
    command     => "rpm --import ${gpgkey}",
    refreshonly => true,
    path        => $rpm_path,
  }
}
