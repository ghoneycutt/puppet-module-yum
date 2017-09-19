require 'spec_helper'

describe 'yum::repo' do
  mandatory_facts = {
    :domain              => 'test.local',
    :environment         => 'rp_env', # can't be set on Puppet >= 4.3, using the hardcoded default value here to match
    :lsbmajdistrelease   => '5',
    :lsbminordistrelease => '10',
  }
  mandatory_params = {}
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
      |gpgkey=http://yum.test.local/keys/RPM-GPG-KEY-RSPEC-5
      |baseurl=http://yum.test.local///rspec/5/10/rp_env/$basearch
      |name=rspec
      |enabled=1
      |gpgcheck=1
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

    it { should contain_file('rspec.repo').without_content(/\[rspec\][\s\S]*sslcacert=/) }
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

  context 'with use_gpgkey_uri set to valid bool <false>' do
    let(:params) { mandatory_params.merge({ :use_gpgkey_uri => false }) }

    it { should have_yum__rpm_gpg_key_resource_count(0) }
    it { should contain_file('rspec.repo').without_content(/gpgkey=/) }
  end

  context 'with priority set to valid string <242>' do
    let(:params) { mandatory_params.merge({ :priority => '242' }) }

    it { should contain_file('rspec.repo').with_content(/\[rspec\]\npriority=242$/) }
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

    it { should contain_file('rspec.repo').with_content(/\[rspec\][\s\S]*name=info$/) }
  end

  context 'with environment set to valid string <spec_testing>' do
    let(:params) { mandatory_params.merge({ :environment => 'spec_testing' }) }

    it { should contain_file('rspec.repo').with_content(%r{\[rspec\][\s\S]*baseurl=http://yum.test.local///rspec/5/10/spec_testing/\$basearch$}) }
  end

  context 'with mirrorlist set to valid string <http://mirror.list/?release=7?arch=x86_64>' do
    let(:params) { mandatory_params.merge({ :mirrorlist => 'http://mirror.list/?release=7?arch=x86_64' }) }
    it { should contain_file('rspec.repo').with_content(%r{\[rspec\]\nmirrorlist=http://mirror.list/\?release=7\?arch=x86_64$}) }
    it { should contain_file('rspec.repo').without_content(/baseurl=/) }
  end

  context 'with failovermethod set to valid string <priority>' do
    let(:params) { mandatory_params.merge({ :failovermethod => 'priority' }) }
    it { should contain_file('rspec.repo').with_content(/\[rspec\]\nfailovermethod=priority/) }
  end

  context 'with sslcacert set to valid string </path/to/cert>' do
    let(:params) { mandatory_params.merge({ :sslcacert => '/path/to/cert' }) }
    it { should contain_file('rspec.repo').with_content(/\[rspec\][\s\S]*sslcacert=\/path\/to\/cert/) }
  end

  describe 'variable type and content validations' do
    let(:mandatory_params) { mandatory_params }

    validations = {
      'absolute_path' => {
        :name    => %w(gpgkey_local_path yum_repos_d_path),
        :valid   => ['/absolute/filepath', '/absolute/directory/'],
        :invalid => ['../invalid', %w(array), { 'ha' => 'sh' }, 3, 2.42, true, false, nil],
        :message => 'is not an absolute path',
      },
      'absolute_path_and_undef' => {
        :name    => %w(sslcacert),
        :valid   => [ :undef, '/absolute/filepath', '/absolute/directory/'],
        :invalid => ['../invalid', %w(array), { 'ha' => 'sh' }, 3, 2.42, true, false],
        :message => 'is not an absolute path',
      },
      'bool and stringified' => {
        :name    => %w(enabled gpgcheck use_gpgkey_uri),
        :valid   => [true, false, 'true', '1', 'false', '0'],
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, 3, 2.42, nil],
        :message => '(is not a boolean|Unknown type of boolean given)',
      },
      'domain_name' => {
        :name    => %w(gpgkey_url_server repo_server),
        :valid   => %w(v.al.id val.id),
        :invalid => ['in,val.id', 'in_val.id', %w(array), { 'ha' => 'sh' }, 3, 2.42, true, false],
        :message => 'is not a domain name',
      },
      'integer and stringified' => {
        :name    => %w(priority),
        :valid   => [242, '242'],
        :invalid => ['string', 2.42, %w(array), { 'ha' => 'sh' }, true, false, nil],
        :message => '(is not an integer nor stringified integer|floor\(\): Wrong argument type)',
      },
      'regex for mode' => {
        :name    => %w(repo_file_mode),
        :valid   => %w(0644 0755 0640 0740),
        :invalid => ['0844', '755', '00644', 'string', %w(array), { 'ha' => 'sh' }, 3, 2.42, true, false, nil],
        :message => 'is not a file mode in octal notation',
      },
      # /!\ Downgrade for Puppet 3.x: remove fixnum and float from invalid list
      'string' => {
        :name    => %w(baseurl description environment failovermethod gpgkey gpgkey_file_prefix gpgkey_url_path gpgkey_url_proto mirrorlist password repo_server_basedir repo_server_protocol username),
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
