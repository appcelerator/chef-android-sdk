include_recipe 'test::_user'
include_recipe 'test::_base'

android_sdk '/usr/local/android-sdk' do
  owner 'random'
  group 'staff'
end
