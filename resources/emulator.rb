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
property :heap, Integer, default: 128
property :ram, Integer, default: 1024
property :disk_size, String, default: '1280M'
property :launch, [true, false], default: false # Do we launch the emulator after creation?
# User values
property :user, String, required: true
property :group, [String, Integer], required: true
property :home, String, default: lazy { |r| ::Dir.home(r.user) }
property :gpu_mode, String, default: 'auto'
# density is typically around:
# ldpi  120dpi	0.75x	Resources for low-density (ldpi) screens.
# mdpi	~160dpi	1x	Resources for medium-density (mdpi) screens. (This is the baseline density.)
# hdpi	~240dpi	1.5x	Resources for high-density (hdpi) screens.
# xhdpi	~320dpi	2x	Resources for extra-high-density (xhdpi) screens.
# xxhdpi	~480dpi	3x	Resources for extra-extra-high-density (xxhdpi) screens.
# xxxhdpi	~640dpi 4x
property :density, Integer, default: 320
property :height, Integer, default: 1920
property :width, Integer, default: 1080

# Path to Android SDK to use to manage avd (avdmanager in tool)
property :sdk, String, default: lazy { ::File.join(node['ark']['prefix_home'], 'android-sdk') }

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

  # TODO: Support using a device profile name!
  # "Galaxy Nexus"
  # "Nexus 10"
  # "Nexus 4"
  # "Nexus 5"
  # "Nexus 5X"
  # "Nexus 6"
  # "Nexus 6P"
  # "Nexus 7 2013"
  # "Nexus 7"
  # "Nexus 9"
  # "Nexus One"
  # "Nexus S"
  # "pixel"
  # "pixel_c"
  # "pixel_xl"
  # "2.7in QVGA"
  # "2.7in QVGA slider"
  # "3.2in HVGA slider (ADP1)"
  # "3.2in QVGA (ADP2)"
  # "3.3in WQVGA"
  # "3.4in WQVGA"
  # "3.7 FWVGA slider"
  # "3.7in WVGA (Nexus One)"
  # "4in WVGA (Nexus S)"
  # "4.65in 720p (Galaxy Nexus)"
  # "4.7in WXGA"
  # "5.1in WVGA"
  # "5.4in FWVGA"
  # "7in WSVGA (Tablet)"
  # "10.1in WXGA (Tablet)"
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
        sdcard: new_resource.sdcard,
        ram: [new_resource.ram, node['memory']['total'].to_i / 4].min, # Cap at 25% of system RAM
        tag: new_resource.tag,
        heap: new_resource.heap,
        skin: new_resource.skin,
        disk_size: new_resource.disk_size,
        density: new_resource.density,
        height: new_resource.height,
        width: new_resource.width,
        platform: new_resource.platform,
        avd_dir: "#{new_resource.home}/.android/avd/#{new_resource.name}.avd",
        gpu_mode: new_resource.gpu_mode
      }
    }
    # If first time, or config has changed, launch the emulator once
    notifies :run, "execute[launch emulator #{new_resource.name}]", :immediate
  end

  # Force it to save snapshots on exit (and avoid prompting when emulator exits!)
  template "#{new_resource.home}/.android/avd/#{new_resource.name}.avd/quickBootChoice.ini" do
    cookbook 'android'
    owner new_resource.user
    group new_resource.group
    variables lazy {
      {
        saveOnExit: true,
      }
    }
  end

  # Launch emulator for first time
  execute "launch emulator #{new_resource.name}" do
    command "#{emulator_binary(new_resource.sdk)} -avd '#{new_resource.name}' -wipe-data -no-snapshot-load &"
    user new_resource.user
    group new_resource.group
    # Due to http://tickets.opscode.com/browse/CHEF-2288
    # Need to specify HOME explicitly for emulator launch to work
    environment lazy {
      {
        'HOME' => new_resource.home,
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
