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
      expect { should contain_class(subject) }.to raise_error(Puppet::Error, /expects a value for parameter/) # Puppet 4 & 5
    end
  end

  context 'with mandatory parameters set to valid values' do
    let(:params) { mandatory_params }

    it { should compile.with_all_deps }
    it do
      should contain_exec('remove_if_empty-/etc/pki/rpm-gpg/RPM-GPG-KEY-RSPEC-242').with({
        'command'     => 'rm -f /etc/pki/rpm-gpg/RPM-GPG-KEY-RSPEC-242',
        'unless'      => "test -f /etc/pki/rpm-gpg/RPM-GPG-KEY-RSPEC-242; if [ $? == '0' ]; then test -s /etc/pki/rpm-gpg/RPM-GPG-KEY-RSPEC-242; fi",
        'path'        => '/bin:/usr/bin:/sbin:/usr/sbin',
      })
    end
    it do
      should contain_exec('yum_wget_gpgkey_for_spectest_repo').with({
        'command' => 'wget http://yum.domain.tld/keys/RPM-GPG-KEY-RSPEC-242 -O /etc/pki/rpm-gpg/RPM-GPG-KEY-RSPEC-242',
        'creates' => '/etc/pki/rpm-gpg/RPM-GPG-KEY-RSPEC-242',
        'path'    => '/bin:/usr/bin:/sbin:/usr/sbin',
        'notify'  => 'Exec[yum_rpm_import_spectest_gpgkey]',
        'require' => 'Exec[remove_if_empty-/etc/pki/rpm-gpg/RPM-GPG-KEY-RSPEC-242]',
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

    it do
      should contain_exec('remove_if_empty-/spec/tests/RPM-GPG-KEY-RSPEC-242').with({
        'command'     => 'rm -f /spec/tests/RPM-GPG-KEY-RSPEC-242',
        'unless'      => "test -f /spec/tests/RPM-GPG-KEY-RSPEC-242; if [ $? == '0' ]; then test -s /spec/tests/RPM-GPG-KEY-RSPEC-242; fi",
      })
    end
    it do
      should contain_exec('yum_wget_gpgkey_for_spectest_repo').with({
        'command' => 'wget http://yum.domain.tld/keys/RPM-GPG-KEY-RSPEC-242 -O /spec/tests/RPM-GPG-KEY-RSPEC-242',
        'creates' => '/spec/tests/RPM-GPG-KEY-RSPEC-242',
        'require' => 'Exec[remove_if_empty-/spec/tests/RPM-GPG-KEY-RSPEC-242]',
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

  describe 'variable type and content validations' do
    let(:mandatory_params) { mandatory_params }

    validations = {
      'Stdlib::Absolutepath' => {
        :name    => %w(gpgkey),
        :valid   => ['/absolute/filepath', '/absolute/directory/'],
        :invalid => ['../invalid', %w(array), { 'ha' => 'sh' }, 3, 2.42, false, nil],
        :message => 'expects a (match for|match for Stdlib::Absolutepath =|Stdlib::Absolutepath =) Variant\[Stdlib::Windowspath.*Stdlib::Unixpath', # Puppet (4.x|5.0 & 5.1|5.x)
      },
      'Stdlib::Httpurl' => {
        :name    => %w(gpgkey_url),
        :valid   => %w(http://plain.test https://secure.test https://port.test:242),
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, 3, 2.42, false, nil],
        :message => 'expects a match for Stdlib::HTTPUrl', # Puppet 4 & 5
      },
      'string' => {
        :name    => %w(rpm_path wget_path),
        :valid   => ['string'],
        :invalid => [%w(array), { 'ha' => 'sh' }, 3, 2.42, true],
        :message => 'expects a String', # Puppet 4 & 5
      },
    }

    validations.sort.each do |type, var|
      var[:name].each do |var_name|
        var[:params] = {} if var[:params].nil?
        var[:valid].each do |valid|
          context "when #{var_name} (#{type}) is set to valid #{valid} (as #{valid.class})" do
            let(:params) { [mandatory_params, var[:params], { :"#{var_name}" => valid, }].reduce(:merge) }
            it { should compile }
          end
        end

        var[:invalid].each do |invalid|
          context "when #{var_name} (#{type}) is set to invalid #{invalid} (as #{invalid.class})" do
            let(:params) { [mandatory_params, var[:params], { :"#{var_name}" => invalid, }].reduce(:merge) }
            it 'should fail' do
              expect { should contain_class(subject) }.to raise_error(Puppet::Error, /#{var[:message]}/)
            end
          end
        end
      end # var[:name].each
    end # validations.sort.each
  end # describe 'variable type and content validations'
end
