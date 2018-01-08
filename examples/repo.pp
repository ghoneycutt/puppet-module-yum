include ::yum

yum::rpm_gpg_key { 'RPM-GPG-KEY-EPEL-7':
  gpgkey_url => 'http://yum-server/keys/RPM-GPG-KEY-EPEL-7',
  gpgkey     => '/etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7',
  before     => Yum::Repo['epel'],
}

yum::repo { 'epel':
  description    => 'Extra Packages for Enterprise Linux 7 - $basearch',
  metalink       => 'https://mirrors.fedoraproject.org/metalink?repo=epel-7&arch=$basearch',
  failovermethod => 'priority',
  enabled        => true,
  gpgcheck       => true,
  gpgkey         => ['file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7'],
}

package { 'jq':
  ensure  => 'installed',
  require => Yum::Repo['epel'],
}
