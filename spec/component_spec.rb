require 'spec_helper'

describe 'component' do
  platform 'ubuntu'
  step_into :android_component
  default_attributes['ark']['prefix_root'] = '/usr/local/'
  default_attributes['ark']['prefix_home'] = '/usr/local/'
  default_attributes['android']['set_environment_variables'] = true
  default_attributes['android']['java_from_system'] = true

  context 'install' do
    recipe do
      android_component 'system-images;android-23;google_apis;armeabi-v7a' do
        user 'random'
        group 'staff'
      end
    end

    it { is_expected.to install_package('expect') }
    it { is_expected.to run_script('Install Android SDK component system-images;android-23;google_apis;armeabi-v7a').with(:interpreter => 'expect') }
    # TODO: test notifies to "fix ownership"
  end
end
