# default file/URL/checksum for linux
platform = 'linux'
checksum = '92ffee5a1d98d856634e8b71132e8a95d96c83a63fde1099be3d86df3106def9' # sdk tools 4333796 linux checksum
group = 'root'

# Overrides for Mac OS X
if node['platform_family'] == 'mac_os_x'
  platform = 'darwin'
  checksum = 'ecb29358bc0f13d7c2fa0f9290135a5b608e38434aad9bf7067d0252c160853e' # sdk tools 4333796 mac checksum
  group = 'wheel'
elsif node['platform'] == 'windows'
  platform = 'windows'
  checksum = '7e81d69c303e47a4f0e748a6352d85cd0c8fd90a5a95ae4e076b5e5f960d3c7a' # sdk tools 4333796 windows checksum
end

default['android']['path']                      = '/usr/local/android-sdk'
default['android']['owner']                     = 'root'
default['android']['group']                     = group
default['android']['set_environment_variables'] = true

default['android']['version']                   = '4333796'
default['android']['checksum']                  = checksum
default['android']['download_url']              = "https://dl.google.com/android/repository/sdk-tools-#{platform}-#{node['android']['version']}.zip"

#
# List of Android SDK components to preinstall:
# Selection based on
# - Platform usage statistics (see http://developer.android.com/about/dashboards/index.html)
# - Build Tools releases: http://developer.android.com/tools/revisions/build-tools.html
#
# Hint:
# Add 'tools' to the list below if you wish to get the latest version,
# without having to adapt 'version' and 'checksum' attributes of this cookbook.
# Note that it will require (waste) some extra download effort.
#
default['android']['components'] = %w( platform-tools
                                       build-tools;26.0.1
                                       platforms;android-23
                                       emulator
                                       system-images;android-23;default;armeabi-v7a
                                       extras;google;google_play_services
                                       extras;google;m2repository
                                       extras;android;m2repository )

default['android']['scripts']['path']  = '/usr/local/bin'
default['android']['scripts']['owner'] = node['android']['owner']
default['android']['scripts']['group'] = node['android']['group']

default['android']['java_from_system']          = false

default['android']['maven-rescue']              = false
