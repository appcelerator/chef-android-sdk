user 'random' do
  manage_home true
  home '/home/random'
  group 'staff'
end

apt_update 'update'

android_sdk 'whatever' do
  owner 'random'
  group 'staff'
end
