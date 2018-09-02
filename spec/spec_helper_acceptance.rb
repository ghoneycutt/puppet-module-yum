require 'beaker-rspec'
require 'beaker-puppet'
require 'beaker/module_install_helper'

install_puppet_agent_on(hosts, :puppet_collection => 'puppet5', :puppet_agent_version => ENV['PUPPET_INSTALL_VERSION'], :run_in_parallel => true)
proj = File.join(File.dirname(__FILE__), '..')
modulepath = '/etc/puppetlabs/code/modules'
copy_module_to(hosts, :source => proj, :module_name => 'yum', :target_module_path => modulepath)

UNSUPPORTED_PLATFORMS = ['Suse','AIX','Solaris']

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module dependencies
    on hosts, puppet('module', 'install', 'puppetlabs-stdlib', '--version', '">= 4.25.0 < 5.0.0"'), { :acceptable_exit_codes => [0,1], :run_in_parallel => true }
    on hosts, puppet('module', 'install', 'puppetlabs-apache', '--version', '">= 3.2.0 < 4.0.0"'), { :acceptable_exit_codes => [0,1], :run_in_parallel => true }
    on hosts, puppet('module', 'install', 'puppetlabs-concat', '--version', '">= 4.2.1 < 5.0.0"'), { :acceptable_exit_codes => [0,1], :run_in_parallel => true }
  end
end
