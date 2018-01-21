### v2.0.0 - 2017-12-xx
  * All yum.conf specific parameters will only be added when their value is not an empty string or array.
  * Changed default value for keepcache in main section of yum.conf to '1' (true) to follow yum standard.
  * Changed default value for gpgcheck in main section of yum.conf to '0' (false) to follow yum standard.
  * Changed default value for tolerant in main section of yum.conf to '0' (false) to follow yum standard.
  * Changed default value for plugins in main section of yum.conf to '0' (false) to follow yum standard.
  * Changed default value for metadata_expire in main section of yum.conf to '6h' to follow yum standard.
  * distroverpkg now also allows free string texts.
  * exclude does now only suppport arrays. Support for strings was removed.
  * Changed default value for yum::repo::gpgcheck in main section of yum.conf to '0' (false) to follow yum standard.
  * Removed non existing yum::repo::priority parameter.
  * Removed concatination logic for $baseurl. Consequently also removes $environment, $repo_server_basedir, $repo_server_protocol, and $repo_server.
  * Removed concatination logic for $gpgkey. Consequently also removes $use_gpgkey_uri, $gpgkey_url_proto, $gpgkey_url_path and $gpgkey_file_prefix.

### v1.4.0 - 2017-09-28
  * Add ensure parameter to yum::repo so it could be set to absent.

### v1.3.0 - 2017-09-19
  * Add sslcacert parameter to yum::repo

### v1.2.0 - 2017-05-08
  * Allow yum::exclude to do a merged Hiera lookup

### v1.1.0 - 2017-05-03
  * Allow yum::exclude to be an array.

### v1.0.0 - 2016-11-04
  * After three years of use, finally calling it stable.
