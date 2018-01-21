# -*- mode: ruby -*-
# vi: set ft=ruby :
#
if not Vagrant.has_plugin?('vagrant-vbguest')
  abort <<-EOM

vagrant plugin vagrant-vbguest is required.
https://github.com/dotless-de/vagrant-vbguest
To install the plugin, please run, 'vagrant plugin install vagrant-vbguest'.

  EOM
end

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.synced_folder ".", "/vagrant", type: "virtualbox"

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "512"]
  end

  config.vm.define "yum-server", primary: true, autostart: true do |cfg|
    cfg.vm.box = "centos/7"
    cfg.vm.hostname = 'yum-server.example.com'
    cfg.vm.network :private_network, ip: '192.168.59.10'
    cfg.vm.provision :shell, :path => "vagrant/provision.sh"
    cfg.vm.provision :shell, :inline => "puppet apply /vagrant/examples/updatesd.pp"
    cfg.vm.provision :shell, :inline => "puppet apply /vagrant/examples/server.pp"
  end

  config.vm.define "el7-client", autostart: true do |cfg|
    cfg.vm.box = "centos/7"
    cfg.vm.hostname = 'el7-client.example.com'
    cfg.vm.network  :private_network, ip: "192.168.59.11"
    cfg.vm.provision :shell, :path => "vagrant/provision.sh"
    cfg.vm.provision :shell, :inline => "puppet apply /vagrant/examples/updatesd.pp"
    cfg.vm.provision :shell, :inline => "puppet apply /vagrant/examples/repo.pp"
  end

  config.vm.define "el6-client", autostart: false do |cfg|
    cfg.vm.box = "centos/6"
    cfg.vm.hostname = 'el6-client.example.com'
    cfg.vm.network  :private_network, ip: "192.168.59.12"
    cfg.vm.provision :shell, :path => "vagrant/provision.sh"
    cfg.vm.provision :shell, :inline => "puppet apply /vagrant/examples/updatesd.pp"
    cfg.vm.provision :shell, :inline => "puppet apply /vagrant/examples/repo.pp"
  end
end
