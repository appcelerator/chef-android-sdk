user 'random' do
  group 'staff'
end

apt_update 'update'

android_ndk 'r10e' do
  owner 'random'
  group 'staff'
end
