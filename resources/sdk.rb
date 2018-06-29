#
# Cookbook Name:: android
# Resource:: sdk
#
resource_name :android_sdk

default_action :install

# TODO: Add a mapping from the "nice names" (like 26.0.2) to the specific version/rev under the hood with checksums
CHECKSUMS = {
  '4333796' => {
    'darwin'  => 'ecb29358bc0f13d7c2fa0f9290135a5b608e38434aad9bf7067d0252c160853e',
    'linux'   => '92ffee5a1d98d856634e8b71132e8a95d96c83a63fde1099be3d86df3106def9',
    'windows' => '7e81d69c303e47a4f0e748a6352d85cd0c8fd90a5a95ae4e076b5e5f960d3c7a',
  },
  '3859397' => {
    'darwin'  => '4a81754a760fce88cba74d69c364b05b31c53d57b26f9f82355c61d5fe4b9df9',
    'linux'   => '444e22ce8ca0f67353bda4b85175ed3731cae3ffa695ca18119cbacef1c1bea0',
    'windows' => '7f6037d3a7d6789b4fdc06ee7af041e071e9860c51f66f7a4eb5913df9871fd2',
  },
}.freeze

# Determine defaults
platform = 'linux'
owner = 'root'
group = 'root'

# Overrides by platform
if node['platform'] == 'mac_os_x'
  platform = 'darwin'
  group = 'wheel'
elsif node['platform'] == 'windows'
  platform = 'windows'
end

property :version, String, default: '3859397'
property :owner, String, default: owner
property :group, String, default: group
property :checksum, String
property :url, String
property :path, String # parent path to install?

def initialize(*args)
  super

  @run_context.include_recipe 'ark'
end

action :install do
  android_home = ::File.join(new_resource.path || node['ark']['prefix_home'], 'android-sdk')
  checksum = new_resource.checksum || CHECKSUMS[new_resource.version.to_sym][platform]
  url = new_resource.url || "https://dl.google.com/android/repository/sdk-tools-#{platform}-#{new_resource.version}.zip"

  ark 'android-sdk' do
    url url
    path new_resource.path if new_resource.path
    checksum checksum
    version new_resource.version
    prefix_root new_resource.path if new_resource.path
    prefix_home new_resource.path if new_resource.path
    owner new_resource.owner
    group new_resource.group
    action :put
    strip_components 0
  end

  #
  # Fix non-friendly 0750 permissions in order to make android-sdk available to all system users
  #
  %w(add-ons platforms tools).each do |subfolder|
    directory ::File.join(android_home, subfolder) do
      mode 0755
      user new_resource.owner
      group new_resource.group
      recursive true
    end
  end

  # TODO: find a way to handle 'chmod stuff' below with own chef resource (idempotence stuff...)
  execute 'Grant all users to read android files' do
    command "chmod -R a+r #{android_home}/*"
    user new_resource.owner
    group new_resource.group
  end
  execute 'Grant all users to execute android tools' do
    command "chmod -R a+X #{::File.join(android_home, 'tools')}/*"
    user new_resource.owner
    group new_resource.group
  end

  # Make /etc/profile.d so the cookbooks that stick env vars in there won't fail
  directory '/etc/profile.d' do
    owner 'root'
    group 'wheel'
    only_if { platform?('mac_os_x') }
  end

  # Configure environment variables (ANDROID_HOME and PATH)
  template '/etc/profile.d/android-sdk.sh' do
    mode 0644
    owner new_resource.owner
    group new_resource.group
    cookbook 'android'
    variables lazy {
      {
        android_home: android_home,
      }
    }
  end
end
