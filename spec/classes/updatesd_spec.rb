require 'spec_helper'

describe 'yum::updatesd' do
  mandatory_facts = {
    :fqdn => 'no-hiera-data.example.local',
    :test => 'no-hiera-data',
  }
  mandatory_params = {}
  let(:facts) { mandatory_facts }
  let(:params) { mandatory_params }

  context 'with defaults for all parameters' do
    it do
      should contain_package('yum_updatesd_package').with({
        'ensure' => 'absent',
        'name'   => 'yum-updatesd',
      })
    end
    it do
      should contain_service('yum_updatesd_service').with({
        'ensure' => 'stopped',
        'name'   => 'yum-updatesd',
        'enable' => 'false',
        'before' => 'Package[yum_updatesd_package]',
      })
    end
  end

  context 'with updatesd_package set to valid string <spec-test>' do
    let(:params) { mandatory_params.merge({ :updatesd_package => 'spec-test' }) }
    it { should contain_package('yum_updatesd_package').with_name('spec-test') }
  end

  context 'with updatesd_package_ensure set to valid string <present>' do
    let(:params) { mandatory_params.merge({ :updatesd_package_ensure => 'present' }) }
    it { should contain_package('yum_updatesd_package').with_ensure('present') }
  end

  context 'with updatesd_service set to valid string <spec-test>' do
    let(:params) { mandatory_params.merge({ :updatesd_service => 'spec-test' }) }
    it { should contain_service('yum_updatesd_service').with_name('spec-test') }
  end

  context 'with updatesd_service_ensure set to valid string <running>' do
    let(:params) { mandatory_params.merge({ :updatesd_service_ensure => 'running' }) }
    it { should contain_service('yum_updatesd_service').with_ensure('running') }
  end

  context 'with updatesd_service_enable set to valid string <true>' do
    let(:params) { mandatory_params.merge({ :updatesd_service_enable => 'true' }) }
    it { should contain_service('yum_updatesd_service').with_enable('true') }
  end

  describe 'variable type and content validations' do
    # set needed custom facts and variables
    let(:facts) { mandatory_facts }
    let(:mandatory_params) { {} }

    validations = {
      'regex for package ensure' => {
        :name    => %w(updatesd_package_ensure),
        :valid   => %w(absent latest present purged),
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, 3, 2.42, false, nil],
        :message => 'expects a match for Enum\[\'absent\', \'latest\', \'present\', \'purged\'\]', # Puppet 4 & 5
      },
      'regex for service enable' => {
        :name    => %w(updatesd_service_enable),
        :valid   => %w(false manual mark true),
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, 3, 2.42, false, nil],
        :message => 'expects a match for Enum\[\'false\', \'manual\', \'mark\', \'true\'\]', # Puppet 4 & 5
      },
      'regex for service ensure' => {
        :name    => %w(updatesd_service_ensure),
        :valid   => %w(running stopped),
        :invalid => ['string', %w(array), { 'ha' => 'sh' }, 3, 2.42, false, nil],
        :message => 'expects a match for Enum\[\'running\', \'stopped\'\]', # Puppet 4 & 5
      },
      'string' => {
        :name    => %w(updatesd_package updatesd_service),
        :valid   => ['string'],
        :invalid => [%w(array), { 'ha' => 'sh' }, 3, 2.42, false],
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
