require 'spec_helper'
describe 'yum' do
  context 'with repos set to example hash when hiera merge is disabled' do
    let(:params) do
      {
        repos_hiera_merge: false,
        repos: {
          'example_plain' => {
            'gpgkey'   => ['http://yum.test.local/keys/RPM-GPG-KEY-EXAMPLE_PLAIN'],
            'baseurl'  => ['http://yum.test.local/customrepo/5/10/$basearch'],
          },
          'example_secure' => {
            'gpgkey'   => ['https://yum.test.local/keys/RPM-GPG-KEY-EXAMPLE_SECURE'],
            'baseurl'  => ['https://yum.test.local/customrepo/5/10/$basearch'],
            'username' => 'example',
            'password' => 'secret',
            'gpgcheck' => true,
          }
        }
      }
    end

    it { is_expected.to have_yum__repo_resource_count(2) }

    it do
      is_expected.to contain_yum__repo('example_plain').with(
        {
          'gpgkey' => ['http://yum.test.local/keys/RPM-GPG-KEY-EXAMPLE_PLAIN'],
          'baseurl'  => ['http://yum.test.local/customrepo/5/10/$basearch'],
        },
      )
    end

    it do
      is_expected.to contain_yum__repo('example_secure').with(
        {
          'gpgkey'   => ['https://yum.test.local/keys/RPM-GPG-KEY-EXAMPLE_SECURE'],
          'baseurl'  => ['https://yum.test.local/customrepo/5/10/$basearch'],
          'username' => 'example',
          'password' => 'secret',
          'gpgcheck' => true,
        },
      )
    end

    content_example_plain = <<-END.gsub(%r{^\s+\|}, '')
      |# This file is being maintained by Puppet.
      |# DO NOT EDIT
      |
      |[example_plain]
      |gpgkey=http://yum.test.local/keys/RPM-GPG-KEY-EXAMPLE_PLAIN
      |baseurl=http://yum.test.local/customrepo/5/10/$basearch
      |name=example_plain
      |enabled=1
      |gpgcheck=0
    END

    it do
      is_expected.to contain_file('example_plain.repo').with(
        {
          'ensure' => 'file',
          'path'    => '/etc/yum.repos.d/example_plain.repo',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0400',
          'content' => content_example_plain,
          'notify'  => 'Exec[clean_yum_cache]',
        },
      )
    end

    content_example_secure = <<-END.gsub(%r{^\s+\|}, '')
      |# This file is being maintained by Puppet.
      |# DO NOT EDIT
      |
      |[example_secure]
      |gpgkey=https://yum.test.local/keys/RPM-GPG-KEY-EXAMPLE_SECURE
      |baseurl=https://yum.test.local/customrepo/5/10/$basearch
      |name=example_secure
      |enabled=1
      |gpgcheck=1
      |password=secret
      |username=example
    END

    it do
      is_expected.to contain_file('example_secure.repo').with(
        {
          'ensure'   => 'file',
          'path'     => '/etc/yum.repos.d/example_secure.repo',
          'owner'    => 'root',
          'group'    => 'root',
          'content'  => content_example_secure,
          'notify'   => 'Exec[clean_yum_cache]',
        },
      )
    end
  end

  context 'with rpm_gpg_keys set to example hash when hiera merge is disabled' do
    let(:params) do
      {
        rpm_gpg_keys_hiera_merge: false,
        rpm_gpg_keys: {
          'example' => {
            'gpgkey'     => '/etc/pki/rpm-gpg/RPM-GPG-KEY-EXAMPLE',
            'gpgkey_url' => 'http://yum.domain.tld/keys/RPM-GPG-KEY-EXAMPLE',
          }
        }
      }
    end

    it { is_expected.to have_yum__rpm_gpg_key_resource_count(1) }

    it do
      is_expected.to contain_yum__rpm_gpg_key('example').with(
        {
          'gpgkey' => '/etc/pki/rpm-gpg/RPM-GPG-KEY-EXAMPLE',
          'gpgkey_url' => 'http://yum.domain.tld/keys/RPM-GPG-KEY-EXAMPLE',
        },
      )
    end

    it { is_expected.to contain_exec('remove_if_empty-/etc/pki/rpm-gpg/RPM-GPG-KEY-EXAMPLE') }
    it { is_expected.to contain_exec('yum_wget_gpgkey_for_example_repo') }
    it { is_expected.to contain_exec('yum_rpm_import_example_gpgkey') }
  end
end
