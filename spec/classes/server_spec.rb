require 'spec_helper'
describe 'yum::server' do
  mandatory_facts = {
    fqdn: 'no-hiera-data.example.local',
    hostname: 'no-hiera-data',
    test: 'no-hiera-data',
    ipaddress: '10.0.0.242',
    osfamily: 'RedHat',
    operatingsystemrelease: '7.0.1406',
    operatingsystem: 'RedHat',
    os: {
      family: 'RedHat',
      name:   'RedHat',
    },
    networking: {
      fqdn:     'no-hiera-data.example.local',
      hostname: 'no-hiera-data',
      ip:       '10.0.0.242',
    },
  }
  mandatory_params = {}
  let(:facts) { mandatory_facts }
  let(:params) { mandatory_params }

  context 'with defaults for all parameters' do
    it { is_expected.to contain_class('apache') }

    it { is_expected.to contain_package('createrepo').with_ensure('installed') }
    it { is_expected.to contain_package('hardlink').with_ensure('installed') }
    it do
      is_expected.to contain_file('gpg_keys_dir').with(
        {
          'ensure'  => 'directory',
          'path'    => '/opt/repos/keys',
          'recurse' => 'true',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
          'require' => 'Exec[mkdir_p-/opt/repos]',
        },
      )
    end
    it do
      is_expected.to contain_file('dot_rpmmacros').with(
        {
          'ensure' => 'file',
          'path'    => '/root/.rpmmacros',
          'content' => "%_gpg_name Root\n%_signature gpg\n",
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
        },
      )
    end
    it do
      is_expected.to contain_exec('mkdir_p-/opt/repos').with(
        {
          'command' => 'mkdir -p /opt/repos',
          'unless'      => 'test -d /opt/repos',
          'path'        => '/bin:/usr/bin',
        },
      )
    end
    it do
      is_expected.to contain_apache__vhost('yumrepo').with(
        {
          'docroot' => '/opt/repos',
          'port'          => '80',
          'vhost_name'    => '10.0.0.242',
          'servername'    => 'yum',
          'serveraliases' => [ 'no-hiera-data.example.local', 'no-hiera-data' ],
          'serveradmin'   => 'root@localhost',
          'options'       => ['Indexes', 'FollowSymLinks', 'MultiViews'],
          'override'      => ['AuthConfig'],
          'require'       => 'Exec[mkdir_p-/opt/repos]',
        },
      )
    end
  end

  context 'with contact_email set to valid string <spec@test.local>' do
    let(:params) { mandatory_params.merge({ contact_email: 'spec@test.local' }) }

    it { is_expected.to contain_apache__vhost('yumrepo').with_serveradmin('spec@test.local') }
  end

  context 'with docroot set to valid string </spec/tests>' do
    let(:params) { mandatory_params.merge({ docroot: '/spec/tests' }) }

    it do
      is_expected.to contain_file('gpg_keys_dir').with(
        {
          'path'    => '/spec/tests/keys',
          'require' => 'Exec[mkdir_p-/spec/tests]',
        },
      )
    end
    it do
      is_expected.to contain_exec('mkdir_p-/spec/tests').with(
        {
          'command' => 'mkdir -p /spec/tests',
          'unless' => 'test -d /spec/tests',
        },
      )
    end
    it do
      is_expected.to contain_apache__vhost('yumrepo').with(
        {
          'docroot' => '/spec/tests',
          'require' => 'Exec[mkdir_p-/spec/tests]',
        },
      )
    end
  end

  context 'with gpg_keys_path set to valid string <spectests>' do
    let(:params) { mandatory_params.merge({ gpg_keys_path: 'spectests' }) }

    it { is_expected.to contain_file('gpg_keys_dir').with_path('/opt/repos/spectests') }
  end

  context 'with gpg_user_name set to valid string <spectester>' do
    let(:params) { mandatory_params.merge({ gpg_user_name: 'spectester' }) }

    it { is_expected.to contain_file('dot_rpmmacros').with_content("%_gpg_name spectester\n%_signature gpg\n") }
  end

  context 'with servername set to valid string <jum>' do
    let(:params) { mandatory_params.merge({ servername: 'jum' }) }

    it { is_expected.to contain_apache__vhost('yumrepo').with_servername('jum') }
  end

  context 'with http_listen_ip set to valid string <10.242.242.242>' do
    let(:params) { mandatory_params.merge({ http_listen_ip: '10.242.242.242' }) }

    it { is_expected.to contain_apache__vhost('yumrepo').with_vhost_name('10.242.242.242') }
  end

  describe 'variable type and content validations' do
    # set needed custom facts and variables
    let(:facts) { mandatory_facts }
    let(:mandatory_params) { {} }

    validations = {
      'IP::Address::Nosubnet' => {
        name:    ['http_listen_ip'],
        valid:   ['127.0.0.1', '194.232.104.150', '3ffe:0505:0002::'],
        invalid: ['127.0.0.256', '23.43.9.22/64', ['array'], { 'ha' => 'sh' }, false],
        message: 'expects a( match for Variant\[| match for |n )IP::Address|value, got', # Puppet (4.x|5.0 & 5.1|5.x)
      },
      'Stdlib::Absolutepath' => {
        name:    ['docroot'],
        valid:   ['/absolute/filepath', '/absolute/directory/'],
        invalid: ['../invalid', ['array'], { 'ha' => 'sh' }, 3, 2.42, false, nil],
        message: 'expects a (match for|match for Stdlib::Absolutepath =|Stdlib::Absolutepath =) Variant\[Stdlib::Windowspath.*Stdlib::Unixpath', # Puppet (4.x|5.0 & 5.1|5.x)
      },
      'string' => {
        name:    ['contact_email', 'gpg_keys_path', 'gpg_user_name', 'servername'],
        valid:   ['string'],
        invalid: [['array'], { 'ha' => 'sh' }, false],
        message: 'expects a String', # Puppet 4 & 5
      },
      'array_of_strings_mininum_one' => {
        name:    ['serveraliases'],
        valid:   [['array'], ['ar', 'ray']],
        invalid: [[], { 'ha' => 'sh' }, false, 'string'],
        message: %r{expects an Array|expects size to be at least 1}, # Puppet 4 & 5
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
