require 'spec_helper'

describe 'yum::repo' do
  mandatory_facts = {
    domain: 'test.local',
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
    it { is_expected.to compile.with_all_deps }

    content = <<-END.gsub(%r{^\s+\|}, '')
      |# This file is being maintained by Puppet.
      |# DO NOT EDIT
      |
      |[rspec]
      |name=rspec
      |enabled=1
      |gpgcheck=0
    END

    it do
      is_expected.to contain_file('rspec.repo').with(
        {
          'ensure' => 'file',
          'path'    => '/etc/yum.repos.d/rspec.repo',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0400',
          'content' => content,
          'notify'  => 'Exec[clean_yum_cache]',
        },
      )
    end

    it { is_expected.to have_yum__rpm_gpg_key_resource_count(0) }
    it { is_expected.to contain_file('rspec.repo').without_content(%r{\[rspec\][\s\S]*sslcacert=}) }
  end

  context 'with enabled set to valid boolean false' do
    let(:params) { mandatory_params.merge({ enabled: false }) }

    it { is_expected.to contain_file('rspec.repo').with_content(%r{\[rspec\][\s\S]*enabled=0$}) }
  end

  context 'with gpgcheck set to valid boolean false' do
    let(:params) { mandatory_params.merge({ gpgcheck: false }) }

    it { is_expected.to have_yum__rpm_gpg_key_resource_count(0) }
    it { is_expected.to contain_file('rspec.repo').with_content(%r{\[rspec\][\s\S]*gpgcheck=0$}) }
  end

  context 'with repo_file_mode set to valid string <0242>' do
    let(:params) { mandatory_params.merge({ repo_file_mode: '0242' }) }

    it { is_expected.to contain_file('rspec.repo').with_mode('0242') }
  end

  context 'with yum_repos_d_path set to valid string </rspec/test>' do
    let(:params) { mandatory_params.merge({ yum_repos_d_path: '/rspec/test' }) }

    it { is_expected.to contain_file('rspec.repo').with_path('/rspec/test/rspec.repo') }
  end

  context 'with mirrorlist set to valid string <http://mirror.list/?release=7?arch=x86_64>' do
    let(:params) { mandatory_params.merge({ mirrorlist: 'http://mirror.list/?release=7?arch=x86_64' }) }

    it { is_expected.to contain_file('rspec.repo').with_content(%r{\[rspec\]\nmirrorlist=http://mirror.list/\?release=7\?arch=x86_64$}) }
    it { is_expected.to contain_file('rspec.repo').without_content(%r{baseurl=}) }
  end

  context 'with ensure set to valid string <absent>' do
    let(:params) { mandatory_params.merge({ ensure: 'absent' }) }

    it { is_expected.to contain_file('rspec.repo').with_ensure('absent') }
    it { is_expected.to have_yum__rpm_gpg_key_resource_count(0) }
  end

  context 'with ensure set to valid string <present>' do
    let(:params) { mandatory_params.merge({ ensure: 'present' }) }

    it { is_expected.to contain_file('rspec.repo').with_ensure('file') }
  end

  # <parameters for repo file>
  # tests for general booleans
  boolean_params = {
    # name of param                 # default
    'enabled'                      => true,
    'enablegroups'                 => :undef,
    'gpgcheck'                     => false,
    'keepalive'                    => :undef,
    'repo_gpgcheck'                => :undef,
    'skip_if_unavailable'          => :undef,
    'ssl_check_cert_permissions'   => :undef,
    'sslverify'                    => :undef,
  }
  boolean_params.each do |param, default|
    [true, false, :undef].each do |value|
      context "with #{param} set to valid #{value.class} <#{value}>" do
        let(:params) { { "#{param}": value } }

        if value == true
          it { is_expected.to contain_file('rspec.repo').with_content(%r{^\[rspec\][\s\S]*#{param}=1$}) }
        elsif value == false
          it { is_expected.to contain_file('rspec.repo').with_content(%r{^\[rspec\][\s\S]*#{param}=0$}) }
        else
          it { is_expected.to contain_file('rspec.repo').without_content(%r{^\[rspec\][\s\S]*#{param}=$}) }
        end
      end
    end

    context "with #{param} unset" do
      if default == true
        it { is_expected.to contain_file('rspec.repo').with_content(%r{^\[rspec\][\s\S]*#{param}=1}) }
      elsif default == false
        it { is_expected.to contain_file('rspec.repo').with_content(%r{^\[rspec\][\s\S]*#{param}=0}) }
      else
        it { is_expected.to contain_file('rspec.repo').without_content(%r{^\[rspec\][\s\S]*#{param}=}) }
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
        let(:params) { { "#{param}": value } }

        it { is_expected.to contain_file('rspec.repo').with_content(%r{^\[rspec\][\s\S]*#{param}=#{value}$}) }
      end
    end
    context "with #{param} set to valid undef" do
      let(:params) { { "#{param}": :undef } }

      it { is_expected.to contain_file('rspec.repo').without_content(%r{#{param}=}) }
    end
  end

  # tests for general strings
  string_params = {
    'password'          => ['string'],
    'proxy_password'    => ['string'],
    'proxy_username'    => ['string'],
    'repositoryid'      => ['string'],
    'username'          => ['string'],
    'gpgcakey'          => ['http://url.test', 'https://url.test', 'https://port.test:242'],
    'metalink'          => ['http://url.test', 'https://url.test', 'https://port.test:242'],
    'mirrorlist'        => ['http://url.test', 'https://url.test', 'https://port.test:242'],
    'proxy'             => ['http://url.test', 'https://url.test', 'https://port.test:242', '_none_'],
    'failovermethod'    => ['roundrobin', 'priority'],
    'http_caching'      => ['all', 'none', 'packages'],
    'metadata_expire'   => [242, '242d', '242h', '242m', 'never'],
    'throttle'          => [2.42, 242, '2.42M'],
    'sslcacert'         => ['/absolute/file_path', '/absolute/directory/'],
    'sslclientcert'     => ['/absolute/file_path', '/absolute/directory/'],
    'sslclientkey'      => ['/absolute/file_path', '/absolute/directory/'],
  }
  string_params.each do |param, valid|
    valid.each do |value|
      context "with #{param} set to valid #{value.class} <#{value}>" do
        let(:params) { { "#{param}": value } }

        it { is_expected.to contain_file('rspec.repo').with_content(%r{^\[rspec\][\s\S]*#{param}=#{Regexp.escape(value.to_s)}$}) }
      end
    end
    context "with #{param} set to valid undef" do
      let(:params) { { "#{param}": :undef } }

      it { is_expected.to contain_file('rspec.repo').without_content(%r{#{param}=}) }
    end
  end

  # special treamment for name parameter as $name is a reserved variable name
  context 'with description set to valid String <string>' do
    let(:params) { { description: 'string' } }

    it { is_expected.to contain_file('rspec.repo').with_content(%r{^\[rspec\][\s\S]*name=string}) }
  end

  # /!\ need to skip this test
  # found no way to set undef successfully from here
  # context 'with description set to valid undef' do
  #  let(:params) { { :description => :undef } }
  #  it { should contain_file('rspec.repo').without_content(%r{name=}) }
  # end

  # arrays with free content
  array_params = {
    'exclude'     => ['package1', 'package2'],
    'includepkgs' => ['package1', 'package2'],
  }
  array_params.each do |param, valid|
    context "with #{param} set to valid array #{valid}" do
      let(:params) { { "#{param}": valid } }

      it { is_expected.to contain_file('rspec.repo').with_content(%r{^\[rspec\][\s\S]*#{param}=#{valid.join(',')}$}) }
    end

    context "with #{param} unset" do
      it { is_expected.to contain_file('rspec.repo').without_content(%r{#{param}=}) }
    end
  end

  # arrays with free content for multiliners
  array_params = {
    'baseurl' => ['http://url.test', 'https://url.test', 'https://port.test:242', 'ftp://port.test:242', 'file:///file.local'],
    'gpgkey'  => ['http://url.test', 'https://url.test', 'https://port.test:242', 'ftp://port.test:242', 'file:///file.local'],
  }
  array_params.each do |param, valid|
    context "with #{param} set to valid array #{valid}" do
      let(:params) { { "#{param}": valid } }

      it { is_expected.to contain_file('rspec.repo').with_content(%r{^\[rspec\][\s\S]*#{param}=#{valid.join('\n  ')}$}) }
    end

    context "with #{param} unset" do
      it { is_expected.to contain_file('rspec.repo').without_content(%r{#{param}=}) }
    end
  end
  # </parameters for repo file>

  describe 'variable type and content validations' do
    let(:mandatory_params) { mandatory_params }

    validations = {
      'Array' => {
        name:    ['exclude', 'includepkgs'],
        valid:   [['array']],
        invalid: ['string', { 'ha' => 'sh' }, 3, 2.42, false, nil],
        message: 'expects an Array', # Puppet 4 & 5
      },
      'Array[Variant[Stdlib::Httpurl,Pattern[]]]' => {
        name:    ['baseurl', 'gpgkey'],
        valid:   [['http://plain.test'], ['https://secure.test'], ['https://port.test:242'], ['ftp://ftp.test'], ['file:///local.file']],
        invalid: ['string', ['array'], { 'ha' => 'sh' }, 3, 2.42, false, nil],
        message: '(expects an Array value|expects a match for Variant\[Stdlib::HTTPUrl.*, Pattern\[\^\(file|ftp\):)', # Puppet 4 & 5
      },
      'Enum[] for ensure' => {
        name:    ['ensure'],
        valid:   ['present', 'absent'],
        invalid: [false, 'file'],
        message: 'expects a match for Enum\[\'absent\', \'present\'\]', # Puppet 4 & 5
      },
      'Optional[Boolean]' => {
        name:    ['enabled', 'enablegroups', 'gpgcheck', 'keepalive', 'repo_gpgcheck', 'skip_if_unavailable', 'ssl_check_cert_permissions', 'sslverify'],
        valid:   [true, false, :undef],
        invalid: ['string', ['array'], { 'ha' => 'sh' }, 3, 2.42, 'false'],
        message: 'expects a value of type Undef or Boolean', # Puppet 4 & 5
      },
      'Optional[Integer]' => {
        name:    ['bandwidth', 'cost', 'mirrorlist_expire', 'retries', 'timeout'],
        valid:   [1, 10, :undef],
        invalid: ['242', 2.42, ['array'], { 'ha' => 'sh' }, false],
        message: 'expects a value of type Undef or Integer', # Puppet 4 & 5
      },
      'Optional[String]' => {
        name:    ['description', 'password', 'proxy_password', 'proxy_username', 'repositoryid', 'username'],
        valid:   ['string'],
        invalid: [['array'], { 'ha' => 'sh' }, 3, 2.42, true],
        message: 'expects a value of type Undef or String',  # Puppet 4 & 5
      },
      'Optional[Stdlib::Httpurl]' => {
        name:    ['gpgcakey', 'metalink', 'mirrorlist'],
        valid:   ['http://plain.test', 'https://secure.test', 'https://port.test:242'],
        invalid: ['string', ['array'], { 'ha' => 'sh' }, 3, 2.42, false, nil],
        message: 'expects a match for Stdlib::HTTPUrl', # Puppet 4 & 5
      },
      'Optional[Enum[]] for failovermethod' => {
        name:    ['failovermethod'],
        valid:   ['priority', 'roundrobin'],
        invalid: ['string', ['array'], { 'ha' => 'sh' }, false],
        message: 'expects a(n undef value or a)? match for Enum', # Puppet (4) & 5
      },
      'Optional[Enum[]] for http_caching' => {
        name:    ['http_caching'],
        valid:   ['all', 'none', 'packages'],
        invalid: ['string', ['array'], { 'ha' => 'sh' }, false],
        message: 'expects a(n undef value or a)? match for Enum', # Puppet (4) & 5
      },
      'Optional[Enum[]] for proxy' => {
        name:    ['proxy'],
        valid:   ['http://plain.test', 'https://secure.test', 'https://port.test:242', '_none_'],
        invalid: ['string', ['array'], { 'ha' => 'sh' }, false],
        message: 'expects a (match for Variant.|value of type Undef, )Stdlib::HTTPUrl.* Enum', # Puppet (4|5)
      },
      'Optional[Stdlib::Absolutepath]' => {
        name:    ['sslcacert', 'sslclientcert', 'sslclientkey'],
        valid:   ['/absolute/filepath', '/absolute/directory/'],
        invalid: ['../invalid', ['array'], { 'ha' => 'sh' }, 3, 2.42, false, nil],
        message: 'expects a (match for|match for Stdlib::Absolutepath =|Stdlib::Absolutepath =) Variant\[Stdlib::Windowspath.*Stdlib::Unixpath', # Puppet (4.x|5.0 & 5.1|5.x)
      },
      'Optional[Variant[Integer,Float,Pattern[]]] for throttle' => {
        name:    ['throttle'],
        valid:   [3, 2.42, '242k', '24.2M', '2.42G' ],
        invalid: ['string', ['array'], { 'ha' => 'sh' }, false],
        message: 'expects a value of type Undef, Integer, Float, or Pattern', # Puppet 4 & 5
      },
      'Optional[Variant[Integer,Pattern[]]] for metadata_expire' => {
        name:    ['metadata_expire'],
        valid:   [3, '242m', '242h', '242d', 'never' ],
        invalid: [['array'], { 'ha' => 'sh' }, 2.42, false],
        message: 'expects a value of type Undef, Integer, or Pattern', # Puppet 4 & 5
      },
      'Stdlib::Absolutepath' => {
        name:    ['yum_repos_d_path'],
        valid:   ['/absolute/filepath', '/absolute/directory/'],
        invalid: ['../invalid', ['array'], { 'ha' => 'sh' }, 3, 2.42, false, nil],
        message: 'expects a (match for|match for Stdlib::Absolutepath =|Stdlib::Absolutepath =) Variant\[Stdlib::Windowspath.*Stdlib::Unixpath', # Puppet (4.x|5.0 & 5.1|5.x)
      },
      'Stdlib::Filemode' => {
        name:    ['repo_file_mode'],
        valid:   ['0644', '0755', '0640', '0740', '755'],
        invalid: [ 2770, '0844', '00644', 'string', ['array'], { 'ha' => 'sh' }, 3, 2.42, false, nil],
        message: 'expects a match for Stdlib::Filemode|expect', # Puppet 4 & 5
      },
    }

    validations.sort.each do |type, var|
      var[:name].each do |var_name|
        var[:params] = {} if var[:params].nil?
        var[:valid].each do |valid|
          context "when #{var_name} (#{type}) is set to valid #{valid} (as #{valid.class})" do
            let(:params) { [mandatory_params, var[:params], { "#{var_name}": valid, }].reduce(:merge) }

            it { is_expected.to compile }
          end
        end

        var[:invalid].each do |invalid|
          context "when #{var_name} (#{type}) is set to invalid #{invalid} (as #{invalid.class})" do
            let(:params) { [mandatory_params, var[:params], { "#{var_name}": invalid, }].reduce(:merge) }

            it 'fails' do
              expect { is_expected.to contain_class(:subject) }.to raise_error(Puppet::Error, %r{#{var[:message]}})
            end
          end
        end
      end # var[:name].each
    end # validations.sort.each
  end # describe 'variable type and content validations'
end
