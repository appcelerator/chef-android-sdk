user 'random' do
  group       'staff'
  manage_home true
  shell       '/bin/bash'
  home        '/Users/random' if platform?('mac_os_x')
  # attributes necessary to set password of 'password' on macOS
  iterations  25_000 if platform?('mac_os_x')
  salt        '2961f8ef3c544df3b114b7847ed4307382a9a9e6b3c8c252ffa8a932629d4334' if platform?('mac_os_x')
  password    '4bb7997f6e499a97f8e3bae46a387386e15de774fb136579ea89c220679d8232615ce87511b583dd25f6608fa818c97138a2d4e41795700619a5c33ebb0f806b3756235723a0454a2a04eb9746b30150adace272e0bbe8670cc89edd52def8e004fce3e0e19e8d0d438efa8b14599f499313cd31829576dcd3e144126370726b' if platform?('mac_os_x')
end

directory '/Users/random' do
  owner 'random'
  group 'staff'
  only_if { platform?('mac_os_x') }
end

android_sdk '/usr/local/android-sdk' do
  owner 'random'
  group 'staff'
end
