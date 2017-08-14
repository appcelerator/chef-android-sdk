name 'android-sdk'
maintainer 'Gilles Cornu'
maintainer_email 'foss@gilles.cornu.name'
license 'Apache-2.0'
description 'Installs Google Android SDK'
version '1.0.2'
issues_url 'https://github.com/cappcelerator/chef-android-sdk/issues' if respond_to?(:issues_url)
source_url 'https://github.com/appcelerator/chef-android-sdk/' if respond_to?(:source_url)
chef_version '>= 12.5' if respond_to?(:chef_version)

%w(java ark).each do |dep|
  depends dep
end

# TODO: maybe put maven into depends section
# recommends 'maven' # Maven 3.1.1+ is required by android-sdk::maven-rescue recipe

supports 'ubuntu', '>= 12.04'
supports 'centos', '>= 6.6'
supports 'mac_os_x'
# Support for more platforms is on the road (e.g. Debian, CentOS,...).
# Please watch or help on https://github.com/gildegoma/chef-android-sdk/issues/5

recipe 'android-sdk::default', 'Install and update Google Android SDK'
recipe 'android-sdk::maven_rescue', 'Install missing dependencies with Maven Android SDK Deployer'
