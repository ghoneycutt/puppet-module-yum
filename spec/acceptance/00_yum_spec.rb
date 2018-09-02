require 'spec_helper_acceptance'

describe 'yum class' do
  context 'yum' do
    context 'with default values for all parameters' do
      context 'it should be idempotent' do
        it 'should work with no errors' do
          pp = <<-EOS
          include ::yum
          EOS

          # Run it twice and test for idempotency
          apply_manifest(pp, :catch_failures => true)
          apply_manifest(pp, :catch_changes  => true)
        end
      end

      context 'should contain resources' do

        pp = <<-EOS
        include ::yum
        EOS

        apply_manifest(pp, :catch_failures => true)

        describe package('yum') do
          it { is_expected.to be_installed }
        end

        yum_conf = <<-END.gsub(/^\s+\|/, '')
          |[main]
          |cachedir=/var/cache/yum/$basearch/$releasever
          |keepcache=0
          |debuglevel=2
          |logfile=/var/log/yum.log
          |exactarch=1
          |obsoletes=1
          |gpgcheck=1
          |plugins=1
          |installonly_limit=5
          |bugtracker_url=http://bugs.centos.org/set_project.php?project_id=23&ref=http://bugs.centos.org/bug_report_page.php?category=yum
          |distroverpkg=centos-release
          |
          |
          |#  This is the default, if you make this bigger yum won't see if the metadata
          |# is newer on the remote and so you'll "gain" the bandwidth of not having to
          |# download the new metadata and "pay" for it by yum not having correct
          |# information.
          |#  It is esp. important, to have correct metadata, for distributions like
          |# Fedora which don't keep old packages around. If you don't like this checking
          |# interupting your command line usage, it's much better to have something
          |# manually check the metadata once an hour (yum-updatesd will do this).
          |# metadata_expire=90m
          |
          |# PUT YOUR REPOS HERE OR IN separate files named file.repo
          |# in /etc/yum.repos.d
        END

        describe file('/etc/yum.conf') do
          it { is_expected.to be_file }
          it { is_expected.to be_mode 0644 }
          it { is_expected.to be_owned_by 'root' }
          it { is_expected.to be_grouped_into 'root' }
          its(:content) { is_expected.to match yum_conf }
        end

        describe file('/etc/yum.repos.d') do
          it { is_expected.to be_directory }
          it { is_expected.to be_mode 0755 }
          it { is_expected.to be_owned_by 'root' }
          it { is_expected.to be_grouped_into 'root' }
        end

        describe service('yum') do
          it { is_expected.to be_running }
          it { is_expected.to be_enabled }
        end
      end
    end
  end
end
