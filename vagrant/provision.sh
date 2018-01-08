#!/bin/bash

# using this instead of "rpm -Uvh" to resolve dependencies
function rpm_install() {
    package=$(echo $1 | awk -F "/" '{print $NF}')
    wget --quiet $1
    yum install -y ./$package
    rm -f $package
}

release=$(awk -F \: '{print $5}' /etc/system-release-cpe)

rpm --import http://yum.puppetlabs.com/RPM-GPG-KEY-puppet
rpm --import http://vault.centos.org/RPM-GPG-KEY-CentOS-${release}

yum install -y wget

# install and configure puppet
rpm -qa | grep -q puppet
if [ $? -ne 0 ]
then

    rpm_install https://yum.puppetlabs.com/puppetlabs-release-pc1-el-${release}.noarch.rpm
    yum -y install puppet-agent
    ln -s /opt/puppetlabs/puppet/bin/puppet /usr/bin/puppet

    # suppress default warnings for deprecation
    cat > /etc/puppetlabs/puppet/hiera.yaml <<EOF
---
version: 5
hierarchy:
  - name: Common
    path: common.yaml
defaults:
  data_hash: yaml_data
  datadir: hieradata
EOF

fi

# use local module
puppet resource file /etc/puppetlabs/code/environments/production/modules/yum ensure=link target=/vagrant

# setup module dependencies
puppet module install puppetlabs/stdlib --version 4.24.0
puppet module install puppetlabs/apache --version 2.3.0
puppet module install thrnio/ip --version 1.0.0

fqdn=$(hostname -f)
if [[ $fqdn == 'yum-server.example.com' ]]; then
  # install EPEL repos for required dependencies
  rpm --import http://download-ib01.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-${release}
  rpm_install https://dl.fedoraproject.org/pub/epel/epel-release-latest-${release}.noarch.rpm
fi

# setup /etc/hosts
cat > /etc/hosts <<EOF
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

192.168.59.10 yum-server yum-server.example.com
192.168.59.11 el7-client el7-client.example.com
192.168.59.12 el6-client el6-client.example.com
EOF
