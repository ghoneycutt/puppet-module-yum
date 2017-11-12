# @summary Manage yum-updatesd which is available on EL5, though not EL6
#   This is defaulted to being disabled.
#
# @param updatesd_package
#   Specify name of yum updatesd package.
#
# @param updatesd_package_ensure
#   Set ensure attribute for package resource. Valid values are: 'present',
#   'absent', 'latest', and 'purged'.
#
# @param updatesd_service
#   Specify name of yum updatesd service.
#
# @param updatesd_service_ensure
#  Set ensure attribute for service resource. Valid values are: 'running'
#  and 'stopped'.
#
# @param updatesd_service_enable
#  Set enable attribute for service resource. Valid values are: 'true', 'false',
#  'manual', and 'mark'.
#
class yum::updatesd (
  String $updatesd_package                                               = 'yum-updatesd',
  Enum['absent', 'latest', 'present', 'purged'] $updatesd_package_ensure = 'absent',
  String $updatesd_service                                               = 'yum-updatesd',
  Enum['running', 'stopped'] $updatesd_service_ensure                    = 'stopped',
  Enum['false', 'manual', 'mark', 'true'] $updatesd_service_enable       = 'false', # lint:ignore:quoted_booleans
) {

  package { 'yum_updatesd_package':
    ensure => $updatesd_package_ensure,
    name   => $updatesd_package,
  }

  service { 'yum_updatesd_service':
    ensure => $updatesd_service_ensure,
    name   => $updatesd_service,
    enable => $updatesd_service_enable,
    before => Package['yum_updatesd_package'],
  }
}
