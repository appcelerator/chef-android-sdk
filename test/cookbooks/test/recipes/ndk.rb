user 'random' do
  manage_home true
  home '/home/random'
  group 'staff'
end

android_ndk 'r10e' do
  owner 'random'
  group 'staff'
end
