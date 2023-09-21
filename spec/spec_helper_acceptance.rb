require 'beaker-rspec'
require 'beaker-puppet'
require 'beaker/module_install_helper'
require 'beaker/puppet_install_helper'

run_puppet_install_helper
install_module_dependencies
install_module

UNSUPPORTED_PLATFORMS = ['Suse', 'AIX', 'Solaris'].freeze

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation
  c.add_setting :yum_full, default: false
  c.yum_full = (ENV['BEAKER_yum_full'] == 'yes' || ENV['BEAKER_yum_full'] == 'true')
end
