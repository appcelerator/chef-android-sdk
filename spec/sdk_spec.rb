require 'spec_helper'

describe 'sdk' do
  platform 'mac_os_x' # Use mac so we can test /etc/profile.d setup
  step_into :android_sdk
  default_attributes['ark']['prefix_root'] = '/usr/local/'
  default_attributes['android']['set_environment_variables'] = true

  context 'when setting simple value' do
    recipe do
      android_sdk '/usr/local/android-sdk'
    end

    it { is_expected.to put_ark('android-sdk') }
    it { is_expected.to create_directory('/usr/local/android-sdk/add-ons') }
    it { is_expected.to create_directory('/usr/local/android-sdk/platforms') }
    it { is_expected.to create_directory('/usr/local/android-sdk/tools') }
    it { is_expected.to run_execute('Grant all users to read android files') }
    it { is_expected.to run_execute('Grant all users to execute android tools') }
    it { is_expected.to create_env('ANDROID_HOME').with(:value => '/usr/local/android-sdk/') }
    it { is_expected.to create_env('ANDROID_HOME_PATH').with(:key_name => 'PATH') }
  end

  # TODO: Test :update action
end
