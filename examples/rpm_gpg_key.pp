include ::yum

yum::rpm_gpg_key { 'RPM-GPG-KEY-puppet':
  gpgkey_url => 'http://yum.puppetlabs.com/RPM-GPG-KEY-puppet',
  gpgkey     => '/etc/pki/rpm-gpg/RPM-GPG-KEY-puppet',
}
