# puppet-module-yum

#### Table of Contents

1. [Module Description](#module-description)
2. [Compatibility](#compatibility)
3. [Class Descriptions](#class-descriptions)
    * [yum](#class-yum)
    * [yum::server](#class-yumserver)
    * [yum::updatesd](#class-yumupdatesd)
4. [Define Descriptions](#define-descriptions)
    * [yum::repo](#defined-type-yumrepo)
    * [yum::rpm_gpg_key](#defined-type-yumrpm_gpg_key)


# Module description

Manage yum (client, server, and key management)

Requires Facter >= v2.2.0 for the `lsbminordistrelease` fact.

# Compatibility

This module is built for use with Puppet v3 (with and without the future
parser) and Puppet v4 on the following platforms and supports Ruby versions
1.8.7, 1.9.3, 2.0.0, 2.1.0 and 2.3.1.

 * EL 6
 * EL 7

# Class Descriptions
## Class `yum`
### Parameters

---
#### config_group (string)
Set group access to the yum.conf file, representing a group.

- *Default*: 'root'

---
#### config_mode (string)
Set access permissions for the yum.conf file, in numeric notation.

- *Default*: '0644'

---
#### config_owner (string)
Set owner access to the yum.conf file, representing a user.

- *Default*: 'root'

---
#### config_path (string)
Set the path to the yum.conf file, representing a fully qualified name.

- *Default*: '/etc/yum.conf'

---
#### distroverpkg (boolean)
Trigger to add the `distroverpkg` setting to the main section of yum.conf. Will use the format distroverpk=$::operatingsystem-release (downcase) if active.

- *Default*: false

---
#### installonly_limit (integer)
Trigger to add the `installonly_limit` setting with the given number to the main section of yum.conf. When unset (default) installonly_limit will not be present in yum.conf.

- *Default*: undef

---
#### exclude (string or array)
Value for the exclude setting in the main section of yum.conf. When `undef` (default) exclude will not be present in yum.conf.

- *Default*: undef

---
#### exclude_hiera_merge (boolean)
Trigger to merge all found instances of yum::exclude in Hiera. This is useful for specifying repositories at different levels of the hierarchy and having them all included in the catalog.

- *Default*: false

---
#### manage_repos (boolean)
Trigger if files in /etc/yum.repos.d should get managed by Puppet exclusivly. If set to true, all unmanged files in /etc/yum.repos.d (and below) will get removed.

- *Default*: false

---
#### pkgpolicy (string)
Trigger to add the `pkgpolicy` setting with the given string to the main section of yum.conf. Valid values are: 'newest' or 'last'.

- *Default*: undef

---
#### proxy (string)
Trigger to add the `proxy` setting with the given string to the main section of yum.conf. Specify a proxy URL.

- *Default*: undef

---
#### repos_d_group (string)
Set group access to the /etc/yum.repos.d directory, representing a group.

- *Default*: 'root'

---
#### repos_d_mode (string)
Set access permissions for the /etc/yum.repos.d directory, in numeric notation.

- *Default*: '0755'

---
#### repos_d_owner (string)
Set owner access to the /etc/yum.repos.d directory, representing a user.

- *Default*: 'root'

---
#### repos_hiera_merge (boolean)
Trigger to merge all found instances of yum::repos in Hiera. This is useful for specifying repositories at different levels of the hierarchy and having them all included in the catalog.

- *Default*: true

---
#### repos (hash)
Hash of repos to pass to yum::repo. See [yum::repo](#defined-type-yumrepo) for more details.

- *Default*: undef

---
## Class `yum::server`

### Description

Manage a yum repository service

This class includes Puppetlabs apache module to set up a vhost for Apache HTTPD.

### Parameters

---
#### contact_email (string)
Set email address for server administration contact. Will be used for `ServerAdmin` in Apache vhost configuration.

- *Default*: 'root@localhost'

---
#### docroot (string)
Set absolute path to document root. Will be used for `DocumentRoot` Apache vhost configuration.

- *Default*: '/opt/repos'

---
#### gpg_keys_path (string)
Set relative path to GPG keys directory which will be in $docroot directory. `$docroot/$gpg_keys_path` will be created and used.

- *Default*: 'keys'

---
#### gpg_user_name (string)
Set user who signs the packages. Will be used as %_gpg_name in in /root/.rpmmacros.

- *Default*: 'Root'

---
#### yum_server (string)
Set servername for yum repository. Will be used for `ServerName` in Apache vhost configuration.

- *Default*: 'yum'

---
#### yum_server_http_listen_ip (string)
Set listen IP for yum repository server. Will be used for `VirtualHost` in Apache vhost configuration.

- *Default*: '$::ipaddress'

---
## Class `yum::updatesd`

### Description

Manage yum-updatesd which is available on EL5, though not EL6

### Parameters

---
#### updatesd_package_ensure (string)
Set ensure attribute for package resource. Valid values are: 'present', 'absent', 'latest', 'purged', and 'held'.

- *Default*: 'absent'

---
#### updatesd_package (string)
Specify name of yum updatesd package.

- *Default*: 'yum-updatesd'

---
#### updatesd_service_enable (string)
Set enable attribute for service resource. Valid values are: 'true', 'false', 'manual', and 'mark'.

- *Default*: 'false'

---
#### updatesd_service_ensure (string)
Set ensure attribute for service resource. Valid values are: 'stopped' or 'false', and 'running' or 'true'.

- *Default*: 'stopped'

---
#### updatesd_service (string)
Specify name of yum updatesd service.

- *Default*: 'yum-updatesd'

---

# Define Descriptions
## Defined type `yum::repo`

### Description

Manage individual yum repo files in /etc/yum.repos.d

### Parameters

---
#### baseurl (string)
Trigger to set the `baseurl` parameter of the repository configuration. Takes a form such as 'http://yum.domain.tld/customrepo/5/8/dev/x86_64'.

If $baseurl and $mirrorlist are both unset, it baseurl will become:  
`$repo_server_protocol://$username:$password@$repo_server/$repo_server_basedir/$name/$::lsbmajdistrelease/$::lsbminordistrelease/$environment/$basearch`.  
Passing $username and $password is optional.

If only $mirrorlist is set, `baseurl` will not be used in the repository configuration.

- *Default*: undef

---
#### description (string)
Set the `name` parameter of the repository configuration. If unset it will use the name of the defined type.

- *Default*: undef

---
#### enabled (boolean)
Set the `enabled` parameter of the repository configuration.

- *Default*: true

---
#### environment (string)
Specify the environment part of the default value for baseurl (see [$baseurl](#baseurl-string)).
Specifying $baseurl or $mirrorlist will override this parameter.

- *Default*: $::environment

---
#### failovermethod (boolean)
Trigger to set the `failovermethod` parameter of the repository configuration.

- *Default*: undef

---
#### gpgcheck (boolean)
Set the `gpgcheck` parameter of a repository configuration.

- *Default*: true

---
#### gpgkey_file_prefix (string)
Specify the prefix part of the default URL for GPG keys (see [$gpgkey](#gpgkey-string)).
Specifing $gpgkey will override this parameter.

- *Default*: 'RPM-GPG-KEY'

---
#### gpgkey_local_path (string)
Specify the path where GPG keys should be stored locally.

- *Default*: '/etc/pki/rpm-gpg'

---
#### gpgkey (string)
Set the `gpgkey` parameter of the repository configuration.
Will only be used when $use_gpgkey_uri is set to true.

- *Default*: undef

---
#### gpgkey_url_path (string)
Specify the URL part of the default URL for GPG keys (see [$gpgkey](#gpgkey-string)).
Specifing $gpgkey will override this parameter.

- *Default*: 'keys'

---
#### gpgkey_url_proto (string)
Specify the protocol part of the default URL for GPG keys (see [$gpgkey](#gpgkey-string)).
Specifing $gpgkey will override this parameter.

- *Default*: 'http'

---
#### gpgkey_url_server (string)
Specify the server part of the default URL for GPG keys (see [$gpgkey](#gpgkey-string)). If unset $repo_server will be used.
Specifing $gpgkey will override this parameter.

- *Default*: undef

---
#### mirrorlist (string)
Trigger to set the `mirrorlist` parameter of the repository configuration.

- *Default*: undef

---
#### password (string)
Specify the optional password part of the default URL for baseurl (see [$baseurl](#baseurl-string)).
Specifing $baseurl or $mirrlost will override this parameter.

- *Default*: undef

---
#### priority (string)
Trigger to set the `priority` parameter of the repository configuration.

- *Default*: undef

---
#### repo_file_mode (string)
Set the file mode of the repository configuration file.

- *Default*: '0400'

---
#### repo_server_basedir (string)
Specify the basedir part of the default URL for baseurl (see [$baseurl](#baseurl-string)).
Specifing $baseurl or $mirrlost will override this parameter.

- *Default*: '/'

---
#### repo_server_protocol (string)
Specify the protocol part of the default URL for baseurl (see [$baseurl](#baseurl-string)).
Specifing $baseurl or $mirrlost will override this parameter.

- *Default*: 'http'

---
#### repo_server (string)
Specify the server part of the default URL for baseurl (see [$baseurl](#baseurl-string)).
Specifing $baseurl or $mirrlost will override this parameter.

- *Default*: 'yum.$::domain'

---
#### use_gpgkey_uri (boolean)
Trigger to activate support for using GPG keys. If set to true the module will download GPG keys and add the `gpgkey` parameter to the repository configuration.

- *Default*: true

---
#### username (string)
Specify the optional username part of the default URL for baseurl (see [$baseurl](#baseurl-string)).
Specifing $baseurl or $mirrlost will override this parameter.

- *Default*: undef

---
#### yum_repos_d_path (string)
Specify the path of the directory for yum repository files.

- *Default*: '/etc/yum.repos.d'

---

## Defined type `yum::rpm_gpg_key`

### Description

Downloads a public gpg key for a yum repo and installs the key

### Parameters

---
#### gpgkey (string) (mandatory)
Specify the fully qualified destination file name for the GPG key to save to.

- *Default*:

---
#### gpgkey_url (string) (mandatory)
Specify the source URL for the GPG key to download from.

- *Default*:

---
#### rpm_path (string)
Specify the path parameter to be used for the rpm command.

- *Default*: '/bin:/usr/bin:/sbin:/usr/sbin'

---
#### wget_path (string)
Specify the path parameter to be used for the wget command.

- *Default*: '/bin:/usr/bin:/sbin:/usr/sbin'

---
