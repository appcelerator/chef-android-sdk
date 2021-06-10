#
# Cookbook Name:: android
# Resource:: sdk
#
resource_name :android_sdk
provides :android_sdk

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
if node['platform_family'] == 'mac_os_x'
  platform = 'darwin'
  group = 'wheel'
elsif node['platform'] == 'windows'
  platform = 'windows'
end

property :version, String, default: '4333796'
property :owner, String, default: owner
property :group, [String, Integer], default: group
property :checksum, String, default: lazy { |r| CHECKSUMS[r.version][platform] }
property :url, String, default: lazy { |r| "https://dl.google.com/android/repository/sdk-tools-#{platform}-#{r.version}.zip" }
property :path, String, name_property: true
property :timeout, Integer, default: 1800
property :mode, [Integer, String], default: 0755

def initialize(*args)
  super

  @run_context.include_recipe 'ark'
end

action :install do
  ark ::File.basename(new_resource.path) do
    url new_resource.url
    path ::File.dirname(new_resource.path)
    checksum new_resource.checksum
    version new_resource.version
    owner new_resource.owner
    group new_resource.group
    mode new_resource.mode
    action :put
    strip_components 0
  end

  # Fix non-friendly 0750 permissions in order to make android-sdk available to all system users
  %w(add-ons platforms tools).each do |subfolder|
    directory ::File.join(new_resource.path, subfolder) do
      mode      0755
      user      new_resource.owner
      group     new_resource.group
      recursive true
    end
  end

  # TODO: find a way to handle 'chmod stuff' below with own chef resource (idempotence stuff...)
  execute 'Grant all users to read android files' do
    command "chmod -R a+r #{new_resource.path}/"
    user    new_resource.owner
    group   new_resource.group
  end

  execute 'Grant all users to execute android tools' do
    command "chmod -R a+X #{::File.join(new_resource.path, 'tools')}/*"
    user    new_resource.owner
    group   new_resource.group
  end

  # Set ANDROID_HOME to point to this SDK install
  environment_variable "ANDROID_HOME" do
    value   "#{new_resource.path}/"
    not_if  { platform?('windows') }
    only_if { node['android']['set_environment_variables'] }
  end

  # Prepend typical android SDK binary paths to PATH (note that the ANDROID_HOME value is separate)
  environment_variable "ANDROID_HOME_PATH" do
    key_name 'PATH'
    value    [ '${ANDROID_HOME}tools/bin', '${ANDROID_HOME}emulator', '${ANDROID_HOME}tools', '${ANDROID_HOME}platform-tools' ]
    prepend  false
    not_if   { platform?('windows') }
    only_if  { node['android']['set_environment_variables'] }
  end
end

action :update do
  script 'Install updates to all outdated components' do
    interpreter 'expect'
    # FIXME: Specifying the user/group here causes the temporary expect script file to not be executable/permissions issues on macOS!
    environment lazy {
      {
        'USER' => new_resource.owner,
        'HOME' => ::Dir.home(new_resource.owner),
        'ANDROID_HOME' => new_resource.path,
        'PATH' => "#{::File.join(new_resource.path, 'tools')}:#{ENV['PATH']}",
      }
    }
    code <<-EOF
      spawn #{new_resource.path}/tools/bin/sdkmanager --update
      set timeout #{new_resource.timeout}
      expect {
        "Accept? (y/N):" {
          exp_send "y\r"
          exp_continue
        }
        eof
      }
    EOF
  end
end
