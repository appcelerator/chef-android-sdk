describe directory('/usr/local/android-sdk') do
  it { should exist }
end

describe directory('/usr/local/android-sdk/add-ons') do
  it { should exist }
  its('mode') { should cmp '0755' }
end

describe directory('/usr/local/android-sdk/platforms') do
  it { should exist }
  its('mode') { should cmp '0755' }
end

describe directory('/usr/local/android-sdk/tools') do
  it { should exist }
  its('mode') { should cmp '0755' }
end

describe directory('/usr/local/android-sdk/tools/bin') do
  it { should exist }
  its('mode') { should cmp '0755' }
end

describe file('/usr/local/android-sdk/tools/bin/avdmanager') do
  it { should exist }
  it { should be_executable }
  its('mode') { should cmp '0755' }
end

describe file('/usr/local/android-sdk/tools/bin/sdkmanager') do
  it { should exist }
  it { should be_executable }
  its('mode') { should cmp '0755' }
end

describe file('/etc/profile.d/ANDROID_HOME.sh') do
  it { should exist }
  its('mode') { should cmp '0755' }
  its('content') { should cmp "export ANDROID_HOME=/usr/local/android-sdk\n" }
end
# appends to PATH
describe file('/etc/profile.d/ANDROID_HOME_PATH.sh') do
  it { should exist }
  its('mode') { should cmp '0755' }
  its('content') { should cmp "export PATH=$PATH:${ANDROID_HOME}tools/bin:${ANDROID_HOME}tools:${ANDROID_HOME}platform-tools\n" }
end
