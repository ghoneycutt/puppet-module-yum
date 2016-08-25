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

  context 'with updatesd_service_ensure set to valid string <spec-test>' do
    let(:params) { mandatory_params.merge({ :updatesd_service_ensure => 'latest' }) }
    it { should contain_service('yum_updatesd_service').with_ensure('latest') }
  end

  context 'with updatesd_service_enable set to valid boolean <true>' do
    let(:params) { mandatory_params.merge({ :updatesd_service_enable => true }) }
    it { should contain_service('yum_updatesd_service').with_enable('true') }
  end
end
