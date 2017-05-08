require 'spec_helper'
describe 'yum' do
  mandatory_facts = {
    :fqdn                => 'no-hiera-data.example.local',
    :test                => 'no-hiera-data',
    :environment         => 'rp_env',
    :operatingsystem     => 'RedHat',
    :lsbmajdistrelease   => '5',
    :lsbminordistrelease => '10',
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
      |keepcache=0
      |debuglevel=2
      |logfile=/var/log/yum.log
      |tolerant=1
      |exactarch=1
      |obsoletes=1
      |gpgcheck=1
      |plugins=1
      |
      |# Note: yum-RHN-plugin doesn't honor this.
      |metadata_expire=1h
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
            'gpgcheck'          => '1',
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
        'gpgcheck' => '1',
      })
    end

    it do
      should contain_yum__repo('test').with({
        'repo_file_mode' => '0242',
      })
    end
  end

  context 'with distroverpkg set to valid bool <true>' do
    let(:params) { { :distroverpkg => true } }
    it { should contain_file('yum_config').with_content(/\[main\]\ndistroverpkg=redhat-release$/) }
  end

  context 'with pkgpolicy set to valid string <newest>' do
    let(:params) { { :pkgpolicy => 'newest' } }
    it { should contain_file('yum_config').with_content(/\[main\]\npkgpolicy=newest$/) }
  end

  context 'with proxy set to valid string <https://rspec.test:3128>' do
    let(:params) { { :proxy => 'https://rspec.test:3128' } }
    it { should contain_file('yum_config').with_content(%r{\[main\]\nproxy=https://rspec.test:3128$}) }
  end

  context 'with exclude set to valid string <foo>' do
    let(:params) { { :exclude => 'foo' } }
    it { should contain_file('yum_config').with_content(%r{^exclude=foo$}) }
  end

  context "with exclude set to valid array ['foo*', 'bar']" do
    let(:params) { { :exclude => ['foo*', 'bar'] } }
    it { should contain_file('yum_config').with_content(%r{^exclude=foo\* bar$}) }
  end

  [242, '242'].each do |value|
    context "with installonly_limit set to valid <242> (as #{value.class})" do
      let(:params) { { :installonly_limit => value } }
      it { should contain_file('yum_config').with_content(/\[main\]\ninstallonly_limit=242$/) }
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
      it { should contain_file('yum_config').with_content(%r{^exclude=from_hiera_fqdn from_hiera_test$}) }
    end
  end

  describe 'variable type and content validations' do
    # set needed custom facts and variables
    let(:facts) { mandatory_facts }
    let(:mandatory_params) { {} }

    validations = {
      'absolute_path' => {
        :name    => %w(config_path),
        :valid   => ['/absolute/filepath', '/absolute/directory/'],
        :invalid => ['../invalid', %w(array), { 'ha' => 'sh' }, 3, 2.42, true, false, nil],
        :message => 'is not an absolute path',
      },
      'bool and stringified' => {
        :name    => %w(distroverpkg exclude_hiera_merge manage_repos repos_hiera_merge),
        :valid   => [true, false, 'true', 'false'],
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, 3, 2.42, nil],
        :message => '(is not a boolean|Unknown type of boolean given|str2bool)',
      },
      'hash' => {
        :name    => %w(repos),
        :params  => { :repos_hiera_merge => false },
        :valid   => [], # valid hashes are to complex to block test them here. Subclasses have their own specific spec tests anyway.
        :invalid => ['string', 3, 2.42, %w(array), true, false, nil],
        :message => 'is not a Hash',
      },
      'integer and stringified' => {
        :name    => %w(installonly_limit),
        :valid   => [242, '242'],
        :invalid => ['string', 2.42, %w(array), { 'ha' => 'sh' }, true, false, nil],
        :message => '(is not an integer nor stringified integer|floor\(\): Wrong argument type)',
      },
      'regex for mode' => {
        :name    => %w(config_mode repos_d_mode),
        :valid   => %w(0644 0755 0640 0740),
        :invalid => ['0844', '755', '00644', 'string', %w(array), { 'ha' => 'sh' }, 3, 2.42, true, false, nil],
        :message => 'is not a file mode in octal notation',
      },
      'regex for pkgpolicy' => {
        :name    => %w(pkgpolicy),
        :valid   => %w(newest last),
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, 3, 2.42, true, false, nil],
        :message => 'must be <newest> or <last>',
      },
      # /!\ Downgrade for Puppet 3.x: remove fixnum and float from invalid list
      'string' => {
        :name    => %w(config_owner config_group repos_d_owner repos_d_group proxy),
        :valid   => ['string'],
        :invalid => [%w(array), { 'ha' => 'sh' }, true, false],
        :message => 'is not a string',
      },
      'string and array' => {
        :name    => %w(exclude),
        :valid   => ['string', %w(array)],
        :invalid => [{ 'ha' => 'sh' }, true, false],
        :message => 'must be either a string or an array',
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
