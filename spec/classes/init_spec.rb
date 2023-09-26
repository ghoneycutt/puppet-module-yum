require 'spec_helper'
describe 'yum' do
  mandatory_facts = {
    fqdn: 'no-hiera-data.example.local',
    test: 'no-hiera-data',
    os: {
      name: 'RedHat',
    }
  }
  mandatory_params = {}
  let(:facts) { mandatory_facts }
  let(:params) { mandatory_params }

  context 'with defaults for all parameters' do
    it { is_expected.to contain_class('yum') }
    it { is_expected.to contain_class('yum::updatesd') }

    it { is_expected.to have_yum__repo_resource_count(0) }
    it { is_expected.to contain_package('yum').with_ensure('installed') }

    content = <<-END.gsub(%r{^\s+\|}, '')
      |# This file is being maintained by Puppet.
      |# DO NOT EDIT
      |
      |[main]
      |cachedir=/var/cache/yum/$basearch/$releasever
      |keepcache=1
      |debuglevel=2
      |logfile=/var/log/yum.log
      |tolerant=0
      |exactarch=1
      |obsoletes=1
      |gpgcheck=0
      |plugins=0
      |
      |# Note: yum-RHN-plugin doesn't honor this.
      |metadata_expire=6h
    END

    it do
      is_expected.to contain_file('yum_config').with(
        {
          'ensure' => 'file',
          'path'    => '/etc/yum.conf',
          'content' => content,
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
          'require' => 'Package[yum]',
        },
      )
    end

    it do
      is_expected.to contain_file('/etc/yum.repos.d').with(
        {
          'ensure'  => 'directory',
          'purge'   => 'false',
          'recurse' => 'false',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0755',
          'require' => 'File[yum_config]',
          'notify'  => 'Exec[clean_yum_cache]',
        },
      )
    end

    it do
      is_expected.to contain_exec('clean_yum_cache').with(
        {
          'command' => 'yum clean all',
          'path'        => '/bin:/usr/bin:/sbin:/usr/sbin',
          'refreshonly' => 'true',
        },
      )
    end
  end

  context 'with config_path set to valid string </spec/test>' do
    let(:params) { { config_path: '/spec/test' } }

    it { is_expected.to contain_file('yum_config').with_path('/spec/test') }
  end

  context 'with config_owner set to valid string <john>' do
    let(:params) { { config_owner: 'john' } }

    it { is_expected.to contain_file('yum_config').with_owner('john') }
  end

  context 'with config_group set to valid string <doe>' do
    let(:params) { { config_group: 'doe' } }

    it { is_expected.to contain_file('yum_config').with_group('doe') }
  end

  context 'with config_mode set to valid string <0242>' do
    let(:params) { { config_mode: '0242' } }

    it { is_expected.to contain_file('yum_config').with_mode('0242') }
  end

  context 'with manage_repos set to valid boolean <true>' do
    let(:params) { { manage_repos: true } }

    it do
      is_expected.to contain_file('/etc/yum.repos.d').with(
        {
          'purge'   => 'true',
          'recurse' => 'true',
        },
      )
    end
  end

  context 'with repos_d_owner set to valid string <john>' do
    let(:params) { { repos_d_owner: 'john' } }

    it { is_expected.to contain_file('/etc/yum.repos.d').with_owner('john') }
  end

  context 'with repos_d_group set to valid string <doe>' do
    let(:params) { { repos_d_group: 'doe' } }

    it { is_expected.to contain_file('/etc/yum.repos.d').with_group('doe') }
  end

  context 'with repos_d_mode set to valid string <0242>' do
    let(:params) { { repos_d_mode: '0242' } }

    it { is_expected.to contain_file('/etc/yum.repos.d').with_mode('0242') }
  end

  context 'with repos set to valid hash when hiera merge is disabled' do
    let(:params) do
      {
        repos_hiera_merge: false,
        repos: {
          'rspec' => {
            'gpgcheck'          => false,
          },
          'test' => {
            'repo_file_mode'    => '0242',
          }
        }
      }
    end

    it { is_expected.to have_yum__repo_resource_count(2) }

    it { is_expected.to contain_yum__repo('rspec').with_gpgcheck(false) }
    it { is_expected.to contain_yum__repo('test').with_repo_file_mode('0242') }
  end

  context 'with rpm_gpg_keys set to valid hash when hiera merge is disabled' do
    let(:params) do
      {
        rpm_gpg_keys_hiera_merge: false,
        rpm_gpg_keys: {
          'rspec' => {
            'gpgkey'     => '/etc/pki/rpm-gpg/RPM-GPG-KEY-RSPEC',
            'gpgkey_url' => 'http://yum.domain.tld/keys/RPM-GPG-KEY-RSPEC',
          },
          'test' => {
            'gpgkey'     => '/etc/pki/rpm-gpg/RPM-GPG-KEY-TEST',
            'gpgkey_url' => 'http://yum.domain.tld/keys/RPM-GPG-KEY-TEST',
          }
        }
      }
    end

    it { is_expected.to have_yum__rpm_gpg_key_resource_count(2) }

    it do
      is_expected.to contain_yum__rpm_gpg_key('rspec').with(
        {
          'gpgkey' => '/etc/pki/rpm-gpg/RPM-GPG-KEY-RSPEC',
          'gpgkey_url' => 'http://yum.domain.tld/keys/RPM-GPG-KEY-RSPEC',
        },
      )
    end

    it do
      is_expected.to contain_yum__rpm_gpg_key('test').with(
        {
          'gpgkey' => '/etc/pki/rpm-gpg/RPM-GPG-KEY-TEST',
          'gpgkey_url' => 'http://yum.domain.tld/keys/RPM-GPG-KEY-TEST',
        },
      )
    end
  end

  describe 'with hiera providing data from multiple levels for the repos parameter' do
    let(:facts) do
      mandatory_facts.merge(
        {
          fqdn: 'yum.example.local',
          test: 'yum__repos',
        },
      )
    end

    context 'with defaults for all parameters' do
      it { is_expected.to have_yum__repo_resource_count(2) }
      it { is_expected.to contain_yum__repo('from_hiera_class') }
      it { is_expected.to contain_yum__repo('from_hiera_fqdn') }
    end

    context 'with repos_hiera_merge set to valid <false>' do
      let(:params) { { repos_hiera_merge: false } }

      it { is_expected.to have_yum__repo_resource_count(1) }
      it { is_expected.to contain_yum__repo('from_hiera_fqdn') }
    end
  end

  describe 'with hiera providing data from multiple levels for the rpm_gpg_keys parameter' do
    let(:facts) do
      mandatory_facts.merge(
        {
          fqdn: 'yum.example.local',
          test: 'yum__rpm_gpg_keys',
        },
      )
    end

    context 'with defaults for all parameters' do
      it { is_expected.to have_yum__rpm_gpg_key_resource_count(2) }
      it { is_expected.to contain_yum__rpm_gpg_key('from_hiera_class') }
      it { is_expected.to contain_yum__rpm_gpg_key('from_hiera_fqdn') }
    end

    context 'with repos_hiera_merge set to valid <false>' do
      let(:params) { { rpm_gpg_keys_hiera_merge: false } }

      it { is_expected.to have_yum__rpm_gpg_key_resource_count(1) }
      it { is_expected.to contain_yum__rpm_gpg_key('from_hiera_fqdn') }
    end
  end

  describe 'with hiera providing data from multiple levels for the exclude parameter' do
    let(:facts) do
      mandatory_facts.merge(
        {
          fqdn: 'yum.example.local',
          test: 'yum__exclude',
        },
      )
    end

    context 'with defaults for all parameters' do
      it { is_expected.to contain_file('yum_config').with_content(%r{^exclude=from_hiera_fqdn$}) }
    end

    context 'with exclude_hiera_merge set to valid <true>' do
      let(:params) { { exclude_hiera_merge: true } }

      it { is_expected.to contain_file('yum_config').with_content(%r{^exclude=from_hiera_fqdn,from_hiera_test$}) }
    end
  end

  # <parameters for yum.conf>
  # tests for general booleans
  boolean_params = {
    # name of param                 # default
    'alwaysprompt'                 => :undef,
    'assumeyes'                    => :undef,
    'clean_requirements_on_remove' => :undef,
    'color'                        => :undef,
    'diskspacecheck'               => :undef,
    'enable_group_conditionals'    => :undef,
    'exactarch'                    => true,
    'gpgcheck'                     => false,
    'groupremove_leaf_only'        => :undef,
    'history_record'               => :undef,
    'keepalive'                    => :undef,
    'keepcache'                    => true,
    'localpkg_gpgcheck'            => :undef,
    'obsoletes'                    => true,
    'overwrite_groups'             => :undef,
    'plugins'                      => false,
    'protected_multilib'           => :undef,
    'repo_gpgcheck'                => :undef,
    'reset_nice'                   => :undef,
    'showdupesfromrepos'           => :undef,
    'skip_broken'                  => :undef,
    'ssl_check_cert_permissions'   => :undef,
    'sslverify'                    => :undef,
    'tolerant'                     => false,
  }
  boolean_params.each do |param, default|
    [true, false, :undef].each do |value|
      context "with #{param} set to valid #{value.class} <#{value}>" do
        let(:params) { { "#{param}": value } }

        if value == true
          it { is_expected.to contain_file('yum_config').with_content(%r{^\[main\][\s\S]*#{param}=1$}) }
        elsif value == false
          it { is_expected.to contain_file('yum_config').with_content(%r{^\[main\][\s\S]*#{param}=0$}) }
        else
          it { is_expected.to contain_file('yum_config').without_content(%r{#{param}=$}) }
        end
      end
    end
    context "with #{param} unset" do
      if default == true
        it { is_expected.to contain_file('yum_config').with_content(%r{^\[main\][\s\S]*#{param}=1}) }
      elsif default == false
        it { is_expected.to contain_file('yum_config').with_content(%r{^\[main\][\s\S]*#{param}=0}) }
      else
        it { is_expected.to contain_file('yum_config').without_content(%r{#{param}=}) }
      end
    end
  end

  # tests for general integers
  integer_params_valid = {
    'bandwidth'         => [0, 3, 42],
    'debuglevel'        => [0, 3, 10],
    'errorlevel'        => [0, 3, 10],
    'installonly_limit' => [0, 3, 42],
    'mirrorlist_expire' => [0, 3, 42],
    'recent'            => [0, 3, 42],
    'retries'           => [0, 3, 42],
    'timeout'           => [0, 3, 42],
  }
  integer_params_valid.each do |param, valid|
    valid.each do |value|
      context "with #{param} set to valid #{value.class} <#{value}>" do
        let(:params) { { "#{param}": value } }

        it { is_expected.to contain_file('yum_config').with_content(%r{^\[main\][\s\S]*#{param}=#{value}$}) }
      end
    end

    # /!\ need to exclude parameters that do not defaults to undef
    # found no way to set undef successfully from here
    next unless param != 'debuglevel'
    context "with #{param} set to valid undef" do
      let(:params) { { "#{param}": :undef } }

      it { is_expected.to contain_file('yum_config').without_content(%r{#{param}=}) }
    end
  end

  # tests for integers with valid range
  integer_params_invalid = {
    'debuglevel'        => [-1, 11],
    'errorlevel'        => [-1, 11],
  }
  integer_params_invalid.each do |param, invalid|
    invalid.each do |value|
      context "with #{param} set to invalid #{value.class} <#{value}>" do
        let(:params) { { "#{param}": value } }

        it 'fails' do
          expect { is_expected.to contain_class(:subject) }.to raise_error(Puppet::Error, %r{Integer\[0, 10\]})
        end
      end
    end
  end

  # tests for general strings
  string_params = {
    'metadata_expire'   => [242, '242d', '242h', '242m', 'never'],
    'bugtracker_url'    => ['http://port.test', 'https://port.test', 'https://port.test:242'],
    'history_list_view' => ['cmds', 'commands', 'default', 'single-user-commands', 'users'],
    'http_caching'      => ['all', 'none', 'packages'],
    'mdpolicy'          => ['group:all', 'group:main', 'group:primary', 'group:small', 'instant'],
    'multilib_policy'   => ['all', 'best'],
    'password'          => ['string'],
    'proxy_password'    => ['string'],
    'proxy_username'    => ['string'],
    'proxy'             => ['http://port.test', 'https://port.test', 'https://port.test:242'],
    'rpmverbosity'      => ['critical', 'debug', 'emergency', 'error', 'info', 'warn'],
    'syslog_device'     => ['string'],
    'syslog_facility'   => ['string'],
    'syslog_ident'      => ['string'],
    'throttle'          => [2.42, 242, '2.42M'],
    'username'          => ['string'],
    'cachedir'          => ['/absolute/file_path', '/absolute/directory/', '/test/$basearch/$releasever'],
    'installroot'       => ['/absolute/file_path', '/absolute/directory/'],
    'logfile'           => ['/absolute/file_path', '/absolute/directory/'],
    'persistdir'        => ['/absolute/file_path', '/absolute/directory/'],
    'pluginconfpath'    => ['/absolute/file_path', '/absolute/directory/'],
    'pluginpath'        => ['/absolute/file_path', '/absolute/directory/'],
    'sslcacert'         => ['/absolute/file_path', '/absolute/directory/'],
    'sslclientcert'     => ['/absolute/file_path', '/absolute/directory/'],
    'sslclientkey'      => ['/absolute/file_path', '/absolute/directory/'],
    'pkgpolicy'         => ['last', 'newest'],
  }
  string_params.each do |param, valid|
    valid.each do |value|
      context "with #{param} set to valid #{value.class} <#{value}>" do
        let(:params) { { "#{param}": value } }

        it { is_expected.to contain_file('yum_config').with_content(%r{^\[main\][\s\S]*#{param}=#{Regexp.escape(value.to_s)}$}) }
      end
    end

    # /!\ need to exclude parameters that do not defaults to undef
    # found no way to set undef successfully from here
    next unless !%r{(metadata_expire|cachedir|logfile)}.match?(param)
    context "with #{param} set to valid undef" do
      let(:params) { { "#{param}": :undef } }

      it { is_expected.to contain_file('yum_config').without_content(%r{#{param}=}) }
    end
  end

  # distroverpkg also allows booleans
  # true will trigger a default value that is based on $::operatingsystem
  context 'with distroverpkg set to valid bool <true>' do
    let(:params) { { distroverpkg: true } }

    it { is_expected.to contain_file('yum_config').with_content(%r{^\[main\][\s\S]*distroverpkg=redhat-release$}) }
  end

  context 'with distroverpkg set to valid bool <true> when operatingsystem is CentOS' do
    let(:facts) { mandatory_facts.merge({ os: { name: 'CentOS' } }) }
    let(:params) { { distroverpkg: true } }

    it { is_expected.to contain_file('yum_config').with_content(%r{^\[main\][\s\S]*distroverpkg=centos-release$}) }
  end

  context 'with distroverpkg set to valid bool <false>' do
    let(:params) { { distroverpkg: false } }

    it { is_expected.to contain_file('yum_config').without_content(%r{distroverpkg=}) }
  end

  context 'with distroverpkg set to valid string <weirdos-releases>' do
    let(:params) { { distroverpkg: false } }

    it { is_expected.to contain_file('yum_config').without_content(%r{distroverpkg=weirdos-releases}) }
  end

  # test for params with default values
  context 'with cachedir unset' do
    it { is_expected.to contain_file('yum_config').with_content(%r{^\[main\][\s\S]*cachedir=/var/cache/yum/\$basearch/\$releasever}) }
  end

  context 'with logfile unset' do
    it { is_expected.to contain_file('yum_config').with_content(%r{^\[main\][\s\S]*logfile=/var/log/yum.log}) }
  end

  context 'with metadata_expire unset' do
    it { is_expected.to contain_file('yum_config').with_content(%r{\[main\][\s\S]*metadata_expire=6h}) }
  end

  # arrays with free content
  array_params = {
    'protected_packages'             => ['package1', 'package2'],
    'exclude'                        => ['package1', 'package2'],
    'installonlypkgs'                => ['package1', 'package2'],
    'kernelpkgnames'                 => ['package1', 'package2'],
    'history_record_packages'        => ['package1', 'package2'],
    'commands'                       => ['command1', 'command2'],
    'reposdir'                       => ['/absolute/file_path', '/absolute/directory/'],
  }
  array_params.each do |param, valid|
    context "with #{param} set to valid array #{valid}" do
      let(:params) { { "#{param}": valid } }

      it { is_expected.to contain_file('yum_config').with_content(%r{^\[main\][\s\S]*#{param}=#{valid.join(',')}$}) }
    end

    context "with #{param} unset" do
      it { is_expected.to contain_file('yum_config').without_content(%r{#{param}=}) }
    end
  end

  # arrays with content verification
  array_params = {
    'color_list_available_downgrade' => ['bg:black', 'fg:blue', 'bold'],
    'color_list_available_install'   => ['bg:black', 'fg:blue', 'bold'],
    'color_list_available_reinstall' => ['bg:black', 'fg:blue', 'bold'],
    'color_list_available_upgrade'   => ['bg:black', 'fg:blue', 'bold'],
    'color_list_installed_extra'     => ['bg:black', 'fg:blue', 'bold'],
    'color_list_installed_newer'     => ['bg:black', 'fg:blue', 'bold'],
    'color_list_installed_older'     => ['bg:black', 'fg:blue', 'bold'],
    'color_list_installed_reinstall' => ['bg:black', 'fg:blue', 'bold'],
    'color_search_match'             => ['bg:black', 'fg:blue', 'bold'],
    'color_update_installed'         => ['bg:black', 'fg:blue', 'bold'],
    'color_update_local'             => ['bg:black', 'fg:blue', 'bold'],
    'color_update_remote'            => ['bg:black', 'fg:blue', 'bold'],
    'group_package_types'            => ['default', 'mandatory', 'optional'],
    'tsflags'                        => ['justdb', 'nocontexts', 'nodocs', 'noscripts', 'notriggers', 'repackage', 'test'],
  }
  array_params.each do |param, valid|
    context "with #{param} set to valid array #{valid}" do
      let(:params) { { "#{param}": valid } }

      it { is_expected.to contain_file('yum_config').with_content(%r{^\[main\][\s\S]*#{param}=#{valid.join(',')}$}) }
    end

    context "with #{param} set to invalid array [invalid]" do
      let(:params) { { "#{param}": ['invalid'] } }

      it 'fails' do
        expect { is_expected.to contain_class(:subject) }.to raise_error(Puppet::Error, %r{yum::#{param} contains an invalid value. Valid values are})
      end
    end

    context "with #{param} unset" do
      it { is_expected.to contain_file('yum_config').without_content(%r{#{param}=}) }
    end
  end
  # </parameters for yum.conf>

  describe 'variable type and content validations' do
    # set needed custom facts and variables
    let(:facts) { mandatory_facts }
    let(:mandatory_params) { {} }

    validations = {
      'Array' => {
        name:    ['protected_packages', 'exclude', 'installonlypkgs', 'kernelpkgnames', 'history_record_packages', 'commands'],
        valid:   [['array']],
        invalid: ['string', { 'ha' => 'sh' }, 3, 2.42, false, nil],
        message: 'expects an Array', # Puppet 4 & 5
      },
      'Array for color_* parameters' => {
        name:    ['color_list_available_downgrade', 'color_list_available_install', 'color_list_available_reinstall', 'color_list_available_upgrade',
                  'color_list_installed_extra', 'color_list_installed_newer', 'color_list_installed_older', 'color_list_installed_reinstall',
                  'color_search_match', 'color_update_installed', 'color_update_local', 'color_update_remote'],
        valid:   [['bold', 'blink'], ['dim', 'reverse', 'underline'], ['fg:black', 'bg:red'], ['fg:green', 'bg:yellow'], ['fg:blue', 'fg:magenta'], ['fg:cyan', 'fg:white'] ],
        invalid: ['string', { 'ha' => 'sh' }, 3, 2.42, false],
        message: 'expects an Array', # Puppet 4 & 5
      },
      'Array for group_package_types' => {
        name:    ['group_package_types'],
        valid:   [['default'], ['optional'], ['mandatory'], ['default', 'mandatory', 'optional']],
        invalid: ['string', { 'ha' => 'sh' }, 3, 2.42, false],
        message: 'expects an Array', # Puppet 4 & 5
      },
      'Array for tsflags' => {
        name:    ['tsflags'],
        valid:   [['justdb'], ['nocontexts'], ['nodocs'], ['noscripts'], ['notriggers'], ['repackage'], ['test'], ['justdb', 'nocontexts'] ],
        invalid: ['string', { 'ha' => 'sh' }, 3, 2.42, false],
        message: 'expects an Array', # Puppet 4 & 5
      },
      'Array[Stdlib::Absolutepath] for reposdir' => {
        name:    ['reposdir'],
        valid:   [['/absolute/file_path', '/absolute/directory/'], ['/absolute/file_path'] ],
        invalid: [['../relative/path'], 'string', ['array'], { 'ha' => 'sh' }, 3, 2.42, false],
        message: '(expects a Stdlib::Absolutepath|expects an Array value)', # Puppet 4 & 5
      },
      'Boolean' => {
        name:    ['manage_repos', 'repos_hiera_merge', 'rpm_gpg_keys_hiera_merge', 'exactarch', 'gpgcheck', 'keepcache', 'obsoletes', 'plugins', 'tolerant'],
        valid:   [true, false],
        invalid: ['string', ['array'], { 'ha' => 'sh' }, 3, 2.42, 'false', nil],
        message: 'expects a Boolean value', # Puppet 4 & 5
      },
      'Boolean for exclude_hiera_merge' => {
        name:    ['exclude_hiera_merge'],
        facts:   { test: 'yum__exclude' },
        valid:   [true, false],
        invalid: ['string', ['array'], { 'ha' => 'sh' }, 3, 2.42, 'false', nil],
        message: 'expects a Boolean value', # Puppet 4 & 5
      },
      'Integer[0, 10]' => {
        name:    ['debuglevel'],
        valid:   [1, 10, :undef],
        invalid: ['242', 2.42, ['array'], { 'ha' => 'sh' }, false],
        message: '(expects an Integer|Integer\[0, 10\])',
      },
      'Optional[Boolean,String]' => {
        name:    ['distroverpkg'],
        valid:   [true, false, :undef, 'string'],
        invalid: [['array'], { 'ha' => 'sh' }, 3, 2.42],
        message: 'expects a value of type Undef, Boolean, or String', # Puppet 4 & 5
      },
      'Optional[Boolean]' => {
        name:    ['alwaysprompt', 'assumeyes', 'clean_requirements_on_remove', 'color', 'diskspacecheck', 'enable_group_conditionals',
                  'groupremove_leaf_only', 'history_record', 'keepalive', 'localpkg_gpgcheck', 'overwrite_groups', 'protected_multilib',
                  'repo_gpgcheck', 'reset_nice', 'showdupesfromrepos', 'skip_broken', 'ssl_check_cert_permissions', 'sslverify'],
        valid:   [true, false, :undef],
        invalid: ['string', ['array'], { 'ha' => 'sh' }, 3, 2.42, 'false'],
        message: 'expects a value of type Undef or Boolean', # Puppet 4 & 5
      },
      'Optional[Enum[]] for history_list_view' => {
        name:    ['history_list_view'],
        valid:   ['cmds', 'commands', 'default', 'users', 'single-user-commands'],
        invalid: ['string', ['array'], { 'ha' => 'sh' }, false],
        message: 'expects a(n undef value or a)? match for Enum', # Puppet (4) & 5
      },
      'Optional[Enum[]] for http_caching' => {
        name:    ['http_caching'],
        valid:   ['all', 'none', 'packages'],
        invalid: ['string', ['array'], { 'ha' => 'sh' }, false],
        message: 'expects a(n undef value or a)? match for Enum', # Puppet (4) & 5
      },
      'Optional[Enum[]] for mdpolicy' => {
        name:    ['mdpolicy'],
        valid:   ['group:all', 'group:main', 'group:primary', 'group:small', 'instant'],
        invalid: ['string', ['array'], { 'ha' => 'sh' }, false],
        message: 'expects a(n undef value or a)? match for Enum', # Puppet (4) & 5
      },
      'Optional[Enum[]] for multilib_policy' => {
        name:    ['multilib_policy'],
        valid:   ['all', 'best'],
        invalid: ['string', ['array'], { 'ha' => 'sh' }, false],
        message: 'expects a(n undef value or a)? match for Enum', # Puppet (4) & 5
      },
      'Optional[Enum[]] for pkgpolicy' => {
        name:    ['pkgpolicy'],
        valid:   ['newest', 'last'],
        invalid: ['string', ['array'], { 'ha' => 'sh' }, false],
        message: 'expects a(n undef value or a)? match for Enum', # Puppet (4) & 5
      },
      'Optional[Enum[]] for rpmverbosity' => {
        name:    ['rpmverbosity'],
        valid:   ['info', 'critical', 'emergency', 'error', 'warn', 'debug'],
        invalid: ['string', ['array'], { 'ha' => 'sh' }, false],
        message: 'expects a(n undef value or a)? match for Enum', # Puppet (4) & 5
      },
      'Optional[Hash]' => {
        name:    ['repos', 'rpm_gpg_keys'],
        params:  { repos_hiera_merge: false },
        valid:   [], # valid hashes are to complex to block test them here. Subclasses have their own specific spec tests anyway.
        invalid: ['string', 3, 2.42, ['array'], true, nil],
        message: 'expects a value of type Undef or Hash', # Puppet 4 & 5
      },
      'Optional[Integer]' => {
        name:    ['bandwidth', 'errorlevel', 'installonly_limit', 'mirrorlist_expire', 'recent', 'retries', 'timeout'],
        valid:   [1, 10, :undef],
        invalid: ['242', 2.42, ['array'], { 'ha' => 'sh' }, false],
        message: 'expects a value of type Undef or Integer', # Puppet 4 & 5
      },
      'Optional[Integer] (range 0..10 checked)' => {
        name:    ['errorlevel'],
        valid:   [], # tested above
        invalid: [-1, 11],
        message: 'expects a value of type Undef or Integer\[\d+, \d+\]', # Puppet 4 & 5
      },
      'Optional[Stdlib::Absolutepath]' => {
        name:    ['cachedir', 'installroot', 'logfile', 'persistdir', 'pluginconfpath', 'pluginpath', 'sslcacert', 'sslclientcert', 'sslclientkey'],
        valid:   ['/absolute/filepath', '/absolute/directory/'],
        invalid: ['../invalid', ['array'], { 'ha' => 'sh' }, 3, 2.42, false, nil],
        message: 'expects a (match for|match for Stdlib::Absolutepath =|Stdlib::Absolutepath =) Variant\[Stdlib::Windowspath.*Stdlib::Unixpath', # Puppet (4.x|5.0 & 5.1|5.x)
      },
      'Optional[Stdlib::Httpurl]' => {
        name:    ['proxy', 'bugtracker_url'],
        valid:   ['http://plain.test', 'https://secure.test', 'https://port.test:242'],
        invalid: ['string', ['array'], { 'ha' => 'sh' }, 3, 2.42, false, nil],
        message: 'expects a match for Stdlib::HTTPUrl', # Puppet 4 & 5
      },
      'Optional[String]' => {
        name:    ['password', 'proxy_password', 'proxy_username', 'syslog_device', 'syslog_facility', 'syslog_ident', 'username'],
        valid:   ['string'],
        invalid: [['array'], { 'ha' => 'sh' }, 3, 2.42, true],
        message: 'expects a value of type Undef or String', # Puppet 4 & 5
      },
      'Optional[Variant[Integer,Float,Pattern]]' => {
        name:    ['throttle'],
        valid:   [3, 2.42, '242k', '24.2M', '2.42G' ],
        invalid: [['array'], { 'ha' => 'sh' }, false],
        message: 'expects a value of type Undef, Integer, Float, or Pattern', # Puppet 4 & 5
      },
      'Optional[Variant[Integer,Pattern[]]]' => {
        name:    ['metadata_expire'],
        valid:   [3, '242m', '242h', '242d', 'never' ],
        invalid: [['array'], { 'ha' => 'sh' }, 2.42, false],
        message: 'expects a value of type Integer or Pattern', # Puppet 4 & 5
      },
      'Stdlib::Absolutepath' => {
        name:    ['config_path'],
        valid:   ['/absolute/filepath', '/absolute/directory/'],
        invalid: ['../invalid', ['array'], { 'ha' => 'sh' }, 3, 2.42, false, nil],
        message: 'expects a (match for|match for Stdlib::Absolutepath =|Stdlib::Absolutepath =) Variant\[Stdlib::Windowspath.*Stdlib::Unixpath', # Puppet (4.x|5.0 & 5.1|5.x)
      },
      'Stdlib::Filemode' => {
        name:    ['config_mode', 'repos_d_mode'],
        valid:   ['0644', '0755', '0640', '0740', '755'],
        invalid: [ 2770, '0844', '00644', 'string', ['array'], { 'ha' => 'sh' }, 3, 2.42, false, nil],
        message: 'expects a match for Stdlib::Filemode', # Puppet 4 & 5
      },
      'String' => {
        name:    ['config_owner', 'config_group', 'repos_d_owner', 'repos_d_group'],
        valid:   ['string'],
        invalid: [['array'], { 'ha' => 'sh' }, 3, 2.42, true],
        message: 'expects a String', # Puppet 4 & 5
      },
    }

    validations.sort.each do |type, var|
      var[:name].each do |var_name|
        var[:params] = {} if var[:params].nil?
        var[:valid].each do |valid|
          context "when #{var_name} (#{type}) is set to valid #{valid} (as #{valid.class})" do
            let(:facts) { [mandatory_facts, var[:facts]].reduce(:merge) } unless var[:facts].nil?
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
