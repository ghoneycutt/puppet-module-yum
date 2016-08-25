require 'spec_helper'

describe 'yum::rpm_gpg_key' do
  mandatory_facts = {}
  mandatory_params = {
    :gpgkey_url => 'http://yum.domain.tld/keys/RPM-GPG-KEY-RSPEC-242',
    :gpgkey     => '/etc/pki/rpm-gpg/RPM-GPG-KEY-RSPEC-242',
  }
  let(:title) { 'spectest' }
  let(:facts) { mandatory_facts }
  let(:params) { {} }

  context 'with defaults for all parameters' do
    it 'should fail' do
      expect { should contain_class(subject) }.to raise_error(Puppet::Error, /(expects a value for parameter|Must pass)/)
    end
  end

  context 'with mandatory parameters set to valid values' do
    let(:params) { mandatory_params }

    it { should compile.with_all_deps }
    it { should have_common__remove_if_empty_resource_count(1) }
    it { should contain_common__remove_if_empty('/etc/pki/rpm-gpg/RPM-GPG-KEY-RSPEC-242') }
    it do
      should contain_exec('yum_wget_gpgkey_for_spectest_repo').with({
        'command' => 'wget http://yum.domain.tld/keys/RPM-GPG-KEY-RSPEC-242 -O /etc/pki/rpm-gpg/RPM-GPG-KEY-RSPEC-242',
        'creates' => '/etc/pki/rpm-gpg/RPM-GPG-KEY-RSPEC-242',
        'path'    => '/bin:/usr/bin:/sbin:/usr/sbin',
        'notify'  => 'Exec[yum_rpm_import_spectest_gpgkey]',
        'require' => 'Common::Remove_if_empty[/etc/pki/rpm-gpg/RPM-GPG-KEY-RSPEC-242]',
      })
    end
    it do
      should contain_exec('yum_rpm_import_spectest_gpgkey').with({
        'command'     => 'rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-RSPEC-242',
        'refreshonly' => 'true',
        'path'        => '/bin:/usr/bin:/sbin:/usr/sbin',
      })
    end
  end

  context 'with gpgkey_url set to valid string <http://yum.domain.tld/tests/RPM-GPG-KEY-RSPEC-242>' do
    let(:params) { mandatory_params.merge({ :gpgkey_url => 'http://yum.domain.tld/tests/RPM-GPG-KEY-RSPEC-242' }) }

    it { should contain_exec('yum_wget_gpgkey_for_spectest_repo').with_command('wget http://yum.domain.tld/tests/RPM-GPG-KEY-RSPEC-242 -O /etc/pki/rpm-gpg/RPM-GPG-KEY-RSPEC-242') }
  end

  context 'with gpgkey set to valid string </spec/tests/RPM-GPG-KEY-RSPEC-242>' do
    let(:params) { mandatory_params.merge({ :gpgkey => '/spec/tests/RPM-GPG-KEY-RSPEC-242' }) }

    it { should contain_common__remove_if_empty('/spec/tests/RPM-GPG-KEY-RSPEC-242') }
    it do
      should contain_exec('yum_wget_gpgkey_for_spectest_repo').with({
        'command' => 'wget http://yum.domain.tld/keys/RPM-GPG-KEY-RSPEC-242 -O /spec/tests/RPM-GPG-KEY-RSPEC-242',
        'creates' => '/spec/tests/RPM-GPG-KEY-RSPEC-242',
        'require' => 'Common::Remove_if_empty[/spec/tests/RPM-GPG-KEY-RSPEC-242]',
      })
    end
    it { should contain_exec('yum_rpm_import_spectest_gpgkey').with_command('rpm --import /spec/tests/RPM-GPG-KEY-RSPEC-242') }
  end

  context 'with wget_path set to valid string </test:/spec/test>' do
    let(:params) { mandatory_params.merge({ :wget_path => '/test:/spec/test' }) }

    it { should contain_exec('yum_wget_gpgkey_for_spectest_repo').with_path('/test:/spec/test') }
  end

  context 'with rpm_path set to valid string </test:/spec/test>' do
    let(:params) { mandatory_params.merge({ :rpm_path => '/test:/spec/test' }) }

    it { should contain_exec('yum_rpm_import_spectest_gpgkey').with_path('/test:/spec/test') }
  end
end
