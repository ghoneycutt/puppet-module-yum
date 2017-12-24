require 'spec_helper'

describe 'yum::repo' do
  mandatory_facts = {
    :domain              => 'test.local',
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
      |name=rspec
      |enabled=1
      |gpgcheck=0
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

    it { should have_yum__rpm_gpg_key_resource_count(0) }
    it { should contain_file('rspec.repo').without_content(/\[rspec\][\s\S]*sslcacert=/) }
  end

  context 'with baseurl set to valid string <http://yum.domain.tld/customrepo/5/8/dev/x86_64>' do
    let(:params) { mandatory_params.merge({ :baseurl => 'http://yum.domain.tld/customrepo/5/8/dev/x86_64' }) }

    it { should contain_file('rspec.repo').with_content(%r{\[rspec\][\s\S]*baseurl=http://yum.domain.tld/customrepo/5/8/dev/x86_64$}) }
  end

  context 'with enabled set to valid boolean false' do
    let(:params) { mandatory_params.merge({ :enabled => false }) }

    it { should contain_file('rspec.repo').with_content(/\[rspec\][\s\S]*enabled=0$/) }
  end

  context 'with gpgcheck set to valid boolean false' do
    let(:params) { mandatory_params.merge({ :gpgcheck => false }) }

    it { should have_yum__rpm_gpg_key_resource_count(0) }
    it { should contain_file('rspec.repo').with_content(/\[rspec\][\s\S]*gpgcheck=0$/) }
  end

  context 'with gpgkey set to valid string <http://yum.domain.tld/keys/RPM-GPG-KEY-CUSTOMREPO-5> when gpgcheck is set to true' do
    let(:params) do
      mandatory_params.merge({
        :gpgkey   => 'http://yum.domain.tld/keys/RPM-GPG-KEY-CUSTOMREPO-5',
        :gpgcheck => true,
      })
    end

    it { should have_yum__rpm_gpg_key_resource_count(1) }
    it do
      should contain_yum__rpm_gpg_key('RSPEC').with({
        'gpgkey_url' => 'http://yum.domain.tld/keys/RPM-GPG-KEY-CUSTOMREPO-5',
      })
    end
    it { should contain_file('rspec.repo').with_content(%r{\[rspec\][\s\S]*gpgkey=http://yum.domain.tld/keys/RPM-GPG-KEY-CUSTOMREPO-5$}) }
  end

  context 'with repo_file_mode set to valid string <0242>' do
    let(:params) { mandatory_params.merge({ :repo_file_mode => '0242' }) }

    it { should contain_file('rspec.repo').with_mode('0242') }
  end

  context 'with yum_repos_d_path set to valid string </rspec/test>' do
    let(:params) { mandatory_params.merge({ :yum_repos_d_path => '/rspec/test' }) }

    it { should contain_file('rspec.repo').with_path('/rspec/test/rspec.repo') }
  end

  context 'with gpgkey_local_path set to valid string </rspec/test>' do
    let(:params) do
      mandatory_params.merge({
        :gpgkey_local_path => '/rspec/test',
        :gpgcheck          => true,
      })
    end
    it { should contain_yum__rpm_gpg_key('RSPEC').with_gpgkey('/rspec/test/RPM-GPG-KEY-RSPEC-5') }
  end

  context 'with mirrorlist set to valid string <http://mirror.list/?release=7?arch=x86_64>' do
    let(:params) { mandatory_params.merge({ :mirrorlist => 'http://mirror.list/?release=7?arch=x86_64' }) }
    it { should contain_file('rspec.repo').with_content(%r{\[rspec\]\nmirrorlist=http://mirror.list/\?release=7\?arch=x86_64$}) }
    it { should contain_file('rspec.repo').without_content(/baseurl=/) }
  end

  context 'with ensure set to valid string "absent"' do
    let(:params) { mandatory_params.merge({ :ensure => 'absent' }) }
    it { should contain_file('rspec.repo').with_ensure('absent') }
    it { is_expected.to have_yum__rpm_gpg_key_resource_count(0) }
  end

  context 'with ensure set to valid string "present"' do
    let(:params) { mandatory_params.merge({ :ensure => 'present' }) }
    it { should contain_file('rspec.repo').with_ensure('file') }
  end

  # <parameters for repo file>
  # tests for general booleans
  boolean_params = {
    # name of param                 # default
    'enabled'                      => true,
    'enablegroups'                 => '',
    'gpgcheck'                     => false,
    'keepalive'                    => '',
    'repo_gpgcheck'                => '',
    'skip_if_unavailable'          => '',
    'ssl_check_cert_permissions'   => '',
    'sslverify'                    => '',
  }
  boolean_params.each do |param, default|
    [true, false,''].each do |value|
      context "with #{param} set to valid #{value.class} <#{value}>" do
        let(:params) { { :"#{param}"  => value } }
        if value == true
          it { should contain_file('rspec.repo').with_content(%r{^\[rspec\][\s\S]*#{param}=1$}) }
        elsif value == false
          it { should contain_file('rspec.repo').with_content(%r{^\[rspec\][\s\S]*#{param}=0$}) }
        else
          it { should contain_file('rspec.repo').without_content(%r{^\[rspec\][\s\S]*#{param}=$}) }
        end
      end
    end
    context "with #{param} unset" do
      if default == true
        it { should contain_file('rspec.repo').with_content(%r{^\[rspec\][\s\S]*#{param}=1}) }
      elsif default == false
        it { should contain_file('rspec.repo').with_content(%r{^\[rspec\][\s\S]*#{param}=0}) }
      else
        it { should contain_file('rspec.repo').without_content(%r{^\[rspec\][\s\S]*#{param}=}) }
      end
    end
  end

  # tests for general integers
  integer_params_valid = {
    'bandwidth'         => [0, 3, 42],
    'cost'              => [0, 3, 9999],
    'mirrorlist_expire' => [0, 3, 42],
    'retries'           => [0, 3, 42],
    'timeout'           => [0, 3, 42],
  }
  integer_params_valid.each do |param, valid|
    valid.each do |value|
      context "with #{param} set to valid #{value.class} <#{value}>" do
        let(:params) { { :"#{param}" => value } }
        it { should contain_file('rspec.repo').with_content(%r{^\[rspec\][\s\S]*#{param}=#{value}$}) }
      end
    end
    context "with #{param} set to valid empty string" do
        let(:params) { { :"#{param}" => '' } }
      it { should contain_file('rspec.repo').without_content(%r{#{param}=}) }
    end
  end

  # tests for general strings
  string_params = {
    'password'          => %w(string),
    'proxy_password'    => %w(string),
    'proxy_username'    => %w(string),
    'repositoryid'      => %w(string),
    'username'          => %w(string),
    'baseurl'           => %w(http://url.test https://url.test https://port.test:242),
    'gpgcakey'          => %w(http://url.test https://url.test https://port.test:242),
    'gpgkey'            => %w(http://url.test https://url.test https://port.test:242),
    'metalink'          => %w(http://url.test https://url.test https://port.test:242),
    'mirrorlist'        => %w(http://url.test https://url.test https://port.test:242),
    'proxy'             => %w(http://url.test https://url.test https://port.test:242 _none_),
    'failovermethod'    => %w(roundrobin priority),
    'http_caching'      => %w(all none packages),
    'metadata_expire'   => [242, '242d','242h','242m','never'],
    'throttle'          => [2.42, 242, '2.42M'],
    'sslcacert'         => %w(/absolute/file_path /absolute/directory/),
    'sslclientcert'     => %w(/absolute/file_path /absolute/directory/),
    'sslclientkey'      => %w(/absolute/file_path /absolute/directory/),
  }
  string_params.each do |param, valid|
    valid.each do |value|
      context "with #{param} set to valid #{value.class} <#{value}>" do
        let(:params) { { :"#{param}" => value } }
        it { should contain_file('rspec.repo').with_content(%r{^\[rspec\][\s\S]*#{param}=#{Regexp.escape(value.to_s)}$}) }
      end
    end
    context "with #{param} set to valid empty string" do
      let(:params) { { :"#{param}" => '' } }
      it { should contain_file('rspec.repo').without_content(%r{#{param}=}) }
    end
  end

  # special treamment for name parameter as $name is a reserved variable name
  context 'with description set to valid String <string>' do
    let(:params) { { :description => 'string' } }
    it { should contain_file('rspec.repo').with_content(%r{^\[rspec\][\s\S]*name=string}) }
  end
  context 'with description set to valid empty string' do
    let(:params) { { :description => '' } }
    it { should contain_file('rspec.repo').without_content(%r{name=}) }
  end

  # arrays with free content
  array_params = {
    'exclude'     => %w(package1 package2),
    'includepkgs' => %w(package1 package2),
  }
  array_params.each do |param, valid|
    context "with #{param} set to valid array #{valid}" do
      let(:params) { { :"#{param}" => valid } }
      it { should contain_file('rspec.repo').with_content(%r{^\[rspec\][\s\S]*#{param}=#{valid.join(',')}$}) }
    end

    context "with #{param} unset" do
      it { should contain_file('rspec.repo').without_content(%r{#{param}=}) }
    end
  end
  # </parameters for repo file>

  describe 'variable type and content validations' do
    let(:mandatory_params) { mandatory_params }

    validations = {
      'Stdlib::Absolutepath' => {
        :name    => %w(gpgkey_local_path yum_repos_d_path),
        :valid   => ['/absolute/filepath', '/absolute/directory/'],
        :invalid => ['../invalid', %w(array), { 'ha' => 'sh' }, 3, 2.42, false, nil],
        :message => 'expects a (match for|match for Stdlib::Absolutepath =|Stdlib::Absolutepath =) Variant\[Stdlib::Windowspath.*Stdlib::Unixpath', # Puppet (4.x|5.0 & 5.1|5.x)
      },
      'Stdlib::Absolutepath (optional)' => {
        :name    => %w(sslcacert sslclientcert sslclientkey),
        :valid   => ['/absolute/filepath', '/absolute/directory/'],
        :invalid => ['../invalid', %w(array), { 'ha' => 'sh' }, 3, 2.42, false, nil],
        :message => 'expects a match for Variant\[Enum\[\'\'\], (Stdlib::Windowspath.*Stdlib::Unixpath|Stdlib::Absolutepath)',  # Puppet (4|5)
      },
      'Stdlib::Filemode' => {
        :name    => %w(repo_file_mode),
        :valid   => %w(0644 0755 0640 0740),
        :invalid => [ 2770, '0844', '755', '00644', 'string', %w(array), { 'ha' => 'sh' }, 3, 2.42, false, nil],
        :message => 'expects a match for Stdlib::Filemode', # Puppet 4 & 5
      },
      'Stdlib::Httpurl' => {
        :name    => %w(baseurl gpgcakey gpgkey metalink mirrorlist),
        :valid   => %w(http://plain.test https://secure.test https://port.test:242),
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, 3, 2.42, false, nil],
        :message => 'expects a match for Variant\[Enum\[\'\'\], Stdlib::HTTPUrl',  # Puppet 4 & 5
      },
      'array' => {
        :name    => %w(exclude includepkgs),
        :valid   => [%w(array)],
        :invalid => ['string', { 'ha' => 'sh' }, 3, 2.42, false, nil],
        :message => 'expects an Array', # Puppet 4 & 5
      },
      'boolean or empty string' => {
        :name    => %w(enabled enablegroups gpgcheck keepalive repo_gpgcheck skip_if_unavailable ssl_check_cert_permissions sslverify),
        :valid   => [true, false],
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, 3, 2.42, 'false'],
        :message => 'expects a match for Variant\[Enum\[\'\'\], Boolean\]', # Puppet 4 & 5
      },
      'integer or empty string' => {
        :name    => %w(bandwidth cost mirrorlist_expire retries timeout),
        :valid   => [242, ''],
        :invalid => ['242', 2.42, %w(array), { 'ha' => 'sh' }, false, nil],
        :message => 'expects a match for Variant\[Enum\[\'\'\], Integer\]', # Puppet 4 & 5
      },
      'present or absent' => {
        :name    => %w(ensure),
        :valid   => ['present', 'absent'],
        :invalid => [false, 'file'],
        :message => 'expects a match for Enum\[\'absent\', \'present\'\]', # Puppet 4 & 5
      },
      'specific for failovermethod' => {
        :name    => %w(failovermethod),
        :valid   => %w(priority roundrobin),
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, false],
        :message => 'expects a match for Enum\[\'\', \'priority\', \'roundrobin\'\]', # Puppet 4 & 5
      },
      'specific for http_caching' => {
        :name    => %w(http_caching),
        :valid   => %w(all none packages),
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, false],
        :message => 'expects a match for Enum\[\'\', \'all\', \'none\', \'packages\'\]', # Puppet 4 & 5
      },
      'specific for metadata_expire' => {
        :name    => %w(metadata_expire),
        :valid   => [3, '242m', '242h', '242d', 'never' ],
        :invalid => [%w(array), { 'ha' => 'sh' }, 2.42, false],
        :message => 'expects a match for Variant\[Enum\[\'\'\], Integer, Pattern',  # Puppet 4 & 5
      },
      'specific for proxy' => {
        :name    => %w(proxy),
        :valid   => %w(http://plain.test https://secure.test https://port.test:242 _none_),
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, 3, 2.42, false, nil],
        :message => 'expects a match for Variant\[Enum\[\'\', \'_none_\'\], Stdlib::HTTPUrl',  # Puppet 4 & 5
      },
      'specific for throttle' => {
        :name    => %w(throttle),
        :valid   => [3, 2.42, '242k', '24.2M', '2.42G' ],
        :invalid => [%w(array), { 'ha' => 'sh' }, false],
        :message => 'expects a match for Variant\[Enum\[\'\'\], Integer, Float, Pattern',  # Puppet 4 & 5
      },
      'string or empty string' => {
        :name    => %w(description password proxy_password proxy_username repositoryid username),
        :valid   => ['string'],
        :invalid => [%w(array), { 'ha' => 'sh' }, 3, 2.42, true],
        :message => 'expects a match for Variant\[Enum\[\'\'\], String\]',  # Puppet 4 & 5
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
