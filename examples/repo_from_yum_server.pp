include ::yum

yum::repo { 'test':
  description => 'Test yum-server serving up yum repos',
  baseurl     => ['http://yum-server/cowsay/\$releasever/'],
  enabled     => true,
  gpgcheck    => false,
}

package { 'cowsay':
  ensure  => 'installed',
  require => Yum::Repo['test'],
}

exec { 'verify_cowsay_comes_from_test':
  command => 'yum list | grep cowsay | awk \'{print $3}\' | grep ^@test$',
  path    => '/bin:/usr/bin:/sbin:/usr/sbin',
  require => Package['cowsay'],
}
