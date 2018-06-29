user 'random' do
  group 'staff'
end

apt_update 'update'

android_sdk 'whatever' do
  owner 'random'
  group 'staff'
end
