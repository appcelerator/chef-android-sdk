include_recipe 'test::_user'

apt_update 'update'

android_ndk 'r10e' do
  owner 'random'
  group 'staff'
end
