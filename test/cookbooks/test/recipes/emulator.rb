include_recipe 'test::component' # Need to install sdk and platform/system-images first!

android_emulator 'android-23-armeabi-v7a' do
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
