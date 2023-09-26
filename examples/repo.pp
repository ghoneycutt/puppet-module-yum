include yum

yum::rpm_gpg_key { "RPM-GPG-KEY-EPEL-${facts['os']['release']['major']}":
  gpgkey_url => "http://yum-server/keys/RPM-GPG-KEY-EPEL-${facts['os']['release']['major']}",
  gpgkey     => "/etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-${facts['os']['release']['major']}",
  before     => Yum::Repo['epel'],
}

yum::repo { 'epel':
  description    => "Extra Packages for Enterprise Linux ${facts['os']['release']['major']} - \$basearch",
  metalink       => "https://mirrors.fedoraproject.org/metalink?repo=epel-${facts['os']['release']['major']}&arch=\$basearch",
  failovermethod => 'priority',
  enabled        => true,
  gpgcheck       => true,
  gpgkey         => ["file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-${facts['os']['release']['major']}"],
}

package { 'jq':
  ensure  => 'installed',
  require => Yum::Repo['epel'],
}

exec { 'verify_jq_comes_from_epel':
  command => 'yum list | grep jq | awk \'{print $3}\' | grep ^@epel$',
  path    => '/bin:/usr/bin:/sbin:/usr/sbin',
  require => Package['jq'],
}
