require 'spec_helper_acceptance'

describe 'yum::updatesd class', unless: RSpec.configuration.yum_full do
  context 'yum::updatesd' do
    context 'with default values for all parameters' do
      context 'it should be idempotent' do
        it 'works with no errors' do
          pp = <<-EOS
          include ::yum::updatesd
          EOS

          # Run it twice and test for idempotency
          apply_manifest(pp, catch_failures: true)
          apply_manifest(pp, catch_changes: true)
        end
      end

      context 'should contain resources' do
        describe package('yum-updatesd') do
          it { is_expected.not_to be_installed }
        end

        describe service('yum-updatesd') do
          it { is_expected.not_to be_enabled }
          it { is_expected.not_to be_running }
        end
      end
    end
  end
end
