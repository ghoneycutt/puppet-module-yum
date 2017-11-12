require 'puppetlabs_spec_helper/module_spec_helper'

RSpec.configure do |config|
  config.hiera_config = 'spec/fixtures/hiera/hiera.yaml'
  config.before :each do
    # Ensure that we don't accidentally cache facts and environment between
    # test cases.  This requires each example group to explicitly load the
    # facts being exercised with something like
    # Facter.collection.loader.load(:ipaddress)
    Facter.clear
    Facter.clear_messages
  end
  config.default_facts = {
    :environment     => 'testing',
    :operatingsystem => 'RedHat',
    :osfamily        => 'RedHat', # mandatory for Puppet service provider
    :os => {
      :release => {
        :major  => '5',
        :minor  => '10',
      }
    }
  }
end
