require 'spec_helper_acceptance'

describe 'yum::updatesd class' do
  context 'yum::updatesd' do
    context 'with default values for all parameters' do
      context 'it should be idempotent' do
        it 'should work with no errors' do
          pp = <<-EOS
          include ::yum::updatesd
          EOS

          # Run it twice and test for idempotency
          apply_manifest(pp, :catch_failures => true)
          apply_manifest(pp, :catch_changes  => true)
        end
      end

      context 'should contain resources' do

        it 'should work with no errors' do
          pp = <<-EOS
          include ::yum::updatesd
          EOS

          apply_manifest(pp, :catch_failures => true)
        end

        describe package('yum-updatesd') do
          it { is_expected.to_not be_installed }
        end

        describe service('yum-updatesd') do
          it { is_expected.to_not be_enabled }
          it { is_expected.to_not be_running }
        end
      end
    end
  end
end
