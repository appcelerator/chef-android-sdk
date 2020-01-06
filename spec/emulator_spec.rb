require 'spec_helper'

describe 'emulator' do
  platform 'ubuntu'
  step_into :android_emulator
  default_attributes['ark']['prefix_root'] = '/usr/local/'
  default_attributes['ark']['prefix_home'] = '/usr/local/'
  default_attributes['android']['set_environment_variables'] = true

  context 'install' do
    recipe do
      android_emulator 'android-23-armeabi-v7a' do
        home             '/home/random'
        platform         'android-23'
        skin             '1080x1920'
        abi              'armeabi-v7a'
        user             'random'
        group            'staff'
        sdcard           '256M'
        disk_size        '2048M'
        ram              2048
        heap             256
      end
    end

    it { is_expected.to create_directory('/home/random/.android') }
    it { is_expected.to create_directory('/home/random/.android/avd') }
    it { is_expected.to run_execute('create avd android-23-armeabi-v7a') }
    it { is_expected.to render_file('/home/random/.android/avd/android-23-armeabi-v7a.avd/config.ini') }
    it { is_expected.to render_file('/home/random/.android/avd/android-23-armeabi-v7a.avd/quickBootChoice.ini') }
    # it { is_expected.to run_execute('launch emulator android-23-armeabi-v7a') }
  end

  context 'uninstall' do
    recipe do
      android_emulator 'android-23-armeabi-v7a' do
        home   '/home/random'
        user   'random'
        action :uninstall
      end
    end
    before do
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with('/home/random/.android/avd/android-23-armeabi-v7a.avd').and_return(true)
    end
    it { is_expected.to run_execute('delete avd android-23-armeabi-v7a') }
  end
end
