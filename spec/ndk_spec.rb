require 'spec_helper'

describe 'ndk' do
  platform 'mac_os_x' # Use mac so we can test /etc/profile.d setup
  step_into :android_ndk
  default_attributes['ark']['prefix_root'] = '/usr/local/'
  default_attributes['android']['set_environment_variables'] = true

  context 'when setting simple value' do
    recipe do
      android_ndk 'r10e' do
        owner 'random'
        group 'staff'
      end
    end

    it { is_expected.to put_ark('android-ndk-r10e') }
    it { is_expected.to run_execute('Grant all users to execute android-ndk-r10e files') }
    it { is_expected.to create_env('ANDROID_NDK_R10E') }
  end

  # TODO: Test :uninstall action
end
