require 'spec_helper_acceptance'

describe 'yum::server class', unless: RSpec.configuration.yum_full do
  context 'yum::server' do
    context 'with default values for all parameters' do
      context 'it should be idempotent' do
        it 'should work with no errors' do
          pp = <<-EOS
          include ::yum::server
          EOS

          # Run it twice and test for idempotency
          apply_manifest(pp, :catch_failures => true)
          apply_manifest(pp, :catch_changes  => true)
        end
      end

      context 'should contain resources' do
        describe package('createrepo') do
          it { is_expected.to be_installed }
        end

        describe package('hardlink') do
          it { is_expected.to be_installed }
        end

        describe file('/opt/repos/keys') do
          it { is_expected.to be_directory }
          it { is_expected.to be_mode 755 }
          it { is_expected.to be_owned_by 'root' }
          it { is_expected.to be_grouped_into 'root' }
        end

        describe file('/root/.rpmmacros') do
          it { is_expected.to be_file }
          it { is_expected.to be_mode 644 }
          it { is_expected.to be_owned_by 'root' }
          it { is_expected.to be_grouped_into 'root' }
        end

        describe service('httpd') do
          it { is_expected.to be_enabled }
          it { is_expected.to be_running }
        end
      end
    end
  end
end
