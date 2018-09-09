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

Manage yum (client, server, and key management). This module manages
`/etc/yum.conf` and can manage a repo file such as
`/etc/yum.repos.d/foo.repo` using `yum::repo`. This functionality is
feature complete and supports all documented options. The module can
fetch and install RPM GPG keys to aid in the usage of GPG keys for
repositories.

This module has the ability to create a yum server to serve up yum
repositories to agents using Apache.

# Compatibility

This module is built for use with Puppet v5 on the following platforms
and supports the Ruby version associated with each puppet agent release.
See `.travis.yml` for an exact matrix.

 * EL 6
 * EL 7

# Examples

## Create simple yum repo file

```puppet
yum::repo { 'example_plain':
  gpgkey  => 'http://yum.test.local/keys/RPM-GPG-KEY-EXAMPLE_PLAIN',
  baseurl => 'http://yum.test.local/customrepo/5/10/$basearch',
}
```

Using Hiera:

```yaml
yum::repos:
  example_plain:
    gpgkey:   'http://yum.test.local/keys/RPM-GPG-KEY-EXAMPLE_PLAIN'
    baseurl:  'http://yum.test.local/customrepo/5/10/$basearch'
```


## Create secured repository and import GPG key into local store:

```puppet
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

Using Hiera:

```yaml
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

## Profile for a yum server

```puppet
include ::yum::server
```

## Profile for all EL systems

```puppet
include ::yum
```

## Design patterns
Use Hiera to include the `yum` class on all EL6 and EL7 systems.

Create a profile such as `profile::yumrepos` that lists all your yum
repos as virtual resources and then realizing the repos in the
appropriate profiles.


```puppet
# profile::yumrepos

@yum::repo { 'app_foo':
  baseurl => 'http://yum.test.local/app_foo/7/$basearch',
}

@yum::repo { 'app_bar':
  baseurl => 'http://yum.test.local/app_bar/7/$basearch',
}
```

```puppet
# profile::foo

realize Yum::repo['app_foo']
```
