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

        it 'should work with no errors' do
          pp = <<-EOS
          include ::yum
          EOS

          apply_manifest(pp, :catch_failures => true)
        end

        describe package('yum') do
          it { is_expected.to be_installed }
        end

        yum_conf = <<-END.gsub(/^\s+\|/, '')
          |# This file is being maintained by Puppet.
          |# DO NOT EDIT
          |
          |[main]
          |cachedir=/var/cache/yum/$basearch/$releasever
          |keepcache=1
          |debuglevel=2
          |logfile=/var/log/yum.log
          |tolerant=0
          |exactarch=1
          |obsoletes=1
          |gpgcheck=0
          |plugins=0
          |
          |# Note: yum-RHN-plugin doesn't honor this.
          |metadata_expire=6h
        END

        describe file('/etc/yum.conf') do
          it { is_expected.to be_file }
          it { is_expected.to be_mode 644 }
          it { is_expected.to be_owned_by 'root' }
          it { is_expected.to be_grouped_into 'root' }
          its(:content) { is_expected.to match yum_conf }
        end

        describe file('/etc/yum.repos.d') do
          it { is_expected.to be_directory }
          it { is_expected.to be_mode 755 }
          it { is_expected.to be_owned_by 'root' }
          it { is_expected.to be_grouped_into 'root' }
        end
      end
    end
  end
end
