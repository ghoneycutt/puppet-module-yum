# @summary Manage yum (client, server, and key management)
#
# @example Declaring the class
#   include ::yum
#
# @param config_path
#   Set the path to the yum.conf file, representing a fully qualified name.
#
# @param config_owner
#   Set owner access to the yum.conf file, representing a user.
#
# @param config_group
#   Set group access to the yum.conf file, representing a group.
#
# @param config_mode
#   Set access permissions for the yum.conf file, in numeric notation.
#
# @param manage_repos
#   Trigger if files in /etc/yum.repos.d should get managed by Puppet exclusivly.
#   If set to true, all unmanged files in /etc/yum.repos.d (and below) will get
#   removed.
#
# @param repos_d_owner
#   Set owner access to the /etc/yum.repos.d directory, representing a user.
#
# @param repos_d_group
#   Set group access to the /etc/yum.repos.d directory, representing a group.
#
# @param repos_d_mode
#   Set access permissions for the /etc/yum.repos.d directory, in numeric notation.
#
# @param repos_hiera_merge
#   Trigger to merge all found instances of yum::repos in Hiera. This is useful
#   for specifying repositories at different levels of the hierarchy and having
#   them all included in the catalog.
#
# @param rpm_gpg_keys_hiera_merge
#   Trigger to merge all found instances of yum::rpm_gpg_keys in Hiera. This is useful
#   for specifying repositories at different levels of the hierarchy and having
#   them all included in the catalog.
#
# @param repos
#   Hash of repos to pass to yum::repo. See yum::repo for more details.
#
# @param rpm_gpg_keys
#   Hash of repos to pass to yum::rpm_gpg_keys. See yum::rpm_gpg_key for more details.
#
# @param exclude_hiera_merge
#   Trigger to merge all found instances of yum::exclude in Hiera. This is useful
#   for specifying repositories at different levels of the hierarchy and having
#   them all included in the catalog.
#
#
#
# @param color_list_available_downgrade
#   color_list_available_downgrade setting in the main section of yum.conf.
#   Valid values are: 'bg:black', 'bg:blue', 'bg:cyan', 'bg:green', 'bg:magenta', 'bg:red', 'bg:white',
#     'bg:yellow', 'blink', 'bold', 'dim', 'fg:black', 'fg:blue', 'fg:cyan', 'fg:green', 'fg:magenta',
#     'fg:red', 'fg:white', 'fg:yellow', 'reverse', 'underline',
#   When empty, it will not be present in yum.conf.
#
# @param color_list_available_install
#   color_list_available_install setting in the main section of yum.conf.
#   Valid values are: 'bg:black', 'bg:blue', 'bg:cyan', 'bg:green', 'bg:magenta', 'bg:red', 'bg:white',
#     'bg:yellow', 'blink', 'bold', 'dim', 'fg:black', 'fg:blue', 'fg:cyan', 'fg:green', 'fg:magenta',
#     'fg:red', 'fg:white', 'fg:yellow', 'reverse', 'underline',
#   When empty, it will not be present in yum.conf.
#
# @param color_list_available_reinstall
#   color_list_available_reinstall setting in the main section of yum.conf.
#   Valid values are: 'bg:black', 'bg:blue', 'bg:cyan', 'bg:green', 'bg:magenta', 'bg:red', 'bg:white',
#     'bg:yellow', 'blink', 'bold', 'dim', 'fg:black', 'fg:blue', 'fg:cyan', 'fg:green', 'fg:magenta',
#     'fg:red', 'fg:white', 'fg:yellow', 'reverse', 'underline',
#   When empty, it will not be present in yum.conf.
#
# @param color_list_available_upgrade
#   color_list_available_upgrade setting in the main section of yum.conf.
#   Valid values are: 'bg:black', 'bg:blue', 'bg:cyan', 'bg:green', 'bg:magenta', 'bg:red', 'bg:white',
#     'bg:yellow', 'blink', 'bold', 'dim', 'fg:black', 'fg:blue', 'fg:cyan', 'fg:green', 'fg:magenta',
#     'fg:red', 'fg:white', 'fg:yellow', 'reverse', 'underline',
#   When empty, it will not be present in yum.conf.
#
# @param color_list_installed_extra
#   color_list_installed_extra setting in the main section of yum.conf.
#   Valid values are: 'bg:black', 'bg:blue', 'bg:cyan', 'bg:green', 'bg:magenta', 'bg:red', 'bg:white',
#     'bg:yellow', 'blink', 'bold', 'dim', 'fg:black', 'fg:blue', 'fg:cyan', 'fg:green', 'fg:magenta',
#     'fg:red', 'fg:white', 'fg:yellow', 'reverse', 'underline',
#   When empty, it will not be present in yum.conf.
#
# @param color_list_installed_newer
#   color_list_installed_newer setting in the main section of yum.conf.
#   Valid values are: 'bg:black', 'bg:blue', 'bg:cyan', 'bg:green', 'bg:magenta', 'bg:red', 'bg:white',
#     'bg:yellow', 'blink', 'bold', 'dim', 'fg:black', 'fg:blue', 'fg:cyan', 'fg:green', 'fg:magenta',
#     'fg:red', 'fg:white', 'fg:yellow', 'reverse', 'underline',
#   When empty, it will not be present in yum.conf.
#
# @param color_list_installed_older
#   color_list_installed_older setting in the main section of yum.conf.
#   Valid values are: 'bg:black', 'bg:blue', 'bg:cyan', 'bg:green', 'bg:magenta', 'bg:red', 'bg:white',
#     'bg:yellow', 'blink', 'bold', 'dim', 'fg:black', 'fg:blue', 'fg:cyan', 'fg:green', 'fg:magenta',
#     'fg:red', 'fg:white', 'fg:yellow', 'reverse', 'underline',
#   When empty, it will not be present in yum.conf.
#
# @param color_list_installed_reinstall
#   color_list_installed_reinstall setting in the main section of yum.conf.
#   Valid values are: 'bg:black', 'bg:blue', 'bg:cyan', 'bg:green', 'bg:magenta', 'bg:red', 'bg:white',
#     'bg:yellow', 'blink', 'bold', 'dim', 'fg:black', 'fg:blue', 'fg:cyan', 'fg:green', 'fg:magenta',
#     'fg:red', 'fg:white', 'fg:yellow', 'reverse', 'underline',
#   When empty, it will not be present in yum.conf.
#
# @param color_search_match
#   color_search_match setting in the main section of yum.conf.
#   Valid values are: 'bg:black', 'bg:blue', 'bg:cyan', 'bg:green', 'bg:magenta', 'bg:red', 'bg:white',
#     'bg:yellow', 'blink', 'bold', 'dim', 'fg:black', 'fg:blue', 'fg:cyan', 'fg:green', 'fg:magenta',
#     'fg:red', 'fg:white', 'fg:yellow', 'reverse', 'underline',
#   When empty, it will not be present in yum.conf.
#
# @param color_update_installed
#   color_update_installed setting in the main section of yum.conf.
#   Valid values are: 'bg:black', 'bg:blue', 'bg:cyan', 'bg:green', 'bg:magenta', 'bg:red', 'bg:white',
#     'bg:yellow', 'blink', 'bold', 'dim', 'fg:black', 'fg:blue', 'fg:cyan', 'fg:green', 'fg:magenta',
#     'fg:red', 'fg:white', 'fg:yellow', 'reverse', 'underline',
#   When empty, it will not be present in yum.conf.
#
# @param color_update_local
#   color_update_local setting in the main section of yum.conf.
#   Valid values are: 'bg:black', 'bg:blue', 'bg:cyan', 'bg:green', 'bg:magenta', 'bg:red', 'bg:white',
#     'bg:yellow', 'blink', 'bold', 'dim', 'fg:black', 'fg:blue', 'fg:cyan', 'fg:green', 'fg:magenta',
#     'fg:red', 'fg:white', 'fg:yellow', 'reverse', 'underline',
#   When empty, it will not be present in yum.conf.
#
# @param color_update_remote
#   color_update_remote setting in the main section of yum.conf.
#   Valid values are: 'bg:black', 'bg:blue', 'bg:cyan', 'bg:green', 'bg:magenta', 'bg:red', 'bg:white',
#     'bg:yellow', 'blink', 'bold', 'dim', 'fg:black', 'fg:blue', 'fg:cyan', 'fg:green', 'fg:magenta',
#     'fg:red', 'fg:white', 'fg:yellow', 'reverse', 'underline',
#   When empty, it will not be present in yum.conf.
#
# @param commands
#   commands setting in the main section of yum.conf.
#   When empty, it will not be present in yum.conf.
#
# @param exclude
#   exclude setting in the main section of yum.conf.
#   When empty, it will not be present in yum.conf.
#
# @param group_package_types
#   group_package_types setting in the main section of yum.conf.
#   Valid values are: , 'default', 'mandatory', and 'optional'.
#   When empty, it will not be present in yum.conf.
#
# @param history_record_packages
#   history_record_packages setting in the main section of yum.conf.
#   When empty, it will not be present in yum.conf.
#
# @param installonlypkgs
#   installonlypkgs setting in the main section of yum.conf.
#   When empty, it will not be present in yum.conf.
#
# @param kernelpkgnames
#   kernelpkgnames setting in the main section of yum.conf.
#   When empty, it will not be present in yum.conf.
#
# @param protected_packages
#   protected_packages setting in the main section of yum.conf.
#   When empty, it will not be present in yum.conf.
#
# @param tsflags
#   tsflags setting in the main section of yum.conf.
#   Valid values are: , 'justdb', 'nocontexts', 'nodocs', 'noscripts', 'notriggers', 'repackage', and 'test'
#   When empty, it will not be present in yum.conf.
#
# @param reposdir
#   reposdir setting in the main section of yum.conf.
#   Takes a list of one or more absolute paths.
#   When empty, it will not be present in yum.conf.
#
# @param distroverpkg
#   distroverpkg setting in the main section of yum.conf.
#   Will use the format distroverpk=$::operatingsystem-release (downcase) if true.
#   Alternatively you can also specify a free string text instead.
#   When undef, it will not be present in yum.conf.
#
# @param alwaysprompt
#   alwaysprompt setting in the main section of yum.conf.
#   True enables, false disables this feature. When undef, it will not be present in yum.conf.
#
# @param assumeyes
#   assumeyes setting in the main section of yum.conf.
#   True enables, false disables this feature. When undef, it will not be present in yum.conf.
#
# @param clean_requirements_on_remove
#   clean_requirements_on_remove setting in the main section of yum.conf.
#   True enables, false disables this feature. When clean, it will not be present in yum.conf.
#
# @param color
#   color setting in the main section of yum.conf.
#   True enables, false disables this feature. When clean, it will not be present in yum.conf.
#
# @param diskspacecheck
#   diskspacecheck setting in the main section of yum.conf.
#   True enables, false disables this feature. When undef, it will not be present in yum.conf.
#
# @param enable_group_conditionals
#   enable_group_conditionals setting in the main section of yum.conf.
#   True enables, false disables this feature. When undef, it will not be present in yum.conf.
#
# @param exactarch
#   exactarch setting in the main section of yum.conf.
#   True enables, false disables this feature. When undef, it will not be present in yum.conf.
#
# @param gpgcheck
#   gpgcheck setting in the main section of yum.conf.
#   True enables, false disables this feature. When undef, it will not be present in yum.conf.
#
# @param groupremove_leaf_only
#   groupremove_leaf_only setting in the main section of yum.conf.
#   True enables, false disables this feature. When undef, it will not be present in yum.conf.
#
# @param history_record
#   history_record setting in the main section of yum.conf.
#   True enables, false disables this feature. When undef, it will not be present in yum.conf.
#
# @param keepalive
#   keepalive setting in the main section of yum.conf.
#   True enables, false disables this feature. When undef, it will not be present in yum.conf.
#
# @param keepcache
#   keepcache setting in the main section of yum.conf.
#   True enables, false disables this feature. When undef, it will not be present in yum.conf.
#
# @param localpkg_gpgcheck
#   localpkg_gpgcheck setting in the main section of yum.conf.
#   True enables, false disables this feature. When undef, it will not be present in yum.conf.
#
# @param obsoletes
#   obsoletes setting in the main section of yum.conf.
#   True enables, false disables this feature. When undef, it will not be present in yum.conf.
#
# @param overwrite_groups
#   overwrite_groups setting in the main section of yum.conf.
#   True enables, false disables this feature. When undef, it will not be present in yum.conf.
#
# @param plugins
#   plugins setting in the main section of yum.conf.
#   True enables, false disables this feature. When undef, it will not be present in yum.conf.
#
# @param protected_multilib
#   protected_multilib setting in the main section of yum.conf.
#   True enables, false disables this feature. When undef, it will not be present in yum.conf.
#
# @param repo_gpgcheck
#   repo_gpgcheck setting in the main section of yum.conf.
#   True enables, false disables this feature. When undef, it will not be present in yum.conf.
#
# @param reset_nice
#   reset_nice setting in the main section of yum.conf.
#   True enables, false disables this feature. When undef, it will not be present in yum.conf.
#
# @param showdupesfromrepos
#   showdupesfromrepos setting in the main section of yum.conf.
#   True enables, false disables this feature. When undef, it will not be present in yum.conf.
#
# @param skip_broken
#   skip_broken setting in the main section of yum.conf.
#   True enables, false disables this feature. When undef, it will not be present in yum.conf.
#
# @param ssl_check_cert_permissions
#   ssl_check_cert_permissions setting in the main section of yum.conf.
#   True enables, false disables this feature. When undef, it will not be present in yum.conf.
#
# @param sslverify
#   sslverify setting in the main section of yum.conf.
#   True enables, false disables this feature. When undef, it will not be present in yum.conf.
#
# @param tolerant
#   tolerant setting in the main section of yum.conf.
#   True enables, false disables this feature. When undef, it will not be present in yum.conf.
#
# @param debuglevel
#   debuglevel setting in the main section of yum.conf.
#   Takes any integer between 0 and 10. When undef, it will not be present in yum.conf.
#
# @param errorlevel
#   errorlevel setting in the main section of yum.conf.
#   Takes any integer between 0 and 10. When undef, it will not be present in yum.conf.
#
# @param bandwidth
#   bandwidth setting in the main section of yum.conf.
#   Takes any integer. When undef, it will not be present in yum.conf.
#
# @param installonly_limit
#   installonly_limit setting in the main section of yum.conf.
#   Takes any integer. When undef, it will not be present in yum.conf.
#
# @param mirrorlist_expire
#   mirrorlist_expire setting in the main section of yum.conf.
#   Takes any integer. When undef, it will not be present in yum.conf.
#
# @param recent
#   recent setting in the main section of yum.conf.
#   Takes any integer. When undef, it will not be present in yum.conf.
#
# @param retries
#   retries setting in the main section of yum.conf.
#   Takes any integer. When undef, it will not be present in yum.conf.
#
# @param timeout
#   timeout setting in the main section of yum.conf.
#   Takes any integer. When undef, it will not be present in yum.conf.
#
# @param cachedir
#   cachedir setting in the main section of yum.conf.
#   When undef, it will not be present in yum.conf.
#
# @param installroot
#   installroot setting in the main section of yum.conf.
#   When undef, it will not be present in yum.conf.
#
# @param logfile
#   logfile setting in the main section of yum.conf.
#   When undef, it will not be present in yum.conf.
#
# @param persistdir
#   persistdir setting in the main section of yum.conf.
#   When undef, it will not be present in yum.conf.
#
# @param pluginconfpath
#   pluginconfpath setting in the main section of yum.conf.
#   When undef, it will not be present in yum.conf.
#
# @param pluginpath
#   pluginpath setting in the main section of yum.conf.
#   When undef, it will not be present in yum.conf.
#
# @param sslcacert
#   sslcacert setting in the main section of yum.conf.
#   When undef, it will not be present in yum.conf.
#
# @param sslclientcert
#   sslclientcert setting in the main section of yum.conf.
#   When undef, it will not be present in yum.conf.
#
# @param sslclientkey
#   sslclientkey setting in the main section of yum.conf.
#   When undef, it will not be present in yum.conf.
#
# @param bugtracker_url
#   bugtracker_url setting in the main section of yum.conf. When undef, it will not be present in yum.conf.
#
# @param proxy
#   proxy setting in the main section of yum.conf. When undef, it will not be present in yum.conf.
#
# @param password
#   password setting in the main section of yum.conf. When undef, it will not be present in yum.conf.
#
# @param proxy_password
#   proxy_password setting in the main section of yum.conf. When undef, it will not be present in yum.conf.
#
# @param proxy_username
#   proxy_username setting in the main section of yum.conf. When undef, it will not be present in yum.conf.
#
# @param syslog_device
#   syslog_device setting in the main section of yum.conf. When undef, it will not be present in yum.conf.
#
# @param syslog_facility
#   syslog_facility setting in the main section of yum.conf. When undef, it will not be present in yum.conf.
#
# @param syslog_ident
#   syslog_ident setting in the main section of yum.conf. When undef, it will not be present in yum.conf.
#
# @param username
#   username setting in the main section of yum.conf. When undef, it will not be present in yum.conf.
#
# @param throttle
#   throttle setting in the main section of yum.conf.
#   Rate in bytes/sec, allows a suffix of k, M, or G to be appended.
#   When undef, it will not be present in yum.conf.
#
# @param metadata_expire
#   metadata_expire setting in the main section of yum.conf.
#   Time in seconds, allows a suffix of m, h, or d to specify minutes, hours, or days.
#   Alternatively you can also specify the word never instead.
#   When undef, it will not be present in yum.conf.
#
# @param history_list_view
#   history_list_view setting in the main section of yum.conf.
#   Valid values are: 'cmds', 'commands', 'default', 'single-user-commands', or 'users'.
#   When undef, it will not be present in yum.conf.
#
# @param mdpolicy
#   mdpolicy setting in the main section of yum.conf.
#   Valid values are: 'group:all', 'group:main', 'group:primary', 'group:small', or 'instant'.
#   When undef, it will not be present in yum.conf.
#
# @param rpmverbosity
#   rpmverbosity setting in the main section of yum.conf.
#   Valid values are: 'critical', 'debug', 'emergency', 'error', 'info', or 'warn'.
#   When undef, it will not be present in yum.conf.
#
# @param http_caching
#   http_caching setting in the main section of yum.conf.
#   Valid values are: 'all', 'none', or 'packages'.
#   When undef, it will not be present in yum.conf.
#
# @param multilib_policy
#   multilib_policy setting in the main section of yum.conf.
#   Valid values are: 'all' or 'best'.
#   When undef, it will not be present in yum.conf.
#
# @param pkgpolicy
#   pkgpolicy setting in the main section of yum.conf.
#   Valid values are: 'last' or 'newest'.
#   When undef, it will not be present in yum.conf.
#
class yum (
  Boolean $exclude_hiera_merge                    = false,
  Boolean $manage_repos                           = false,
  Boolean $repos_hiera_merge                      = true,
  Boolean $rpm_gpg_keys_hiera_merge               = true,
  Stdlib::Absolutepath $config_path               = '/etc/yum.conf',
  Stdlib::Filemode $config_mode                   = '0644',
  Stdlib::Filemode $repos_d_mode                  = '0755',
  String $config_group                            = 'root',
  String $config_owner                            = 'root',
  String $repos_d_group                           = 'root',
  String $repos_d_owner                           = 'root',
  Optional[Hash] $repos                           = undef,
  Optional[Hash] $rpm_gpg_keys                    = undef,
  # parameters for yum.conf
  Array $color_list_available_downgrade           = [],
  Array $color_list_available_install             = [],
  Array $color_list_available_reinstall           = [],
  Array $color_list_available_upgrade             = [],
  Array $color_list_installed_extra               = [],
  Array $color_list_installed_newer               = [],
  Array $color_list_installed_older               = [],
  Array $color_list_installed_reinstall           = [],
  Array $color_search_match                       = [],
  Array $color_update_installed                   = [],
  Array $color_update_local                       = [],
  Array $color_update_remote                      = [],
  Array $commands                                 = [],
  Array $exclude                                  = [],
  Array $group_package_types                      = [],
  Array $history_record_packages                  = [],
  Array $installonlypkgs                          = [],
  Array $kernelpkgnames                           = [],
  Array $protected_packages                       = [],
  Array $tsflags                                  = [],
  Array[Stdlib::Absolutepath] $reposdir           = [],
  Optional[Variant[Boolean,String]] $distroverpkg = undef,
  Optional[Boolean] $alwaysprompt                 = undef,
  Optional[Boolean] $assumeyes                    = undef,
  Optional[Boolean] $clean_requirements_on_remove = undef,
  Optional[Boolean] $color                        = undef,
  Optional[Boolean] $diskspacecheck               = undef,
  Optional[Boolean] $enable_group_conditionals    = undef,
  Optional[Boolean] $exactarch                    = true,
  Optional[Boolean] $gpgcheck                     = false,
  Optional[Boolean] $groupremove_leaf_only        = undef,
  Optional[Boolean] $history_record               = undef,
  Optional[Boolean] $keepalive                    = undef,
  Optional[Boolean] $keepcache                    = true,
  Optional[Boolean] $localpkg_gpgcheck            = undef,
  Optional[Boolean] $obsoletes                    = true,
  Optional[Boolean] $overwrite_groups             = undef,
  Optional[Boolean] $plugins                      = false,
  Optional[Boolean] $protected_multilib           = undef,
  Optional[Boolean] $repo_gpgcheck                = undef,
  Optional[Boolean] $reset_nice                   = undef,
  Optional[Boolean] $showdupesfromrepos           = undef,
  Optional[Boolean] $skip_broken                  = undef,
  Optional[Boolean] $ssl_check_cert_permissions   = undef,
  Optional[Boolean] $sslverify                    = undef,
  Optional[Boolean] $tolerant                     = false,
  Optional[Integer[0, 10]] $debuglevel            = 2,
  Optional[Integer[0, 10]] $errorlevel            = undef,
  Optional[Integer] $bandwidth                    = undef,
  Optional[Integer] $installonly_limit            = undef,
  Optional[Integer] $mirrorlist_expire            = undef,
  Optional[Integer] $recent                       = undef,
  Optional[Integer] $retries                      = undef,
  Optional[Integer] $timeout                      = undef,
  Optional[Stdlib::Absolutepath] $cachedir        = '/var/cache/yum/$basearch/$releasever',
  Optional[Stdlib::Absolutepath] $installroot     = undef,
  Optional[Stdlib::Absolutepath] $logfile         = '/var/log/yum.log',
  Optional[Stdlib::Absolutepath] $persistdir      = undef,
  Optional[Stdlib::Absolutepath] $pluginconfpath  = undef,
  Optional[Stdlib::Absolutepath] $pluginpath      = undef,
  Optional[Stdlib::Absolutepath] $sslcacert       = undef,
  Optional[Stdlib::Absolutepath] $sslclientcert   = undef,
  Optional[Stdlib::Absolutepath] $sslclientkey    = undef,
  Optional[Stdlib::Httpurl] $bugtracker_url       = undef,
  Optional[Stdlib::Httpurl] $proxy                = undef,
  Optional[String] $password                      = undef,
  Optional[String] $proxy_password                = undef,
  Optional[String] $proxy_username                = undef,
  Optional[String] $syslog_device                 = undef,
  Optional[String] $syslog_facility               = undef,
  Optional[String] $syslog_ident                  = undef,
  Optional[String] $username                      = undef,
  Optional[Variant[Integer,Float,Pattern[/^\d+(.\d+|)(k|M|G)*$/]]] $throttle                    = undef,
  Optional[Variant[Integer,Pattern[/^(\d+(m|h|d)*|never|)$/]]] $metadata_expire                 = '6h',
  Optional[Enum['cmds','commands','default','single-user-commands','users']] $history_list_view = undef,
  Optional[Enum['group:all','group:main','group:primary','group:small','instant']] $mdpolicy    = undef,
  Optional[Enum['critical','debug','emergency','error','info','warn']] $rpmverbosity            = undef,
  Optional[Enum['all','none','packages']] $http_caching                                         = undef,
  Optional[Enum['all','best']] $multilib_policy                                                 = undef,
  Optional[Enum['last', 'newest']] $pkgpolicy                                                   = undef,
) {

  $_valid_colors = [
    'bg:black', 'bg:blue', 'bg:cyan', 'bg:green', 'bg:magenta', 'bg:red', 'bg:white', 'bg:yellow', 'blink', 'bold', 'dim',
    'fg:black', 'fg:blue', 'fg:cyan', 'fg:green', 'fg:magenta', 'fg:red', 'fg:white', 'fg:yellow', 'reverse', 'underline',
  ]

  if $color_list_available_downgrade - $_valid_colors != [] {
    fail("yum::color_list_available_downgrade contains an invalid value. Valid values are <${_valid_colors}>.")
  }

  if $color_list_available_install - $_valid_colors != [] {
    fail("yum::color_list_available_install contains an invalid value. Valid values are <${_valid_colors}>.")
  }

  if $color_list_available_reinstall - $_valid_colors != [] {
    fail("yum::color_list_available_reinstall contains an invalid value. Valid values are <${_valid_colors}>.")
  }

  if $color_list_available_upgrade - $_valid_colors != [] {
    fail("yum::color_list_available_upgrade contains an invalid value. Valid values are <${_valid_colors}>.")
  }

  if $color_list_installed_extra - $_valid_colors != [] {
    fail("yum::color_list_installed_extra contains an invalid value. Valid values are <${_valid_colors}>.")
  }

  if $color_list_installed_newer - $_valid_colors != [] {
    fail("yum::color_list_installed_newer contains an invalid value. Valid values are <${_valid_colors}>.")
  }

  if $color_list_installed_older - $_valid_colors != [] {
    fail("yum::color_list_installed_older contains an invalid value. Valid values are <${_valid_colors}>.")
  }

  if $color_list_installed_reinstall - $_valid_colors != [] {
    fail("yum::color_list_installed_reinstall contains an invalid value. Valid values are <${_valid_colors}>.")
  }

  if $color_search_match - $_valid_colors != [] {
    fail("yum::color_search_match contains an invalid value. Valid values are <${_valid_colors}>.")
  }

  if $color_update_installed - $_valid_colors != [] {
    fail("yum::color_update_installed contains an invalid value. Valid values are <${_valid_colors}>.")
  }

  if $color_update_local - $_valid_colors != [] {
    fail("yum::color_update_local contains an invalid value. Valid values are <${_valid_colors}>.")
  }

  if $color_update_remote - $_valid_colors != [] {
    fail("yum::color_update_remote contains an invalid value. Valid values are <${_valid_colors}>.")
  }

  if $group_package_types - ['optional', 'default', 'mandatory'] != [] {
    fail('yum::group_package_types contains an invalid value. Valid values are <optional>, <default>, and <mandatory>.')
  }

  if $tsflags - ['justdb', 'nocontexts', 'nodocs', 'noscripts', 'notriggers', 'repackage', 'test'] != [] {
    fail('yum::tsflags contains an invalid value. Valid values are <justdb>, <nocontexts>, <nodocs>, <noscripts>, <notriggers>, <repackage>, and <test>.')
  }

  # <convert booleans to string values>
  $alwaysprompt_string = $alwaysprompt ? {
    Boolean => bool2str($alwaysprompt, '1', '0'),
    default => undef,
  }
  $assumeyes_string = $assumeyes ? {
    Boolean => bool2str($assumeyes, '1', '0'),
    default => undef,
  }
  $clean_requirements_on_remove_string = $clean_requirements_on_remove ? {
    Boolean => bool2str($clean_requirements_on_remove, '1', '0'),
    default => undef,
  }
  $color_string = $color ? {
    Boolean => bool2str($color, '1', '0'),
    default => undef,
  }
  $diskspacecheck_string = $diskspacecheck ? {
    Boolean => bool2str($diskspacecheck, '1', '0'),
    default => undef,
  }
  $enable_group_conditionals_string = $enable_group_conditionals ? {
    Boolean => bool2str($enable_group_conditionals, '1', '0'),
    default => undef,
  }
  $exactarch_string = $exactarch ? {
    Boolean => bool2str($exactarch, '1', '0'),
    default => undef,
  }
  $gpgcheck_string = $gpgcheck ? {
    Boolean => bool2str($gpgcheck, '1', '0'),
    default => undef,
  }
  $groupremove_leaf_only_string = $groupremove_leaf_only ? {
    Boolean => bool2str($groupremove_leaf_only, '1', '0'),
    default => undef,
  }
  $history_record_string = $history_record ? {
    Boolean => bool2str($history_record, '1', '0'),
    default => undef,
  }
  $keepalive_string = $keepalive ? {
    Boolean => bool2str($keepalive, '1', '0'),
    default => undef,
  }
  $keepcache_string = $keepcache ? {
    Boolean => bool2str($keepcache, '1', '0'),
    default => undef,
  }
  $localpkg_gpgcheck_string = $localpkg_gpgcheck ? {
    Boolean => bool2str($localpkg_gpgcheck, '1', '0'),
    default => undef,
  }
  $obsoletes_string = $obsoletes ? {
    Boolean => bool2str($obsoletes, '1', '0'),
    default => undef,
  }
  $overwrite_groups_string = $overwrite_groups ? {
    Boolean => bool2str($overwrite_groups, '1', '0'),
    default => undef,
  }
  $plugins_string = $plugins ? {
    Boolean => bool2str($plugins, '1', '0'),
    default => undef,
  }
  $protected_multilib_string = $protected_multilib ? {
    Boolean => bool2str($protected_multilib, '1', '0'),
    default => undef,
  }
  $repo_gpgcheck_string = $repo_gpgcheck ? {
    Boolean => bool2str($repo_gpgcheck, '1', '0'),
    default => undef,
  }
  $reset_nice_string = $reset_nice ? {
    Boolean => bool2str($reset_nice, '1', '0'),
    default => undef,
  }
  $showdupesfromrepos_string = $showdupesfromrepos ? {
    Boolean => bool2str($showdupesfromrepos, '1', '0'),
    default => undef,
  }
  $skip_broken_string = $skip_broken ? {
    Boolean => bool2str($skip_broken, '1', '0'),
    default => undef,
  }
  $ssl_check_cert_permissions_string = $ssl_check_cert_permissions ? {
    Boolean => bool2str($ssl_check_cert_permissions, '1', '0'),
    default => undef,
  }
  $sslverify_string = $sslverify ? {
    Boolean => bool2str($sslverify, '1', '0'),
    default => undef,
  }
  $tolerant_string = $tolerant ? {
    Boolean => bool2str($tolerant, '1', '0'),
    default => undef,
  }
  # </convert booleans to string values>

  $distroverpkg_string = $distroverpkg ? {
    true    => "${::operatingsystem.downcase}-release",
    String  => $distroverpkg,
    default => undef,
  }

  case $exclude_hiera_merge {
    true:    { $exclude_real = lookup('yum::exclude', Array[String], unique ) }
    default: { $exclude_real = $exclude }
  }

  if $repos != undef {
    case $repos_hiera_merge {
      true:    { $repos_real = lookup('yum::repos', Hash, hash ) }
      default: { $repos_real = $repos }
    }

    $repos_real.each |$key,$value| {
      ::yum::repo { $key:
        * => $value,
      }
    }
  }

  if $rpm_gpg_keys != undef {
    case $rpm_gpg_keys_hiera_merge {
      true:    { $rpm_gpg_keys_real = lookup('yum::rpm_gpg_keys', Hash, hash ) }
      default: { $rpm_gpg_keys_real = $rpm_gpg_keys }
    }

    $rpm_gpg_keys_real.each |$key,$value| {
      ::yum::rpm_gpg_key { $key:
        * => $value,
      }
    }
  }

  include ::yum::updatesd

  package { 'yum':
    ensure => installed,
  }

  file { 'yum_config':
    ensure  => file,
    path    => $config_path,
    content => template('yum/yum.conf.erb'),
    owner   => $config_owner,
    group   => $config_group,
    mode    => $config_mode,
    require => Package['yum'],
  }

  file { '/etc/yum.repos.d':
    ensure  => directory,
    purge   => $manage_repos,
    recurse => $manage_repos,
    owner   => $repos_d_owner,
    group   => $repos_d_group,
    mode    => $repos_d_mode,
    require => File['yum_config'],
    notify  => Exec['clean_yum_cache'],
  }

  exec { 'clean_yum_cache':
    command     => 'yum clean all',
    path        => '/bin:/usr/bin:/sbin:/usr/sbin',
    refreshonly => true,
  }
}
