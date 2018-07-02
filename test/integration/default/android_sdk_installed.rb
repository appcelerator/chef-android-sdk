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

describe file('/etc/profile.d/android-sdk.sh') do
  it { should exist }
  its('mode') { should cmp '0644' }
end
