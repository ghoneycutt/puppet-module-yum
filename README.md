# puppet-module-yum

#### Table of Contents

1. [Module Description](#module-description)
2. [Compatibility](#compatibility)
3. [Examples](#examples)
4. [Class Descriptions](#class-descriptions)
    * [yum](#class-yum)
    * [yum::server](#class-yumserver)
    * [yum::updatesd](#class-yumupdatesd)
5. [Define Descriptions](#define-descriptions)
    * [yum::repo](#defined-type-yumrepo)
    * [yum::rpm_gpg_key](#defined-type-yumrpm_gpg_key)


# Module description

Manage yum (client, server, and key management)

# Compatibility

This module is built for use with Puppet v3 (with and without the future
parser) and Puppet v4 on the following platforms and supports Ruby versions
1.8.7, 1.9.3, 2.0.0, 2.1.9 and 2.3.1.

 * EL 6
 * EL 7

# Examples

Create simple repository (without GPG key):

```
yum::repo { 'example_plain':
  gpgkey  => 'http://yum.test.local/keys/RPM-GPG-KEY-EXAMPLE_PLAIN',
  baseurl => 'http://yum.test.local/customrepo/5/10/$basearch',
}
```
via hiera data:

``` yaml
yum::repos:
  example_plain:
    gpgkey:   'http://yum.test.local/keys/RPM-GPG-KEY-EXAMPLE_PLAIN'
    baseurl:  'http://yum.test.local/customrepo/5/10/$basearch'
```


Create secured repository and import GPG key into local store:

```
yum::repo { 'example_secure':
  gpgkey   => 'https://yum.test.local/keys/RPM-GPG-KEY-EXAMPLE_SECURE',
  baseurl  => 'https://yum.test.local/customrepo/5/10/$basearch',
  username => 'example',
  password => 'secret',
  gpgcheck => true,
}
yum::rpm_gpg_key { 'example_secure':
  gpgkey     => '/etc/pki/rpm-gpg/RPM-GPG-KEY-EXAMPLE_SECURE',
  gpgkey_url => 'https://yum.test.local/keys/RPM-GPG-KEY-EXAMPLE_SECURE',
}

```
via hiera data:

``` yaml
yum::repos:
  example_secure:
    gpgkey:   'https://yum.test.local/keys/RPM-GPG-KEY-EXAMPLE_SECURE'
    baseurl   'https://yum.test.local/customrepo/5/10/$basearch'
    username: 'example'
    password: 'secret'
    gpgcheck: true
yum::rpm_gpg_keys:
  example_secure:
    gpgkey:     '/etc/pki/rpm-gpg/RPM-GPG-KEY-EXAMPLE_SECURE'
    gpgkey_url: 'https://yum.test.local/keys/RPM-GPG-KEY-EXAMPLE_SECURE'
```

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
#### rpm_gpg_keys_hiera_merge (boolean)
Trigger to merge all found instances of yum::rpm_gpg_keys in Hiera. This is useful for specifying repositories at different levels of the hierarchy and having them all included in the catalog.

- *Default*: true

---
#### repos (hash)
Hash of repos to pass to yum::repo. See [yum::repo](#defined-type-yumrepo) for more details.

- *Default*: undef

---
#### rpm_gpg_keys (hash)
Hash of repos to pass to yum::rpm_gpg_keys. See [yum::rpm_gpg_key](#defined-type-yumrpmgpgkeys) for more details.

- *Default*: undef

---

### Parameters for yum.conf
---
#### color_list_available_downgrade (array)
`color_list_available_downgrade` setting in the main section of yum.conf.
Valid values are: 'bg:black', 'bg:blue', 'bg:cyan', 'bg:green', 'bg:magenta', 'bg:red', 'bg:white',
'bg:yellow', 'blink', 'bold', 'dim', 'fg:black', 'fg:blue', 'fg:cyan', 'fg:green', 'fg:magenta',
'fg:red', 'fg:white', 'fg:yellow', 'reverse', 'underline',
When empty, it will not be present in yum.conf.

- *Default*: []

---
#### color_list_available_install (array)
`color_list_available_install` setting in the main section of yum.conf.
Valid values are: 'bg:black', 'bg:blue', 'bg:cyan', 'bg:green', 'bg:magenta', 'bg:red', 'bg:white',
'bg:yellow', 'blink', 'bold', 'dim', 'fg:black', 'fg:blue', 'fg:cyan', 'fg:green', 'fg:magenta',
'fg:red', 'fg:white', 'fg:yellow', 'reverse', 'underline',
When empty, it will not be present in yum.conf.

- *Default*: []

---
#### color_list_available_reinstall (array)
`color_list_available_reinstall` setting in the main section of yum.conf.
Valid values are: 'bg:black', 'bg:blue', 'bg:cyan', 'bg:green', 'bg:magenta', 'bg:red', 'bg:white',
'bg:yellow', 'blink', 'bold', 'dim', 'fg:black', 'fg:blue', 'fg:cyan', 'fg:green', 'fg:magenta',
'fg:red', 'fg:white', 'fg:yellow', 'reverse', 'underline',
When empty, it will not be present in yum.conf.

- *Default*: []

---
#### color_list_available_upgrade (array)
`color_list_available_upgrade` setting in the main section of yum.conf.
Valid values are: 'bg:black', 'bg:blue', 'bg:cyan', 'bg:green', 'bg:magenta', 'bg:red', 'bg:white',
'bg:yellow', 'blink', 'bold', 'dim', 'fg:black', 'fg:blue', 'fg:cyan', 'fg:green', 'fg:magenta',
'fg:red', 'fg:white', 'fg:yellow', 'reverse', 'underline',
When empty, it will not be present in yum.conf.

- *Default*: []

---
#### color_list_installed_extra (array)
`color_list_installed_extra` setting in the main section of yum.conf.
Valid values are: 'bg:black', 'bg:blue', 'bg:cyan', 'bg:green', 'bg:magenta', 'bg:red', 'bg:white',
'bg:yellow', 'blink', 'bold', 'dim', 'fg:black', 'fg:blue', 'fg:cyan', 'fg:green', 'fg:magenta',
'fg:red', 'fg:white', 'fg:yellow', 'reverse', 'underline',
When empty, it will not be present in yum.conf.

- *Default*: []

---
#### color_list_installed_newer (array)
`color_list_installed_newer` setting in the main section of yum.conf.
Valid values are: 'bg:black', 'bg:blue', 'bg:cyan', 'bg:green', 'bg:magenta', 'bg:red', 'bg:white',
'bg:yellow', 'blink', 'bold', 'dim', 'fg:black', 'fg:blue', 'fg:cyan', 'fg:green', 'fg:magenta',
'fg:red', 'fg:white', 'fg:yellow', 'reverse', 'underline',
When empty, it will not be present in yum.conf.

- *Default*: []

---
#### color_list_installed_older (array)
`color_list_installed_older` setting in the main section of yum.conf.
Valid values are: 'bg:black', 'bg:blue', 'bg:cyan', 'bg:green', 'bg:magenta', 'bg:red', 'bg:white',
'bg:yellow', 'blink', 'bold', 'dim', 'fg:black', 'fg:blue', 'fg:cyan', 'fg:green', 'fg:magenta',
'fg:red', 'fg:white', 'fg:yellow', 'reverse', 'underline',
When empty, it will not be present in yum.conf.

- *Default*: []

---
#### color_list_installed_reinstall (array)
`color_list_installed_reinstall` setting in the main section of yum.conf.
Valid values are: 'bg:black', 'bg:blue', 'bg:cyan', 'bg:green', 'bg:magenta', 'bg:red', 'bg:white',
'bg:yellow', 'blink', 'bold', 'dim', 'fg:black', 'fg:blue', 'fg:cyan', 'fg:green', 'fg:magenta',
'fg:red', 'fg:white', 'fg:yellow', 'reverse', 'underline',
When empty, it will not be present in yum.conf.

- *Default*: []

---
#### color_search_match (array)
`color_search_match` setting in the main section of yum.conf.
Valid values are: 'bg:black', 'bg:blue', 'bg:cyan', 'bg:green', 'bg:magenta', 'bg:red', 'bg:white',
'bg:yellow', 'blink', 'bold', 'dim', 'fg:black', 'fg:blue', 'fg:cyan', 'fg:green', 'fg:magenta',
'fg:red', 'fg:white', 'fg:yellow', 'reverse', 'underline',
When empty, it will not be present in yum.conf.

- *Default*: []

---
#### color_update_installed (array)
`color_update_installed` setting in the main section of yum.conf.
Valid values are: 'bg:black', 'bg:blue', 'bg:cyan', 'bg:green', 'bg:magenta', 'bg:red', 'bg:white',
'bg:yellow', 'blink', 'bold', 'dim', 'fg:black', 'fg:blue', 'fg:cyan', 'fg:green', 'fg:magenta',
'fg:red', 'fg:white', 'fg:yellow', 'reverse', 'underline',
When empty, it will not be present in yum.conf.

- *Default*: []

---
#### color_update_local (array)
`color_update_local` setting in the main section of yum.conf.
Valid values are: 'bg:black', 'bg:blue', 'bg:cyan', 'bg:green', 'bg:magenta', 'bg:red', 'bg:white',
'bg:yellow', 'blink', 'bold', 'dim', 'fg:black', 'fg:blue', 'fg:cyan', 'fg:green', 'fg:magenta',
'fg:red', 'fg:white', 'fg:yellow', 'reverse', 'underline',
When empty, it will not be present in yum.conf.

- *Default*: []

---
#### color_update_remote (array)
`color_update_remote` setting in the main section of yum.conf.
Valid values are: 'bg:black', 'bg:blue', 'bg:cyan', 'bg:green', 'bg:magenta', 'bg:red', 'bg:white',
'bg:yellow', 'blink', 'bold', 'dim', 'fg:black', 'fg:blue', 'fg:cyan', 'fg:green', 'fg:magenta',
'fg:red', 'fg:white', 'fg:yellow', 'reverse', 'underline',
When empty, it will not be present in yum.conf.

- *Default*: []

#### commands (array)
`commands` setting in the main section of yum.conf.
When empty, it will not be present in yum.conf.

- *Default*: []

---
#### exclude (array)
`exclude` setting in the main section of yum.conf.
When empty, it will not be present in yum.conf.

- *Default*: []

---
#### group_package_types (array)
`group_package_types` setting in the main section of yum.conf.
Valid values are: , 'default', 'mandatory', and 'optional'.
When empty, it will not be present in yum.conf.

- *Default*: []

---
#### history_record_packages (array)
`history_record_packages` setting in the main section of yum.conf.
When empty, it will not be present in yum.conf.

- *Default*: []

---
#### installonlypkgs (array)
`installonlypkgs` setting in the main section of yum.conf.
When empty, it will not be present in yum.conf.

- *Default*: []

---
#### kernelpkgnames (array)
`kernelpkgnames` setting in the main section of yum.conf.
When empty, it will not be present in yum.conf.

- *Default*: []

---
#### protected_packages (array)
`protected_packages` setting in the main section of yum.conf.
When empty, it will not be present in yum.conf.

- *Default*: []

---
#### tsflags (array)
`tsflags` setting in the main section of yum.conf.
Valid values are: , 'justdb', 'nocontexts', 'nodocs', 'noscripts', 'notriggers', 'repackage', and 'test'
When empty, it will not be present in yum.conf.

- *Default*: []

#### reposdir (array)
`reposdir` setting in the main section of yum.conf.
Takes a list of one or more absolute paths.
When empty, it will not be present in yum.conf.

- *Default*: []

---
#### distroverpkg (boolean or string)
`distroverpkg` setting in the main section of yum.conf. Will use the format distroverpk=$::operatingsystem-release (downcase) if true. Alternatively you can also specify a free string text instead. When undef, it will not be present in yum.conf.

- *Default*: undef

---
#### alwaysprompt (boolean)
`alwaysprompt` setting in the main section of yum.conf. True enables, false disables this feature. When undef, it will not be present in yum.conf.

- *Default*: undef

---
#### assumeyes (boolean)
`assumeyes` setting in the main section of yum.conf. True enables, false disables this feature. When undef, it will not be present in yum.conf.

- *Default*: undef

---
#### clean_requirements_on_remove (boolean)
`clean_requirements_on_remove` setting in the main section of yum.conf. True enables, false disables this feature. When undef, it will not be present in yum.conf.

- *Default*: undef

---
#### color (boolean)
`color` setting in the main section of yum.conf. True enables, false disables this feature. When undef, it will not be present in yum.conf.

- *Default*: undef

---
#### diskspacecheck (boolean)
`diskspacecheck` setting in the main section of yum.conf. True enables, false disables this feature. When undef, it will not be present in yum.conf.

- *Default*: undef

---
#### enable_group_conditionals (boolean)
`enable_group_conditionals` setting in the main section of yum.conf. True enables, false disables this feature. When undef, it will not be present in yum.conf.

- *Default*: undef

---
#### exactarch (boolean)
`exactarch` setting in the main section of yum.conf. True enables, false disables this feature. When undef, it will not be present in yum.conf.

- *Default*: true

---
#### gpgcheck (boolean)
`gpgcheck` setting in the main section of yum.conf. True enables, false disables this feature. When undef, it will not be present in yum.conf.

- *Default*: false

---
#### groupremove_leaf_only (boolean)
`groupremove_leaf_only` setting in the main section of yum.conf. True enables, false disables this feature. When undef, it will not be present in yum.conf.

- *Default*: undef

---
#### history_record (boolean)
`history_record` setting in the main section of yum.conf. True enables, false disables this feature. When undef, it will not be present in yum.conf.

- *Default*: undef

---
#### keepalive (boolean)
`keepalive` setting in the main section of yum.conf. True enables, false disables this feature. When undef, it will not be present in yum.conf.

- *Default*: undef

---
#### keepcache (boolean)
`keepcache` setting in the main section of yum.conf. True enables, false disables this feature. When undef, it will not be present in yum.conf.

- *Default*: true

---
#### localpkg_gpgcheck (boolean)
`localpkg_gpgcheck` setting in the main section of yum.conf. True enables, false disables this feature. When undef, it will not be present in yum.conf.

- *Default*: undef

---
#### obsoletes (boolean)
`obsoletes` setting in the main section of yum.conf. True enables, false disables this feature. When undef, it will not be present in yum.conf.

- *Default*: true

---
#### overwrite_groups (boolean)
`overwrite_groups` setting in the main section of yum.conf. True enables, false disables this feature. When undef, it will not be present in yum.conf.

- *Default*: undef

---
#### plugins (boolean)
`plugins` setting in the main section of yum.conf. True enables, false disables this feature. When undef, it will not be present in yum.conf.

- *Default*: false

---
#### protected_multilib (boolean)
`protected_multilib` setting in the main section of yum.conf. True enables, false disables this feature. When undef, it will not be present in yum.conf.

- *Default*: undef

---
#### repo_gpgcheck (boolean)
`repo_gpgcheck` setting in the main section of yum.conf. True enables, false disables this feature. When undef, it will not be present in yum.conf.

- *Default*: undef

---
#### reset_nice (boolean)
`reset_nice` setting in the main section of yum.conf. True enables, false disables this feature. When undef, it will not be present in yum.conf.

- *Default*: undef

---
#### showdupesfromrepos (boolean)
`showdupesfromrepos` setting in the main section of yum.conf. True enables, false disables this feature. When undef, it will not be present in yum.conf.

- *Default*: undef

---
#### skip_broken (boolean)
`skip_broken` setting in the main section of yum.conf. True enables, false disables this feature. When undef, it will not be present in yum.conf.

- *Default*: undef

---
#### ssl_check_cert_permissions (boolean)
`ssl_check_cert_permissions` setting in the main section of yum.conf. True enables, false disables this feature. When undef, it will not be present in yum.conf.

- *Default*: undef

---
#### sslverify (boolean)
`sslverify` setting in the main section of yum.conf. True enables, false disables this feature. When undef, it will not be present in yum.conf.

- *Default*: undef

---
#### tolerant (boolean)
`tolerant` setting in the main section of yum.conf. True enables, false disables this feature. When undef, it will not be present in yum.conf.

- *Default*: false

---
#### debuglevel (integer)
`debuglevel` setting in the main section of yum.conf.
Takes any integer between 0 and 10. When undef, it will not be present in yum.conf.

- *Default*: 2

---
#### errorlevel (integer)
`errorlevel` setting in the main section of yum.conf.
Takes any integer between 0 and 10. When undef, it will not be present in yum.conf.

- *Default*: undef

---
#### bandwidth (integer)
`bandwidth` setting in the main section of yum.conf.
Takes any integer. When undef, it will not be present in yum.conf.

- *Default*: undef

---
#### installonly_limit (integer)
`installonly_limit` setting in the main section of yum.conf.
Takes any integer. When undef, it will not be present in yum.conf.

- *Default*: undef

---
#### mirrorlist_expire (integer)
`mirrorlist_expire` setting in the main section of yum.conf.
Takes any integer. When undef, it will not be present in yum.conf.

- *Default*: undef

---
#### recent (integer)
`recent` setting in the main section of yum.conf.
Takes any integer. When undef, it will not be present in yum.conf.

- *Default*: undef

---
#### retries (integer)
`retries` setting in the main section of yum.conf.
Takes any integer. When undef, it will not be present in yum.conf.

- *Default*: undef

---
#### timeout (integer)
`timeout` setting in the main section of yum.conf.
Takes any integer. When undef, it will not be present in yum.conf.

- *Default*: undef

---
#### cachedir (string)
`cachedir` setting in the main section of yum.conf.
When undef, it will not be present in yum.conf.

- *Default*: '/var/cache/yum/$basearch/$releasever'

---
#### installroot (string)
`installroot` setting in the main section of yum.conf.
When undef, it will not be present in yum.conf.

- *Default*: undef

---
#### logfile (string)
`logfile` setting in the main section of yum.conf.
When undef, it will not be present in yum.conf.

- *Default*: '/var/log/yum.log'

---
#### persistdir (string)
`persistdir` setting in the main section of yum.conf.
When undef, it will not be present in yum.conf.

- *Default*: undef

---
#### pluginconfpath (string)
`pluginconfpath` setting in the main section of yum.conf.
When undef, it will not be present in yum.conf.

- *Default*: undef

---
#### pluginpath (string)
`pluginpath` setting in the main section of yum.conf.
When undef, it will not be present in yum.conf.

- *Default*: undef

---
#### sslcacert (string)
`sslcacert` setting in the main section of yum.conf.
When undef, it will not be present in yum.conf.

- *Default*: undef

---
#### sslclientcert (string)
`sslclientcert` setting in the main section of yum.conf.
When undef, it will not be present in yum.conf.

- *Default*: undef

---
#### sslclientkey (string)
`sslclientkey` setting in the main section of yum.conf.
When undef, it will not be present in yum.conf.

- *Default*: undef

---
#### bugtracker_url (string)
`bugtracker_url` setting in the main section of yum.conf. When undef, it will not be present in yum.conf.

- *Default*: undef

---
#### proxy (string)
`proxy` setting in the main section of yum.conf. When undef, it will not be present in yum.conf.

- *Default*: undef

---
#### password (string)
`password` setting in the main section of yum.conf. When undef, it will not be present in yum.conf.

- *Default*: undef

---
#### proxy_password (string)
`proxy_password` setting in the main section of yum.conf. When undef, it will not be present in yum.conf.

- *Default*: undef

---
#### proxy_username (string)
`proxy_username` setting in the main section of yum.conf. When undef, it will not be present in yum.conf.

- *Default*: undef

---
#### syslog_device (string)
`syslog_device` setting in the main section of yum.conf. When undef, it will not be present in yum.conf.

- *Default*: undef

---
#### syslog_facility (string)
`syslog_facility` setting in the main section of yum.conf. When undef, it will not be present in yum.conf.

- *Default*: undef

---
#### syslog_ident (string)
`syslog_ident` setting in the main section of yum.conf. When undef, it will not be present in yum.conf.

- *Default*: undef

---
#### username (string)
`username` setting in the main section of yum.conf. When undef, it will not be present in yum.conf.

- *Default*: undef

---
#### throttle (integer, float, or string)
`throttle` setting in the main section of yum.conf. Rate in bytes/sec, allows an SI prefix (k, M, or G) to be appended. When undef, it will not be present in yum.conf.

- *Default*: undef

---
#### metadata_expire (integer or string)
`metadata_expire` setting in the main section of yum.conf. Time in seconds, allows a prefix of m, h, or d to specify minutes, hours, or days. Alternatively you can also specify the word never instead. When undef, it will not be present in yum.conf.


- *Default*: '6h'

---
#### history_list_view (string)
`history_list_view` setting in the main section of yum.conf.
Valid values are: 'cmds', 'commands', 'default', 'single-user-commands', or 'users'.
When undef, it will not be present in yum.conf.

- *Default*: undef

---
#### mdpolicy (string)
`mdpolicy` setting in the main section of yum.conf.
Valid values are: 'group:all', 'group:main', 'group:primary', 'group:small', or 'instant'
When undef, it will not be present in yum.conf.

- *Default*: undef

---
#### rpmverbosity (string)
`rpmverbosity` setting in the main section of yum.conf.
Valid values are: 'critical', 'debug', 'emergency', 'error', 'info', or 'warn'.
When undef, it will not be present in yum.conf.

- *Default*: undef

---
#### http_caching (string)
`http_caching` setting in the main section of yum.conf.
Valid values are: 'all', 'none', or 'packages'
When undef, it will not be present in yum.conf.

- *Default*: undef

---
#### multilib_policy (string)
`multilib_policy` setting in the main section of yum.conf.
Valid values are: 'all' or 'best'.
When undef, it will not be present in yum.conf.

- *Default*: undef

---
#### pkgpolicy (string)
`pkgpolicy` setting in the main section of yum.conf.
Valid values are: 'last' or 'newest'.
When undef, it will not be present in yum.conf.

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
Set ensure attribute for package resource. Valid values are: 'present', 'absent', 'latest', and 'purged'.

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
Set ensure attribute for service resource. Valid values are: 'running' and 'stopped'.

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
#### ensure (string)
Set to `"present"` or `"absent"`.  When absent, removes the repository
configuration file from the node modeled on the behavior of the File type's
ensure parameter.

- *Default*: `"present"`

---
#### repo_file_mode (string)
Set the file mode of the repository configuration file.

- *Default*: '0400'

---
#### yum_repos_d_path (string)
Specify the path of the directory for yum repository files.

- *Default*: '/etc/yum.repos.d'

---
### Parameters for repository files

---
#### enabled (boolean)
`enabled` setting in the repository file. True enables, false disables this feature. When empty, it will not be present.

- *Default*: true

---
#### enablegroups (boolean)
`enablegroups` setting in the repository file. True enables, false disables this feature. When empty, it will not be present.

- *Default*: ''

---
#### gpgcheck (boolean)
`gpgcheck` setting in the repository file. True enables, false disables this feature. When empty, it will not be present.

- *Default*: false

---
#### keepalive (boolean)
`keepalive` setting in the repository file. True enables, false disables this feature. When empty, it will not be present.

- *Default*: ''

---
#### repo_gpgcheck (boolean)
`repo_gpgcheck` setting in the repository file. True enables, false disables this feature. When empty, it will not be present.

- *Default*: ''

---
#### skip_if_unavailable (boolean)
`skip_if_unavailable` setting in the repository file. True enables, false disables this feature. When empty, it will not be present.

- *Default*: ''

---
#### ssl_check_cert_permissions (boolean)
`ssl_check_cert_permissions` setting in the repository file. True enables, false disables this feature. When empty, it will not be present.

- *Default*: ''

---
#### sslverify (boolean)
`sslverify` setting in the repository file. True enables, false disables this feature. When empty, it will not be present.

- *Default*: ''

---
#### bandwidth (integer)
`bandwidth` setting in the repository file. Takes any integer. When empty, it will not be present.

- *Default*: ''

---
#### cost (integer)
`cost` setting in the repository file. Takes any integer. When empty, it will not be present.

- *Default*: ''

---
#### mirrorlist_expire (integer)
`mirrorlist_expire` setting in the repository file. Takes any integer. When empty, it will not be present.

- *Default*: ''

---
#### retries (integer)
`retries` setting in the repository file. Takes any integer. When empty, it will not be present.

- *Default*: ''

---
#### timeout (integer)
`timeout` setting in the repository file. Takes any integer. When empty, it will not be present.

- *Default*: ''

---
#### description (string)
`description` setting in the repository file. Defaults to the name of the defined type. When empty, it will not be present.

- *Default*: "$name"

---
#### password (string)
`password` setting in the repository file. When empty, it will not be present.

- *Default*: ''

---
#### proxy_password (string)
`proxy_password` setting in the repository file. When empty, it will not be present.

- *Default*: ''

---
#### proxy_username (string)
`proxy_username` setting in the repository file. When empty, it will not be present.

- *Default*: ''

---
#### repositoryid (string)
`repositoryid` setting in the repository file. When empty, it will not be present.

- *Default*: ''

---
#### username (string)
`username` setting in the repository file. When empty, it will not be present.

- *Default*: ''

---
#### baseurl (array)
`baseurl` setting in the repository file. Accepts HTTP/HTTPS/FTP/FILE URLs.
When empty, it will not be present.

- *Default*: []

---
#### gpgcakey (string with URL)
`gpgcakey` setting in the repository file. Accepts HTTP/HTTPS URLs.
When empty, it will not be present.

- *Default*: ''

---
#### gpgkey (array)
`gpgkey` setting in the repository file. Accepts HTTP/HTTPS/FTP/FILE URLs.
When empty, it will not be present.

- *Default*: []

---
#### metalink (string with URL)
`metalink` setting in the repository file. Accepts HTTP/HTTPS URLs.
When empty, it will not be present.

- *Default*: ''

---
#### mirrorlist (string with URL)
`mirrorlist` setting in the repository file. Accepts HTTP/HTTPS URLs.
When empty, it will not be present.

- *Default*: ''

---
#### proxy (string with URL)
`proxy` setting in the repository file. Accepts HTTP/HTTPS URLs and '_none_'.
When empty, it will not be present.

- *Default*: ''

---
#### failovermethod (string with URL)
`failovermethod` setting in the repository file. Valid values are: 'all', 'none', or 'packages'
When empty, it will not be present.

- *Default*: ''

---
#### http_caching (string)
`http_caching` setting in the repository file. Valid values are: 'all', 'none', or 'packages'
When empty, it will not be present.

- *Default*: ''

---
#### throttle (integer, float, or string)
`throttle` setting in the repository file.
Rate in bytes/sec, allows a suffix of k, M, or G to be appended.
When empty, it will not be present.

- *Default*: ''

---
#### metadata_expire (integer or string)
`metadata_expire` setting in the repository file.
Time in seconds, allows a suffix of m, h, or d to specify minutes, hours, or days.
Alternatively you can also specify the word never instead.
When empty, it will not be present.

- *Default*: ''

---
#### sslcacert (string)
`sslcacert` setting in the repository file.
When empty, it will not be present.

- *Default*: ''

---
#### sslclientcert (string)
`sslclientcert` setting in the repository file.
When empty, it will not be present.

- *Default*: ''

---
#### sslclientkey (string)
`sslclientkey` setting in the repository file.
When empty, it will not be present.

- *Default*: ''

---
#### exclude (array)
`exclude` setting in the repository file.
When empty, it will not be present.

- *Default*: []

---
#### includepkgs (array)
`includepkgs` setting in the repository file.
When empty, it will not be present.

- *Default*: []

---

###################
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
