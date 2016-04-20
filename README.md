puppet-module-yum
=================

Puppet module to manage yum (client, server, and key management)

Requires Facter >= v2.2.0 for the `lsbminordistrelease` fact.

===

# Compatibility

This module has been tested to work on the following systems with Puppet v3
( >= 3.5.x due to the Facter >= 2.2.0 requirement) with and without the future
parser and v4 with Ruby versions 1.8.7 (Puppet v3 only), 1.9.3 and 2.1.0.

 * EL 6
 * EL 7
