#
# Cookbook Name:: android
# Resource:: ndk
#
resource_name :android_ndk

default_action :install

property :version, String, name_property: true
property :owner, String, required: true
property :group, [String, Integer], required: true

# TODO: Add checksums for other r13b, r15-beta1?
CHECKSUMS = {
  r10e: {
    'darwin-86_64'   => 'e205278fba12188c02037bfe3088eba34d8b5d96b1e71c8405f9e6e155a3bce4',
    'linux-x86_64'   => 'ee5f405f3b57c4f5c3b3b8b5d495ae12b660e03d2112e4ed5c728d349f1e520c',
    'windows-x86'    => 'e843d276796bda785c637be9529a01914e90c5479762a909e7f69624cac47b96',
    'windows-x86_64' => '4be4192971e1ced4cfb3da8e1242f80741d46c9cb4b44650af17b8053a3f8871',
  },
  r11c: {
    'darwin-86_64'   => 'fe2f8986074717240df45f03e93a4436dac2040dc12fecee4853953d584424b3',
    'linux-x86_64'   => 'ba85dbe4d370e4de567222f73a3e034d85fc3011b3cbd90697f3e8dcace3ad94',
    'windows-x86'    => 'eea7d148cf046baad2b8f3fd8e4a27d3695964079db0da6b9fca08051bb4dccb',
    'windows-x86_64' => '55c69f1d5a3602b3f6d6cea280b16938f17d6a4b509af01641d4db1280088d90',
  },
  r12b: {
    'darwin-x86_64'  => '2bdef9143a2c7680fcb7c9fd54fe85013d591f106aea43831eba5e13e10db77e',
    'linux-x86_64'   => 'eafae2d614e5475a3bcfd7c5f201db5b963cc1290ee3e8ae791ff0c66757781e',
    'windows-x86'    => '4b3b522775858bdf4e5e8f7365e06fdabb9913fb7b9f45d7010232f8271fb42c',
    'windows-x86_64' => 'a201b9dad71802464823dcfc77f61445ec1bbd8a29baa154d0a6ed84f50298ae',
  },
  r14b: {
    'darwin-x86_64'  => 'f5373dcb8ddc1ba8a4ccee864cba2cbdf500b2a32d6497378dfd32b375a8e6fa',
    'linux-x86_64'   => '0ecc2017802924cf81fffc0f51d342e3e69de6343da892ac9fa1cd79bc106024',
    'windows-x86'    => '5c9ae0268f638ef63783e12265ae8369d1c47badf5c3806990a7cd08ae3d7edf',
    'windows-x86_64' => '6c90f9462066ddc15035ac5f5fc51bcfac577dc31b31538a4e24f812c869b9c9',
  },
  r16b: {
    'darwin-x86_64'  => '9654a692ed97713e35154bfcacb0028fdc368128d636326f9644ed83eec5d88b',
    'linux-x86_64'   => 'bcdea4f5353773b2ffa85b5a9a2ae35544ce88ec5b507301d8cf6a76b765d901',
    'windows-x86'    => 'a67c1152eda390de715e1cdb53b1e5959bcebf233a02326dc0193795c6eda8d7',
    'windows-x86_64' => '4c6b39939b29dfd05e27c97caf588f26b611f89fe95aad1c987278bd1267b562',
  },
  r17: {
    'darwin-x86_64'  => '0ccd8fbbd987932f846c76a1a0c8402925461feb161ead353339c508ab3bf1f5',
    'linux-x86_64'   => 'ba3d813b47de75bc32a2f3de087f72599c6cb36fdc9686b96f517f5492ff43ca',
    'windows-x86'    => '8892584c86da97d3bd107389291a4e4fe2d601762621923084673dd0fb0afb73',
    'windows-x86_64' => '7e6d03087e2faa46231554887af4a6bc01b5ca37c6e0e7ca7161b86c51eed4b7',
  },
}.freeze

def initialize(*args)
  super

  @run_context.include_recipe 'ark'
end

action :install do
  ark "android-ndk-#{new_resource.version}" do
    version  new_resource.version
    url      "https://dl.google.com/android/repository/android-ndk-#{new_resource.version}-#{node['os']}-#{node['kernel']['machine']}.zip"
    checksum CHECKSUMS[new_resource.version.to_sym] && CHECKSUMS[new_resource.version.to_sym]["#{node['os']}-#{node['kernel']['machine']}"]
    action   :put # don't do symlinking
    owner    new_resource.owner
    group    new_resource.group
  end

  execute "Grant all users to execute android-ndk-#{new_resource.version} files" do
    command "chmod -R a+x #{node['ark']['prefix_root']}/android-ndk-#{new_resource.version}"
    not_if { platform?('windows') }
    not_if { ::File.exist?("/etc/profile.d/android-ndk-#{new_resource.version}.sh") }
  end

  # Make /etc/profile.d so the cookbooks that stick env vars in there won't fail
  directory '/etc/profile.d' do
    owner 'root'
    group 'wheel'
    only_if { platform?('mac_os_x') }
    only_if { node['android']['set_environment_variables'] }
  end

  # Set up ANDROID_NDK_XXX env var
  file "/etc/profile.d/android-ndk-#{new_resource.version}.sh" do
    content "export ANDROID_NDK_#{new_resource.version.upcase}=#{node['ark']['prefix_root']}/android-ndk-#{new_resource.version}"
    not_if { platform?('windows') }
    only_if { node['android']['set_environment_variables'] }
  end
end

action :uninstall do
  directory "#{node['ark']['prefix_root']}/android-ndk-#{new_resource.version}" do
    recursive true
    action    :delete
  end

  file "/etc/profile.d/android-ndk-#{new_resource.version}.sh" do
    action :delete
    not_if { platform?('windows') }
  end
end
