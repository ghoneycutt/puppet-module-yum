require 'spec_helper_acceptance'

describe 'yum::server class', if: RSpec.configuration.yum_full do
  server = only_host_with_role(hosts, 'server')
  client = only_host_with_role(hosts, 'client')
  context 'yum::server' do
    it 'should work with no errors' do
      pp = <<-EOS
      include ::yum::server
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(server, pp, :catch_failures => true)
      apply_manifest_on(server, pp, :catch_changes  => true)
    end

    it 'should create repo' do
      on server, 'mkdir -p /opt/repos/cowsay/7'
      on server, 'wget https://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/c/cowsay-3.04-4.el7.noarch.rpm -O /opt/repos/cowsay/7/cowsay-3.04-4.el7.noarch.rpm'
      on server, 'cd /opt/repos/cowsay/7 && createrepo -v .'
    end
  end
  context 'yum::repo' do
    it 'sould work with no errors' do
      pp = <<-EOS
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
      EOS
      apply_manifest_on(client, pp, :catch_failures => true)
      apply_manifest_on(client, pp, :catch_changes  => true)
    end

    describe yumrepo('test'), :node => client  do
      it { is_expected.to exist }
      it { is_expected.to be_enabled }
    end
    describe package('cowsay'), :node => client do
      it { is_expected.to be_installed }
    end
    it 'should have installed cowsay from test repo' do
      on client, 'yum list | grep cowsay' do
        repo = stdout.split()[2]
        expect(repo).to eq('@test')
      end
    end
  end
end
