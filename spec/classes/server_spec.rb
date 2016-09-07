require 'spec_helper'

# To get this class working, you need to fix two templates in the apache module.
# To activate these tests, remove the lines with '=begin' and '=end'
# You need to add an @-sign in two templates to fix it:
#
# diff --git a/templates/httpd.conf.erb b/templates/httpd.conf.erb
# index 5b5d963..e8bc6f3 100644
# --- a/templates/httpd.conf.erb
# +++ b/templates/httpd.conf.erb
# @@ -361,7 +361,7 @@ HostnameLookups Off
#  # filesystems.  Please see
#  # http://httpd.apache.org/docs/2.2/mod/core.html#enablesendfile
#  #
# -<% if sendfile %>
# +<% if @sendfile %>
#  EnableSendfile <%= @sendfile %>
#  <% end %>
#
# diff --git a/templates/mod/proxy.conf.erb b/templates/mod/proxy.conf.erb
# index 2360e05..c3629d6 100644
# --- a/templates/mod/proxy.conf.erb
# +++ b/templates/mod/proxy.conf.erb
# @@ -6,7 +6,7 @@
#    # Do not enable proxying with ProxyRequests until you have secured your
#    # server.  Open proxy servers are dangerous both to your network and to the
#    # Internet at large.
# -  ProxyRequests <%= proxy_requests %>
# +  ProxyRequests <%= @proxy_requests %>
#
#    <Proxy *>
#      Order deny,allow

=begin
describe 'yum::server' do
  mandatory_facts = {
    :fqdn                   => 'no-hiera-data.example.local',
    :test                   => 'no-hiera-data',
    :osfamily               => 'RedHat',
    :operatingsystemrelease => '7.0.1406',
    :operatingsystem        => 'RedHat',
  }
  mandatory_params = {}
  let(:facts) { mandatory_facts }
  let(:params) { mandatory_params }

  context 'with defaults for all parameters' do
    it { should contain_class('apache') }

    it { should contain_package('createrepo').with_ensure('installed') }
    it { should contain_package('hardlink').with_ensure('installed') }
    it do
      should contain_file('gpg_keys_dir').with({
        'ensure'  => 'directory',
        'path'    => '/opt/repos/keys',
        'recurse' => 'true',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
        'require' => 'Common::Mkdir_p[/opt/repos]',
      })
    end
    it do
      should contain_file('dot_rpmmacros').with({
        'ensure'  => 'file',
        'path'    => '/root/.rpmmacros',
        'content' => "%_gpg_name Root\n%_signature gpg\n",
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
      })
    end
    it { should contain_common__mkdir_p('/opt/repos') }
    it do
      should contain_apache__vhost('yumrepo').with({
        'docroot'  => '/opt/repos',
        'port'     => '80',
        'template' => 'yum/yumrepo.conf.erb',
        'require' => 'Common::Mkdir_p[/opt/repos]',
      })
    end
  end

  context 'with contact_email set to valid string <spec@test.local>' do
    # parameter is only used in template, can't be tested :(
  end

  context 'with docroot set to valid string </spec/tests>' do
    let(:params) { mandatory_params.merge({ :docroot => '/spec/tests' }) }
    it do
      should contain_file('gpg_keys_dir').with({
        'path'    => '/spec/tests/keys',
        'require' => 'Common::Mkdir_p[/spec/tests]',
      })
    end
    it { should contain_common__mkdir_p('/spec/tests') }
    it do
      should contain_apache__vhost('yumrepo').with({
        'docroot' => '/spec/tests',
        'require' => 'Common::Mkdir_p[/spec/tests]',
      })
    end
  end

  context 'with gpg_keys_path set to valid string <spectests>' do
    let(:params) { mandatory_params.merge({ :gpg_keys_path => 'spectests' }) }
    it { should contain_file('gpg_keys_dir').with_path('/opt/repos/spectests') }
  end

  context 'with gpg_user_name set to valid string <spectester>' do
    let(:params) { mandatory_params.merge({ :gpg_user_name => 'spectester' }) }
    it { should contain_file('dot_rpmmacros').with_content("%_gpg_name spectester\n%_signature gpg\n") }
  end

  context 'with yum_server set to valid string <jum>' do
    # parameter is only used in template, can't be tested :(
  end

  context 'with yum_server_http_listen_ip set to valid string <10.0.0.242>' do
    # parameter is only used in template, can't be tested :(
  end

  describe 'variable type and content validations' do
    # set needed custom facts and variables
    let(:facts) { mandatory_facts }
    let(:mandatory_params) { {} }

    validations = {
      'absolute_path' => {
        :name    => %w(docroot),
        :valid   => ['/absolute/filepath', '/absolute/directory/'],
        :invalid => ['../invalid', %w(array), { 'ha' => 'sh' }, 3, 2.42, true, false, nil],
        :message => 'is not an absolute path',
      },
      'string' => {
        :name    => %w(gpg_keys_path gpg_user_name yum_server yum_server_http_listen_ip),
        :valid   => ['string'],
        :invalid => [%w(array), { 'ha' => 'sh' }, true, false],
        :message => 'is not a string',
      },
    }

    validations.sort.each do |type, var|
      var[:name].each do |var_name|
        var[:params] = {} if var[:params].nil?
        var[:valid].each do |valid|
          context "when #{var_name} (#{type}) is set to valid #{valid} (as #{valid.class})" do
            let(:params) { [mandatory_params, var[:params], { :"#{var_name}" => valid, }].reduce(:merge) }
            it { should compile }
          end
        end

        var[:invalid].each do |invalid|
          context "when #{var_name} (#{type}) is set to invalid #{invalid} (as #{invalid.class})" do
            let(:params) { [mandatory_params, var[:params], { :"#{var_name}" => invalid, }].reduce(:merge) }
            it 'should fail' do
              expect { should contain_class(subject) }.to raise_error(Puppet::Error, /#{var[:message]}/)
            end
          end
        end
      end # var[:name].each
    end # validations.sort.each
  end # describe 'variable type and content validations'
end
=end
