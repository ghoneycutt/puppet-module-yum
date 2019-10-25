require 'spec_helper'
describe 'yum' do
  mandatory_facts = {
    :fqdn                => 'no-hiera-data.example.local',
    :test                => 'no-hiera-data',
  }
  mandatory_params = {}
  let(:facts) { mandatory_facts }
  let(:params) { mandatory_params }

  context 'with defaults for all parameters' do
    it { should contain_class('yum') }
    it { should contain_class('yum::updatesd') }

    it { should have_yum__repo_resource_count(0) }
    it { should contain_package('yum').with_ensure('installed') }

    content = <<-END.gsub(/^\s+\|/, '')
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
      should contain_file('yum_config').with({
        'ensure'  => 'file',
        'path'    => '/etc/yum.conf',
        'content' => content,
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
        'require' => 'Package[yum]',
      })
    end

    it do
      should contain_file('/etc/yum.repos.d').with({
        'ensure'  => 'directory',
        'purge'   => 'false',
        'recurse' => 'false',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0755',
        'require' => 'File[yum_config]',
        'notify'  => 'Exec[clean_yum_cache]',
      })
    end

    it do
      should contain_exec('clean_yum_cache').with({
        'command'     => 'yum clean all',
        'path'        => '/bin:/usr/bin:/sbin:/usr/sbin',
        'refreshonly' => 'true',
      })
    end
  end

  context 'with config_path set to valid string </spec/test>' do
    let(:params) { { :config_path => '/spec/test' } }

    it { should contain_file('yum_config').with_path('/spec/test') }
  end

  context 'with config_owner set to valid string <john>' do
    let(:params) { { :config_owner => 'john' } }

    it { should contain_file('yum_config').with_owner('john') }
  end

  context 'with config_group set to valid string <doe>' do
    let(:params) { { :config_group => 'doe' } }

    it { should contain_file('yum_config').with_group('doe') }
  end

  context 'with config_mode set to valid string <0242>' do
    let(:params) { { :config_mode => '0242' } }

    it { should contain_file('yum_config').with_mode('0242') }
  end

  context 'with manage_repos set to valid boolean <true>' do
    let(:params) { { :manage_repos => true } }

    it do
      should contain_file('/etc/yum.repos.d').with({
        'purge'   => 'true',
        'recurse' => 'true',
      })
    end
  end

  context 'with repos_d_owner set to valid string <john>' do
    let(:params) { { :repos_d_owner => 'john' } }

    it { should contain_file('/etc/yum.repos.d').with_owner('john') }
  end

  context 'with repos_d_group set to valid string <doe>' do
    let(:params) { { :repos_d_group => 'doe' } }

    it { should contain_file('/etc/yum.repos.d').with_group('doe') }
  end

  context 'with repos_d_mode set to valid string <0242>' do
    let(:params) { { :repos_d_mode => '0242' } }

    it { should contain_file('/etc/yum.repos.d').with_mode('0242') }
  end

  context 'with repos set to valid hash when hiera merge is disabled' do
    let(:params) do
      {
        :repos_hiera_merge => false,
        :repos => {
          'rspec' => {
            'gpgcheck'          => false,
          },
          'test' => {
            'repo_file_mode'    => '0242',
          }
        }
      }
    end

    it { should have_yum__repo_resource_count(2) }

    it do
      should contain_yum__repo('rspec').with({
        'gpgcheck' => false,
      })
    end

    it do
      should contain_yum__repo('test').with({
        'repo_file_mode' => '0242',
      })
    end
  end

  context 'with rpm_gpg_keys set to valid hash when hiera merge is disabled' do
    let(:params) do
      {
        :rpm_gpg_keys_hiera_merge => false,
        :rpm_gpg_keys => {
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

    it { should have_yum__rpm_gpg_key_resource_count(2) }

    it do
      should contain_yum__rpm_gpg_key('rspec').with({
        'gpgkey'     => '/etc/pki/rpm-gpg/RPM-GPG-KEY-RSPEC',
        'gpgkey_url' => 'http://yum.domain.tld/keys/RPM-GPG-KEY-RSPEC',
      })
    end

    it do
      should contain_yum__rpm_gpg_key('test').with({
        'gpgkey'     => '/etc/pki/rpm-gpg/RPM-GPG-KEY-TEST',
        'gpgkey_url' => 'http://yum.domain.tld/keys/RPM-GPG-KEY-TEST',
      })
    end
  end

  describe 'with hiera providing data from multiple levels for the repos parameter' do
    let(:facts) do
      mandatory_facts.merge({
        :fqdn => 'yum.example.local',
        :test => 'yum__repos',
      })
    end

    context 'with defaults for all parameters' do
      it { should have_yum__repo_resource_count(2) }
      it { should contain_yum__repo('from_hiera_class') }
      it { should contain_yum__repo('from_hiera_fqdn') }
    end

    context 'with repos_hiera_merge set to valid <false>' do
      let(:params) { { :repos_hiera_merge => false } }
      it { should have_yum__repo_resource_count(1) }
      it { should contain_yum__repo('from_hiera_fqdn') }
    end
  end

  describe 'with hiera providing data from multiple levels for the rpm_gpg_keys parameter' do
    let(:facts) do
      mandatory_facts.merge({
        :fqdn => 'yum.example.local',
        :test => 'yum__rpm_gpg_keys',
      })
    end

    context 'with defaults for all parameters' do
      it { should have_yum__rpm_gpg_key_resource_count(2) }
      it { should contain_yum__rpm_gpg_key('from_hiera_class') }
      it { should contain_yum__rpm_gpg_key('from_hiera_fqdn') }
    end

    context 'with repos_hiera_merge set to valid <false>' do
      let(:params) { { :rpm_gpg_keys_hiera_merge => false } }
      it { should have_yum__rpm_gpg_key_resource_count(1) }
      it { should contain_yum__rpm_gpg_key('from_hiera_fqdn') }
    end
  end

  describe 'with hiera providing data from multiple levels for the exclude parameter' do
    let(:facts) do
      mandatory_facts.merge({
        :fqdn => 'yum.example.local',
        :test => 'yum__exclude',
      })
    end

    context 'with defaults for all parameters' do
      it { should contain_file('yum_config').with_content(%r{^exclude=from_hiera_fqdn$}) }
    end

    context 'with exclude_hiera_merge set to valid <true>' do
      let(:params) { { :exclude_hiera_merge => true } }
      it { should contain_file('yum_config').with_content(%r{^exclude=from_hiera_fqdn,from_hiera_test$}) }
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
    [true, false,:undef].each do |value|
      context "with #{param} set to valid #{value.class} <#{value}>" do
        let(:params) { { :"#{param}" => value } }
        if value == true
          it { should contain_file('yum_config').with_content(%r{^\[main\][\s\S]*#{param}=1$}) }
        elsif value == false
          it { should contain_file('yum_config').with_content(%r{^\[main\][\s\S]*#{param}=0$}) }
        else
          it { should contain_file('yum_config').without_content(%r{#{param}=$}) }
        end
      end
    end
    context "with #{param} unset" do
      if default == true
        it { should contain_file('yum_config').with_content(%r{^\[main\][\s\S]*#{param}=1}) }
      elsif default == false
        it { should contain_file('yum_config').with_content(%r{^\[main\][\s\S]*#{param}=0}) }
      else
        it { should contain_file('yum_config').without_content(%r{#{param}=}) }
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
        let(:params) { { :"#{param}" => value } }
        it { should contain_file('yum_config').with_content(%r{^\[main\][\s\S]*#{param}=#{value}$}) }
      end
    end

    # /!\ need to exclude parameters that do not defaults to undef
    # found no way to set undef successfully from here
    if param != 'debuglevel'
      context "with #{param} set to valid undef" do
        let(:params) { { :"#{param}" => :undef } }
        it { should contain_file('yum_config').without_content(%r{#{param}=}) }
      end
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
        let(:params) { { :"#{param}" => value } }
        it 'should fail' do
          expect { should contain_class(subject) }.to raise_error(Puppet::Error, %r{expects a value of type Undef or Integer\[\d+, \d+\]})
        end
      end
    end
  end

  # tests for general strings
  string_params = {
    'metadata_expire'   => [242, '242d','242h','242m','never'],
    'bugtracker_url'    => %w(http://port.test https://port.test https://port.test:242),
    'history_list_view' => %w(cmds commands default single-user-commands users),
    'http_caching'      => %w(all none packages),
    'mdpolicy'          => %w(group:all group:main group:primary group:small instant),
    'multilib_policy'   => %w(all best),
    'password'          => %w(string),
    'proxy_password'    => %w(string),
    'proxy_username'    => %w(string),
    'proxy'             => %w(http://port.test https://port.test https://port.test:242),
    'rpmverbosity'      => %w(critical debug emergency error info warn),
    'syslog_device'     => %w(string),
    'syslog_facility'   => %w(string),
    'syslog_ident'      => %w(string),
    'throttle'          => [2.42, 242, '2.42M'],
    'username'          => %w(string),
    'cachedir'          => %w(/absolute/file_path /absolute/directory/ /test/$basearch/$releasever),
    'installroot'       => %w(/absolute/file_path /absolute/directory/),
    'logfile'           => %w(/absolute/file_path /absolute/directory/),
    'persistdir'        => %w(/absolute/file_path /absolute/directory/),
    'pluginconfpath'    => %w(/absolute/file_path /absolute/directory/),
    'pluginpath'        => %w(/absolute/file_path /absolute/directory/),
    'sslcacert'         => %w(/absolute/file_path /absolute/directory/),
    'sslclientcert'     => %w(/absolute/file_path /absolute/directory/),
    'sslclientkey'      => %w(/absolute/file_path /absolute/directory/),
    'pkgpolicy'         => %w(last newest),
  }
  string_params.each do |param, valid|
    valid.each do |value|
      context "with #{param} set to valid #{value.class} <#{value}>" do
        let(:params) { { :"#{param}" => value } }
        it { should contain_file('yum_config').with_content(%r{^\[main\][\s\S]*#{param}=#{Regexp.escape(value.to_s)}$}) }
      end
    end

    # /!\ need to exclude parameters that do not defaults to undef
    # found no way to set undef successfully from here
    if param !~ /(metadata_expire|cachedir|logfile)/
      context "with #{param} set to valid undef" do
        let(:params) { { :"#{param}" => :undef } }
        it { should contain_file('yum_config').without_content(%r{#{param}=}) }
      end
    end
  end

  # distroverpkg also allows booleans
  # true will trigger a default value that is based on $::operatingsystem
  context 'with distroverpkg set to valid bool <true>' do
    let(:params) { { :distroverpkg => true } }
    it { should contain_file('yum_config').with_content(%r{^\[main\][\s\S]*distroverpkg=redhat-release$}) }
  end

  context 'with distroverpkg set to valid bool <true> when operatingsystem is CentOS' do
    let(:facts) { mandatory_facts.merge({ :operatingsystem => 'CentOS' }) }
    let(:params) { { :distroverpkg => true } }
    it { should contain_file('yum_config').with_content(%r{^\[main\][\s\S]*distroverpkg=centos-release$}) }
  end

  context 'with distroverpkg set to valid bool <false>' do
    let(:params) { { :distroverpkg => false } }
    it { should contain_file('yum_config').without_content(%r{distroverpkg=}) }
  end

  context 'with distroverpkg set to valid string <weirdos-releases>' do
    let(:params) { { :distroverpkg => false } }
    it { should contain_file('yum_config').without_content(%r{distroverpkg=weirdos-releases}) }
  end

  # test for params with default values
  context 'with cachedir unset' do
    it { should contain_file('yum_config').with_content(%r{^\[main\][\s\S]*cachedir=/var/cache/yum/\$basearch/\$releasever}) }
  end

  context 'with logfile unset' do
    it { should contain_file('yum_config').with_content(%r{^\[main\][\s\S]*logfile=/var/log/yum.log}) }
  end

  context 'with metadata_expire unset' do
    it { should contain_file('yum_config').with_content(%r{\[main\][\s\S]*metadata_expire=6h}) }
  end

  # arrays with free content
  array_params = {
    'protected_packages'             => %w(package1 package2),
    'exclude'                        => %w(package1 package2),
    'installonlypkgs'                => %w(package1 package2),
    'kernelpkgnames'                 => %w(package1 package2),
    'history_record_packages'        => %w(package1 package2),
    'commands'                       => %w(command1 command2),
    'reposdir'                       => %w(/absolute/file_path /absolute/directory/),
  }
  array_params.each do |param, valid|
    context "with #{param} set to valid array #{valid}" do
      let(:params) { { :"#{param}" => valid } }
      it { should contain_file('yum_config').with_content(%r{^\[main\][\s\S]*#{param}=#{valid.join(',')}$}) }
    end

    context "with #{param} unset" do
      it { should contain_file('yum_config').without_content(%r{#{param}=}) }
    end
  end

  # arrays with content verification
  array_params = {
    'color_list_available_downgrade' => %w(bg:black fg:blue bold),
    'color_list_available_install'   => %w(bg:black fg:blue bold),
    'color_list_available_reinstall' => %w(bg:black fg:blue bold),
    'color_list_available_upgrade'   => %w(bg:black fg:blue bold),
    'color_list_installed_extra'     => %w(bg:black fg:blue bold),
    'color_list_installed_newer'     => %w(bg:black fg:blue bold),
    'color_list_installed_older'     => %w(bg:black fg:blue bold),
    'color_list_installed_reinstall' => %w(bg:black fg:blue bold),
    'color_search_match'             => %w(bg:black fg:blue bold),
    'color_update_installed'         => %w(bg:black fg:blue bold),
    'color_update_local'             => %w(bg:black fg:blue bold),
    'color_update_remote'            => %w(bg:black fg:blue bold),
    'group_package_types'            => %w(default mandatory optional),
    'tsflags'                        => %w(justdb nocontexts nodocs noscripts notriggers repackage test),
  }
  array_params.each do |param, valid|
    context "with #{param} set to valid array #{valid}" do
      let(:params) { { :"#{param}" => valid } }
      it { should contain_file('yum_config').with_content(%r{^\[main\][\s\S]*#{param}=#{valid.join(',')}$}) }
    end

    context "with #{param} set to invalid array [invalid]" do
      let(:params) { { :"#{param}" => %w(invalid) } }
      it 'should fail' do
        expect { should contain_class(subject) }.to raise_error(Puppet::Error, /yum::#{param} contains an invalid value. Valid values are/)
      end
    end

    context "with #{param} unset" do
      it { should contain_file('yum_config').without_content(%r{#{param}=}) }
    end
  end
  # </parameters for yum.conf>

  describe 'variable type and content validations' do
    # set needed custom facts and variables
    let(:facts) { mandatory_facts }
    let(:mandatory_params) { {} }

    validations = {
      'Array' => {
        :name    => %w(protected_packages exclude installonlypkgs kernelpkgnames history_record_packages commands),
        :valid   => [%w(array)],
        :invalid => ['string', { 'ha' => 'sh' }, 3, 2.42, false, nil],
        :message => 'expects an Array', # Puppet 4 & 5
      },
      'Array for color_* parameters' => {
        :name    => %w(color_list_available_downgrade color_list_available_install color_list_available_reinstall color_list_available_upgrade color_list_installed_extra color_list_installed_newer color_list_installed_older color_list_installed_reinstall color_search_match color_update_installed color_update_local color_update_remote),
        :valid   => [%w(bold blink), %w(dim reverse underline), %w(fg:black bg:red), %w(fg:green bg:yellow), %w(fg:blue fg:magenta), %w(fg:cyan fg:white) ],
        :invalid => ['string', { 'ha' => 'sh' }, 3, 2.42, false],
        :message => 'expects an Array', # Puppet 4 & 5
      },
      'Array for group_package_types' => {
        :name    => %w(group_package_types),
        :valid   => [%w(default), %W(optional), %w(mandatory), %w(default mandatory optional)],
        :invalid => ['string', { 'ha' => 'sh' }, 3, 2.42, false],
        :message => 'expects an Array', # Puppet 4 & 5
      },
      'Array for tsflags' => {
        :name    => %w(tsflags),
        :valid   => [%w(justdb), %w(nocontexts), %w(nodocs), %w(noscripts), %w(notriggers), %w(repackage), %w(test), %w(justdb nocontexts), ],
        :invalid => ['string', { 'ha' => 'sh' }, 3, 2.42, false],
        :message => 'expects an Array', # Puppet 4 & 5
      },
      'Array[Stdlib::Absolutepath] for reposdir' => {
        :name    => %w(reposdir),
        :valid   => [%w(/absolute/file_path /absolute/directory/), %w(/absolute/file_path) ],
        :invalid => [%w(../relative/path), 'string', %w(array), { 'ha' => 'sh' }, 3, 2.42, false],
        :message => '(expects an Array|expects a (match for|match for Stdlib::Absolutepath =|Stdlib::Absolutepath =) Variant\[Stdlib::Windowspath.*Stdlib::Unixpath)', # (non array cases Puppet 4 & 5 | array cases Puppet (4.x|5.0 & 5.1|5.x))
      },
      'Boolean' => {
        :name    => %w(manage_repos repos_hiera_merge rpm_gpg_keys_hiera_merge),
        :valid   => [true, false],
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, 3, 2.42, 'false', nil],
        :message => 'expects a Boolean value', # Puppet 4 & 5
      },
      'Boolean for exclude_hiera_merge' => {
        :name    => %w(exclude_hiera_merge),
        :facts   => { :test => 'yum__exclude' },
        :valid   => [true, false],
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, 3, 2.42, 'false', nil],
        :message => 'expects a Boolean value', # Puppet 4 & 5
      },
      'Optional[Boolean,String]' => {
        :name    => %w(distroverpkg),
        :valid   => [true, false, :undef, 'string'],
        :invalid => [%w(array), { 'ha' => 'sh' }, 3, 2.42],
        :message => 'expects a value of type Undef, Boolean, or String', # Puppet 4 & 5
      },
      'Optional[Boolean]' => {
        :name    => %w(exactarch gpgcheck keepcache obsoletes plugins tolerant alwaysprompt assumeyes clean_requirements_on_remove color diskspacecheck enable_group_conditionals groupremove_leaf_only history_record keepalive localpkg_gpgcheck overwrite_groups protected_multilib repo_gpgcheck reset_nice showdupesfromrepos skip_broken ssl_check_cert_permissions sslverify),
        :valid   => [true, false, :undef],
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, 3, 2.42, 'false'],
        :message => 'expects a value of type Undef or Boolean', # Puppet 4 & 5
      },
      'Optional[Enum[]] for history_list_view' => {
        :name    => %w(history_list_view),
        :valid   => %w(cmds commands default users single-user-commands),
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, false],
        :message => 'expects a(n undef value or a)? match for Enum', # Puppet (4) & 5
      },
      'Optional[Enum[]] for http_caching' => {
        :name    => %w(http_caching),
        :valid   => %w(all none packages),
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, false],
        :message => 'expects a(n undef value or a)? match for Enum', # Puppet (4) & 5
      },
      'Optional[Enum[]] for mdpolicy' => {
        :name    => %w(mdpolicy),
        :valid   => %w(group:all group:main group:primary group:small instant),
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, false],
        :message => 'expects a(n undef value or a)? match for Enum', # Puppet (4) & 5
      },
      'Optional[Enum[]] for multilib_policy' => {
        :name    => %w(multilib_policy),
        :valid   => %w(all best),
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, false],
        :message => 'expects a(n undef value or a)? match for Enum', # Puppet (4) & 5
      },
      'Optional[Enum[]] for pkgpolicy' => {
        :name    => %w(pkgpolicy),
        :valid   => %w(newest last),
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, false],
        :message => 'expects a(n undef value or a)? match for Enum', # Puppet (4) & 5
      },
      'Optional[Enum[]] for rpmverbosity' => {
        :name    => %w(rpmverbosity),
        :valid   => %w(info critical emergency error warn debug),
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, false],
        :message => 'expects a(n undef value or a)? match for Enum', # Puppet (4) & 5
      },
      'Optional[Hash]' => {
        :name    => %w(repos rpm_gpg_keys),
        :params  => { :repos_hiera_merge => false },
        :valid   => [], # valid hashes are to complex to block test them here. Subclasses have their own specific spec tests anyway.
        :invalid => ['string', 3, 2.42, %w(array), true, nil],
        :message => 'expects a value of type Undef or Hash', # Puppet 4 & 5
      },
      'Optional[Integer]' => {
        :name    => %w(bandwidth debuglevel errorlevel installonly_limit mirrorlist_expire recent retries timeout),
        :valid   => [1, 10, :undef],
        :invalid => ['242', 2.42, %w(array), { 'ha' => 'sh' }, false],
        :message => 'expects a value of type Undef or Integer', # Puppet 4 & 5
      },
      'Optional[Integer] (range 0..10 checked)' => {
        :name    => %w(debuglevel errorlevel),
        :valid   => [], # tested above
        :invalid => [-1, 11],
        :message => 'expects a value of type Undef or Integer\[\d+, \d+\]', # Puppet 4 & 5
      },
      'Optional[Stdlib::Absolutepath]' => {
        :name    => %w(cachedir installroot logfile persistdir pluginconfpath pluginpath sslcacert sslclientcert sslclientkey),
        :valid   => ['/absolute/filepath', '/absolute/directory/'],
        :invalid => ['../invalid', %w(array), { 'ha' => 'sh' }, 3, 2.42, false, nil],
        :message => 'expects a (match for|match for Stdlib::Absolutepath =|Stdlib::Absolutepath =) Variant\[Stdlib::Windowspath.*Stdlib::Unixpath', # Puppet (4.x|5.0 & 5.1|5.x)
      },
      'Optional[Stdlib::Httpurl]' => {
        :name    => %w(proxy bugtracker_url),
        :valid   => %w(http://plain.test https://secure.test https://port.test:242),
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, 3, 2.42, false, nil],
        :message => 'expects a match for Stdlib::HTTPUrl',  # Puppet 4 & 5
      },
      'Optional[String]' => {
        :name    => %w(password proxy_password proxy_username syslog_device syslog_facility syslog_ident username),
        :valid   => ['string'],
        :invalid => [%w(array), { 'ha' => 'sh' }, 3, 2.42, true],
        :message => 'expects a value of type Undef or String',  # Puppet 4 & 5
      },
      'Optional[Variant[Integer,Float,Pattern]]' => {
        :name    => %w(throttle),
        :valid   => [3, 2.42, '242k', '24.2M', '2.42G' ],
        :invalid => [%w(array), { 'ha' => 'sh' }, false],
        :message => 'expects a value of type Undef, Integer, Float, or Pattern', # Puppet 4 & 5
      },
      'Optional[Variant[Integer,Pattern[]]]' => {
        :name    => %w(metadata_expire),
        :valid   => [3, '242m', '242h', '242d', 'never' ],
        :invalid => [%w(array), { 'ha' => 'sh' }, 2.42, false],
        :message => 'expects a value of type Undef, Integer, or Pattern', # Puppet 4 & 5
      },
      'Stdlib::Absolutepath' => {
        :name    => %w(config_path),
        :valid   => ['/absolute/filepath', '/absolute/directory/'],
        :invalid => ['../invalid', %w(array), { 'ha' => 'sh' }, 3, 2.42, false, nil],
        :message => 'expects a (match for|match for Stdlib::Absolutepath =|Stdlib::Absolutepath =) Variant\[Stdlib::Windowspath.*Stdlib::Unixpath', # Puppet (4.x|5.0 & 5.1|5.x)
      },
      'Stdlib::Filemode' => {
        :name    => %w(config_mode repos_d_mode),
        :valid   => %w(0644 0755 0640 0740 755),
        :invalid => [ 2770, '0844', '00644', 'string', %w(array), { 'ha' => 'sh' }, 3, 2.42, false, nil],
        :message => 'expects a match for Stdlib::Filemode',  # Puppet 4 & 5
      },
      'String' => {
        :name    => %w(config_owner config_group repos_d_owner repos_d_group),
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
            let(:facts) { [mandatory_facts, var[:facts]].reduce(:merge) } if ! var[:facts].nil?
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
