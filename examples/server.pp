class { '::yum::server':
  http_listen_ip => $facts['networking']['interfaces']['eth1']['ip'],
}

yum::rpm_gpg_key { 'RPM-GPG-KEY-EPEL-6':
  gpgkey_url => 'http://mirrors.syringanetworks.net/fedora-epel/RPM-GPG-KEY-EPEL-6',
  gpgkey     => '/opt/repos/keys/RPM-GPG-KEY-EPEL-6',
}

yum::rpm_gpg_key { 'RPM-GPG-KEY-EPEL-7':
  gpgkey_url => 'http://mirrors.syringanetworks.net/fedora-epel/RPM-GPG-KEY-EPEL-7',
  gpgkey     => '/opt/repos/keys/RPM-GPG-KEY-EPEL-7',
}
