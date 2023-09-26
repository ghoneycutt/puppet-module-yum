require 'spec_helper'

describe 'yum::updatesd' do
  mandatory_facts = {
    fqdn: 'no-hiera-data.example.local',
    test: 'no-hiera-data',
    networking: {
      fqdn: 'no-hiera-data.example.local',
    },
    os: {
      name: 'RedHat',
      release: {
        full: '7',
      }
    }
  }
  mandatory_params = {}
  let(:facts) { mandatory_facts }
  let(:params) { mandatory_params }

  context 'with defaults for all parameters' do
    it do
      is_expected.to contain_package('yum_updatesd_package').with(
        {
          'ensure' => 'absent',
          'name'   => 'yum-updatesd',
        },
      )
    end
    it do
      is_expected.to contain_service('yum_updatesd_service').with(
        {
          'ensure' => 'stopped',
          'name'   => 'yum-updatesd',
          'enable' => 'false',
          'before' => 'Package[yum_updatesd_package]',
        },
      )
    end
  end

  context 'with updatesd_package set to valid string <spec-test>' do
    let(:params) { mandatory_params.merge({ updatesd_package: 'spec-test' }) }

    it { is_expected.to contain_package('yum_updatesd_package').with_name('spec-test') }
  end

  context 'with updatesd_package_ensure set to valid string <present>' do
    let(:params) { mandatory_params.merge({ updatesd_package_ensure: 'present' }) }

    it { is_expected.to contain_package('yum_updatesd_package').with_ensure('present') }
  end

  context 'with updatesd_service set to valid string <spec-test>' do
    let(:params) { mandatory_params.merge({ updatesd_service: 'spec-test' }) }

    it { is_expected.to contain_service('yum_updatesd_service').with_name('spec-test') }
  end

  context 'with updatesd_service_ensure set to valid string <running>' do
    let(:params) { mandatory_params.merge({ updatesd_service_ensure: 'running' }) }

    it { is_expected.to contain_service('yum_updatesd_service').with_ensure('running') }
  end

  context 'with updatesd_service_enable set to valid string <true>' do
    let(:params) { mandatory_params.merge({ updatesd_service_enable: 'true' }) }

    it { is_expected.to contain_service('yum_updatesd_service').with_enable('true') }
  end

  describe 'variable type and content validations' do
    # set needed custom facts and variables
    let(:facts) { mandatory_facts }
    let(:mandatory_params) { {} }

    validations = {
      'Stdlib::Ensure::Service' => {
        name:    ['updatesd_service_ensure'],
        valid:   ['running', 'stopped'],
        invalid: ['string', ['array'], { 'ha' => 'sh' }, 3, 2.42, false, nil],
        message: 'expects a match for Stdlib::Ensure::Service', # Puppet 4 & 5
      },
      'String' => {
        name:    ['updatesd_package', 'updatesd_service', 'updatesd_package_ensure'],
        valid:   ['string'],
        invalid: [['array'], { 'ha' => 'sh' }, 3, 2.42, false],
        message: 'expects a String', # Puppet 4 & 5
      },
      'Variant[String,Boolean]' => {
        name:    ['updatesd_service_enable'],
        valid:   ['false', 'true', true, false], # 'manual' & 'mask' needs specific features to be set
        invalid: [['array'], { 'ha' => 'sh' }, 3, 2.42],
        message: 'expects a value of type String or Boolean', # Puppet 4 & 5
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
