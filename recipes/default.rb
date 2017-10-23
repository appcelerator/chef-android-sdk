#
# Cookbook Name:: android-sdk
# Recipe:: default
#
# Copyright 2011-2013, Travis CI Development Team <contact@travis-ci.org>
# Authors: Gilles Cornu
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

include_recipe 'java' unless node['android-sdk']['java_from_system']

android_bin = File.join(android_home, 'tools', 'bin', 'sdkmanager')

#
# Install required libraries
#
if node['platform'] == 'ubuntu'
  apt_update 'update'
  package 'libgl1-mesa-dev'
  package 'unzip'

  #
  # Install required 32-bit libraries on 64-bit platforms
  #
  if node['kernel']['machine'] != 'i686'
    # http://askubuntu.com/questions/147400/problems-with-eclipse-and-android-sdk
    if Chef::VersionConstraint.new('>= 13.04').include?(node['platform_version'])
      package 'lib32stdc++6'
    elsif Chef::VersionConstraint.new('>= 11.10').include?(node['platform_version'])
      package 'libstdc++6:i386'
    end

    package 'lib32z1'
  end
end

# FIXME: If upgrading from an old tools zip, we need to forcibly remove the old version!

#
# Download and setup android-sdk tarball package
#
ark node['android-sdk']['name'] do
  url node['android-sdk']['download_url']
  path node['android-sdk']['setup_root']
  checksum node['android-sdk']['checksum']
  version node['android-sdk']['version']
  prefix_root node['android-sdk']['setup_root']
  prefix_home node['android-sdk']['setup_root']
  owner node['android-sdk']['owner']
  group node['android-sdk']['group']
  action :put
  strip_components 0
end

#
# Fix non-friendly 0750 permissions in order to make android-sdk available to all system users
#
%w(add-ons platforms tools).each do |subfolder|
  directory File.join(android_home, subfolder) do
    mode 0755
    recursive true
  end
end

# TODO: find a way to handle 'chmod stuff' below with own chef resource (idempotence stuff...)
execute 'Grant all users to read android files' do
  command "chmod -R a+r #{android_home}/*"
  user node['android-sdk']['owner']
  group node['android-sdk']['group']
end
execute 'Grant all users to execute android tools' do
  command "chmod -R a+X #{File.join(android_home, 'tools')}/*"
  user node['android-sdk']['owner']
  group node['android-sdk']['group']
end

#
# Configure environment variables (ANDROID_HOME and PATH)
#
template "/etc/profile.d/#{node['android-sdk']['name']}.sh" do
  source 'android-sdk.sh.erb'
  mode 0644
  owner node['android-sdk']['owner']
  group node['android-sdk']['group']
  variables(
    android_home: android_home
  )
  only_if { node['android-sdk']['set_environment_variables'] }
end

# Mac OS X already has expect
package 'expect' do
  not_if { node['platform'] == 'mac_os_x' }
end

#
# Install, Update (a.k.a. re-install) Android components
#

# With "--filter node['android-sdk']['components'].join(,)" pattern,
# some system-images were not installed as expected.
# The easiest way I could find to fix this problem consists
# in executing a dedicated 'android sdk update' command for each component to be installed.
node['android-sdk']['components'].each do |sdk_component|
  script "Install Android SDK component #{sdk_component}" do
    interpreter 'expect'
    environment(
      'ANDROID_HOME' => android_home,
      'PATH' => "#{File.join(android_home, 'tools')}:#{ENV['PATH']}"
    )
    # TODO: use --force or not?
    code <<-EOF
      spawn #{android_bin} "#{sdk_component}"
      set timeout #{node['android-sdk']['install-timeout']}
      expect {
        "Accept? (y/N):" {
              exp_send "#{node['android-sdk']['license']['default_answer']}\r"
              exp_continue
        }
        eof
      }
    EOF
    not_if { component_installed?(sdk_component) }
    # TODO: Remove components that are installed that we didn't want! Loop through AndroidSDK.installed_components and remove any not in node['android-sdk']['components']
  end
end

#
# Deploy additional scripts, preferably outside Android-SDK own directories to
# avoid unwanted removal when updating android sdk components later.
#
%w(android-accept-licenses android-wait-for-emulator).each do |android_helper_script|
  cookbook_file File.join(node['android-sdk']['scripts']['path'], android_helper_script) do
    source android_helper_script
    owner node['android-sdk']['scripts']['owner']
    group node['android-sdk']['scripts']['group']
    mode 0755
  end
end
%w(android-update-sdk).each do |android_helper_script|
  template File.join(node['android-sdk']['scripts']['path'], android_helper_script) do
    source "#{android_helper_script}.erb"
    owner node['android-sdk']['scripts']['owner']
    group node['android-sdk']['scripts']['group']
    mode 0755
  end
end

#
# Install Maven Android SDK Deployer toolkit to populate local Maven repository
#
include_recipe('android-sdk::maven_rescue') if node['android-sdk']['maven_rescue']
