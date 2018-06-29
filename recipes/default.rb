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

android_sdk 'android-sdk' do
  checksum node['android-sdk']['checksum']
  version node['android-sdk']['version']
  owner node['android-sdk']['owner']
  group node['android-sdk']['group']
  url node['android-sdk']['download_url']
  path node['android-sdk']['setup_root']
end

#
# Install, Update (a.k.a. re-install) Android components
#
node['android-sdk']['components'].each do |sdk_component|
  android_component sdk_component do
    sdk ::File.join(node['android-sdk']['setup_root'] || node['ark']['prefix_home'], 'android-sdk')
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
include_recipe('android::maven_rescue') if node['android-sdk']['maven_rescue']
