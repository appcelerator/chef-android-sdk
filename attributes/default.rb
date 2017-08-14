# default file/URL/checksum for linux
platform = 'linux'
checksum = '444e22ce8ca0f67353bda4b85175ed3731cae3ffa695ca18119cbacef1c1bea0' # sdk tools 3859397 linux checksum
group = 'root'

# Overrides for Mac OS X
if node['platform'] == 'mac_os_x'
  platform = 'darwin'
  checksum = '4a81754a760fce88cba74d69c364b05b31c53d57b26f9f82355c61d5fe4b9df9' # sdk tools 3859397 mac checksum
  group = 'wheel'
elsif node['platform'] == 'windows'
  platform = 'windows'
  checksum = '7f6037d3a7d6789b4fdc06ee7af041e071e9860c51f66f7a4eb5913df9871fd2' # sdk tools 3859397 windows checksum
end

default['android-sdk']['name']                      = 'android-sdk'
default['android-sdk']['owner']                     = 'root'
default['android-sdk']['group']                     = group
default['android-sdk']['setup_root']                = nil # ark defaults (/usr/local) is used if this attribute is not defined
default['android-sdk']['set_environment_variables'] = true

default['android-sdk']['version']                   = '3859397'
default['android-sdk']['checksum']                  = checksum
default['android-sdk']['download_url']              = "https://dl.google.com/android/repository/sdk-tools-#{platform}-#{node['android-sdk']['version']}.zip"

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
default['android-sdk']['components']                = %w( platform-tools
                                                          build-tools;26.0.1
                                                          platforms;android-23
                                                          system-images;android-23;default;armeabi-v7a
                                                          extras;google;google_play_services
                                                          extras;google;m2repository
                                                          extras;android;m2repository )

default['android-sdk']['license']['white_list']     = %w(.+)
default['android-sdk']['license']['black_list']     = []    # e.g. ['intel-.+', 'mips-.+', 'android-wear-sdk-license-.+']
default['android-sdk']['license']['default_answer'] = 'n'   # 'y' or 'n' ('yes' or 'no')

# Timeout in seconds for sdk component install expect script
default['android-sdk']['install-timeout']           = 1800

default['android-sdk']['scripts']['path']           = '/usr/local/bin'
default['android-sdk']['scripts']['owner']          = node['android-sdk']['owner']
default['android-sdk']['scripts']['group']          = node['android-sdk']['group']

default['android-sdk']['java_from_system']          = false

default['android-sdk']['maven-rescue']              = false
