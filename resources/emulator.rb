#
# Cookbook Name:: android
# Resource:: emulator
#
resource_name :android_emulator

default_action :install

# This definition of name property is unnecessary and happens by default.
# See http://www.foodcritic.io/#FC108
# property :name, String, name_attribute: true

# Emulator values
property :platform, String, required: true
property :skin, String, required: true
property :tag, String, default: 'google_apis'
property :abi, String, required: true
property :sdcard, String, default: '512M'
property :launch, [true, false], default: false # Do we launch the emulator after creation?
# User values
property :user, String, required: true
property :group, [String, Integer], required: true
property :home, String, default: lazy { |r| ::Dir.home(r.user) }

# Path to Android SDK to use to manage avd (avdmanager in tool)
property :sdk, String, default: ::File.join(node['ark']['prefix_home'], 'android-sdk')

action :install do
  # Create working directory for AVD
  directory "#{new_resource.home}/.android" do
    owner new_resource.user
    group new_resource.group
  end

  directory "#{new_resource.home}/.android/avd" do
    owner new_resource.user
    group new_resource.group
  end

  execute "create avd #{new_resource.name}" do
    command "echo | #{new_resource.sdk}/tools/bin/avdmanager create avd -n '#{new_resource.name}' -k 'system-images;#{new_resource.platform};#{new_resource.tag};#{new_resource.abi}' -c #{new_resource.sdcard} -f -p '#{new_resource.home}/.android/avd/#{new_resource.name}.avd' -g #{new_resource.tag}"
    user new_resource.user
    not_if { ::File.exist?("#{new_resource.home}/.android/avd/#{new_resource.name}.avd") }
  end

  # If we generate a new emulator, use our own custom config.ini
  # most important change is upping the heap size from 48M, or test app crashes
  template "#{new_resource.home}/.android/avd/#{new_resource.name}.avd/config.ini" do
    cookbook 'android'
    variables lazy {
      {
        abi: new_resource.abi,
        skin: new_resource.skin,
        platform: new_resource.platform,
        avd_dir: "#{new_resource.home}/.android/avd/#{new_resource.name}.avd",
      }
    }
    # If first time, or config has changed, launch the emulator once
    notifies :run, "execute[launch emulator #{new_resource.name}]", :immediate
  end

  # Launch emulator for first time
  execute "launch emulator #{new_resource.name}" do
    command "#{emulator_binary(new_resource.sdk)} -avd '#{new_resource.name}' &"
    user new_resource.user
    group new_resource.group
    # Due to http://tickets.opscode.com/browse/CHEF-2288
    # Need to specify HOME explicitly for emulator launch to work
    environment lazy {
      {
        'HOME' => home,
        'USER' => new_resource.user,
      }
    }
    action :nothing
    only_if { new_resource.launch }
    # notifies :run, 'execute[wait for emulator]', :immediate
  end

  # Wait until emulator booted before continuing
  # FIXME: This appears to hang!
  # execute 'wait for emulator' do
  #   command "#{node['android']['scripts']['path']}/android-wait-for-emulator"
  #   action :nothing
  # end
end

action :uninstall do
  execute "delete avd #{new_resource.name}" do
    command "echo | #{new_resource.sdk}/tools/bin/avdmanager delete avd -n '#{new_resource.name}'"
    user new_resource.user
    only_if { ::File.exist?("#{new_resource.home}/.android/avd/#{new_resource.name}.avd") }
  end
end
