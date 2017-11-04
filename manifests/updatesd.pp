# == Class: yum::updatesd
#
# Manage yum-updatesd which is available on EL5, though not EL6
#
# This is defaulted to being disabled.
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
