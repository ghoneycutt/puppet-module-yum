require 'spec_helper'

describe 'yum::repo' do
  mandatory_facts = {
    :domain              => 'test.local',
    :lsbmajdistrelease   => '5',
    :lsbminordistrelease => '10',
  }
  mandatory_params = {
    :gpgkey_url_server => 'yum.test.local', # workaround https://github.com/ghoneycutt/puppet-module-yum/issues/6
  }
  let(:title) { 'rspec' }
  let(:facts) { mandatory_facts }
  let(:params) { mandatory_params }
  let(:pre_condition) do
    'exec { clean_yum_cache:
       command => "yum clean all",
       refreshonly => true,
       path        => "/bin:/usr/bin:/sbin:/usr/sbin",
    }'
  end
  context 'with defaults for all parameters' do
    it { should compile.with_all_deps }

    content = <<-END.gsub(/^\s+\|/, '')
      |# This file is being maintained by Puppet.
      |# DO NOT EDIT
      |
      |[rspec]
      |name=rspec
      |baseurl=http://yum.test.local///rspec/5/10/rp_env/$basearch
      |enabled=1
      |gpgcheck=1
      |gpgkey=http://yum.test.local/keys/RPM-GPG-KEY-RSPEC-5
      |
    END

    it do
      should contain_file('rspec.repo').with({
        'ensure'  => 'file',
        'path'    => '/etc/yum.repos.d/rspec.repo',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0400',
        'content' => content,
        'notify'  => 'Exec[clean_yum_cache]',
      })
    end

    it { should have_yum__rpm_gpg_key_resource_count(1) }
    it do
      should contain_yum__rpm_gpg_key('RSPEC').with({
        'gpgkey_url' => 'http://yum.test.local/keys/RPM-GPG-KEY-RSPEC-5',
        'gpgkey'     => '/etc/pki/rpm-gpg/RPM-GPG-KEY-RSPEC-5',
        'before'     => 'File[rspec.repo]',
      })
    end
  end

  context 'with baseurl set to valid string <http://yum.domain.tld/customrepo/5/8/dev/x86_64>' do
    let(:params) { mandatory_params.merge({ :baseurl => 'http://yum.domain.tld/customrepo/5/8/dev/x86_64' }) }

    it { should contain_file('rspec.repo').with_content(%r{\[rspec\][\s\S]*baseurl=http://yum.domain.tld/customrepo/5/8/dev/x86_64$}) }
  end

  context 'with enabled set to valid string <0>' do
    let(:params) { mandatory_params.merge({ :enabled => '0' }) }

    it { should contain_file('rspec.repo').with_content(/\[rspec\][\s\S]*enabled=0$/) }
  end

  context 'with gpgcheck set to valid string <0>' do
    let(:params) { mandatory_params.merge({ :gpgcheck => '0' }) }

    it { should have_yum__rpm_gpg_key_resource_count(0) }
    it { should contain_file('rspec.repo').with_content(/\[rspec\][\s\S]*gpgcheck=0$/) }
  end

# /!\ my_gpgkey is not defined when gpgkey is != UNSET
=begin
  context 'with gpgkey set to valid string <http://yum.domain.tld/keys/RPM-GPG-KEY-CUSTOMREPO-5>' do
    let(:params) { mandatory_params.merge({ :gpgkey => 'http://yum.domain.tld/keys/RPM-GPG-KEY-CUSTOMREPO-5' }) }

    it { should have_yum__rpm_gpg_key_resource_count(1) }
    it do
      should contain_yum__rpm_gpg_key('RSPEC').with({
        'gpgkey_url' => 'http://yum.domain.tld/keys/RPM-GPG-KEY-CUSTOMREPO-5',
      })
    end
    it { should contain_file('rspec.repo').with_content(%r{\[rspec\][\s\S]*gpgkey=http://yum.domain.tld/keys/RPM-GPG-KEY-CUSTOMREPO-5$}) }
  end
=end

  context 'with use_gpgkey_uri set to valid bool <false>' do
    let(:params) { mandatory_params.merge({ :use_gpgkey_uri => false }) }

    it { should have_yum__rpm_gpg_key_resource_count(0) }
    it { should contain_file('rspec.repo').without_content(/gpgkey=/) }
  end

  context 'with priority set to valid string <242>' do
    let(:params) { mandatory_params.merge({ :priority => '242' }) }

    it { should contain_file('rspec.repo').with_content(/\[rspec\][\s\S]*priority=242$/) }
  end

  context 'with repo_server set to valid string <rspec.test.local>' do
    let(:params) { mandatory_params.merge({ :repo_server => 'rspec.test.local' }) }

    it { should contain_file('rspec.repo').with_content(%r{\[rspec\][\s\S]*baseurl=http://rspec.test.local///rspec/5/10/rp_env/\$basearch$}) }
  end

  context 'with repo_server_protocol set to valid string <https>' do
    let(:params) { mandatory_params.merge({ :repo_server_protocol => 'https' }) }

    it { should contain_file('rspec.repo').with_content(%r{\[rspec\][\s\S]*baseurl=https://yum.test.local///rspec/5/10/rp_env/\$basearch$}) }
  end

  # /!\ default result with three backslashes looks suspicious
  context 'with repo_server_basedir set to valid string </rspec>' do
    let(:params) { mandatory_params.merge({ :repo_server_basedir => '/rspec' }) }

    it { should contain_file('rspec.repo').with_content(%r{\[rspec\][\s\S]*baseurl=http://yum.test.local//rspec/rspec/5/10/rp_env/\$basearch$}) }
  end

  context 'with repo_file_mode set to valid string <0242>' do
    let(:params) { mandatory_params.merge({ :repo_file_mode => '0242' }) }

    it { should contain_file('rspec.repo').with_mode('0242') }
  end

  context 'with yum_repos_d_path set to valid string </rspec/test>' do
    let(:params) { mandatory_params.merge({ :yum_repos_d_path => '/rspec/test' }) }

    it { should contain_file('rspec.repo').with_path('/rspec/test/rspec.repo') }
  end

  context 'with gpgkey_url_proto set to valid string <https>' do
    let(:params) { mandatory_params.merge({ :gpgkey_url_proto => 'https' }) }

    it do
      should contain_yum__rpm_gpg_key('RSPEC').with({
        'gpgkey_url' => 'https://yum.test.local/keys/RPM-GPG-KEY-RSPEC-5',
      })
    end
    it { should contain_file('rspec.repo').with_content(%r{\[rspec\][\s\S]*gpgkey=https://yum.test.local/keys/RPM-GPG-KEY-RSPEC-5$}) }
  end

  context 'with gpgkey_url_server set to valid string <rspec.test.local>' do
    let(:params) { { :gpgkey_url_server => 'rspec.test.local' } }

    it do
      should contain_yum__rpm_gpg_key('RSPEC').with({
        'gpgkey_url' => 'http://rspec.test.local/keys/RPM-GPG-KEY-RSPEC-5',
      })
    end
    it { should contain_file('rspec.repo').with_content(%r{\[rspec\][\s\S]*gpgkey=http://rspec.test.local/keys/RPM-GPG-KEY-RSPEC-5$}) }
  end

  context 'with gpgkey_url_path set to valid string <rspec.test.local>' do
    let(:params) { mandatory_params.merge({ :gpgkey_url_path => 'tests' }) }

    it do
      should contain_yum__rpm_gpg_key('RSPEC').with({
        'gpgkey_url' => 'http://yum.test.local/tests/RPM-GPG-KEY-RSPEC-5',
      })
    end
    it { should contain_file('rspec.repo').with_content(%r{\[rspec\][\s\S]*gpgkey=http://yum.test.local/tests/RPM-GPG-KEY-RSPEC-5$}) }
  end

  context 'with gpgkey_file_prefix set to valid string <rspec.test.local>' do
    let(:params) { mandatory_params.merge({ :gpgkey_file_prefix => 'RSPEC-GPG-KEY' }) }

    it do
      should contain_yum__rpm_gpg_key('RSPEC').with({
        'gpgkey_url' => 'http://yum.test.local/keys/RSPEC-GPG-KEY-RSPEC-5',
      })
    end
    it { should contain_file('rspec.repo').with_content(%r{\[rspec\][\s\S]*gpgkey=http://yum.test.local/keys/RSPEC-GPG-KEY-RSPEC-5$}) }
  end

  context 'with gpgkey_local_path set to valid string </rspec/test>' do
    let(:params) { mandatory_params.merge({ :gpgkey_local_path => '/rspec/test' }) }

    it do
      should contain_yum__rpm_gpg_key('RSPEC').with({
        'gpgkey' => '/rspec/test/RPM-GPG-KEY-RSPEC-5',
      })
    end
  end

  context 'with username set to valid string <rspecer>' do
    let(:params) { mandatory_params.merge({ :username => 'rspecer' }) }

    it { should contain_file('rspec.repo').with_content(%r{\[rspec\][\s\S]*baseurl=http://yum.test.local///rspec/5/10/rp_env/\$basearch$}) }
  end

  context 'with password set to valid string <secret>' do
    let(:params) { mandatory_params.merge({ :password => 'secret' }) }

    it { should contain_file('rspec.repo').with_content(%r{\[rspec\][\s\S]*baseurl=http://yum.test.local///rspec/5/10/rp_env/\$basearch$}) }
  end

  context 'with username and password set to valid strings <rspecer> and <secret>' do
    let(:params) { mandatory_params.merge({ :username => 'rspecer', :password => 'secret' }) }

    it { should contain_file('rspec.repo').with_content(%r{\[rspec\][\s\S]*baseurl=http://rspecer:secret@yum.test.local///rspec/5/10/rp_env/\$basearch$}) }
  end

  context 'with description set to valid string <info>' do
    let(:params) { mandatory_params.merge({ :description => 'info' }) }

    it { should contain_file('rspec.repo').with_content(/\[rspec\]\nname=info$/) }
  end

  context 'with environment set to valid string <testing>' do
    let(:params) { mandatory_params.merge({ :environment => 'testing' }) }

    it { should contain_file('rspec.repo').with_content(%r{\[rspec\][\s\S]*baseurl=http://yum.test.local///rspec/5/10/testing/\$basearch$}) }
  end

  describe 'variable type and content validations' do
    let(:mandatory_params) { mandatory_params }

    validations = {
      # /!\ Downgrade for Puppet 3.x: remove fixnum and float from invalid list
      'string' => {
        :name    => %w(username password),
        :valid   => ['string'],
        :invalid => [%w(array), { 'ha' => 'sh' }, true, false],
        :message => 'is not a string',
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
