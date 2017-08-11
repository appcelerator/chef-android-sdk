describe directory('/usr/local/android-sdk') do
  it { should exist }
end

describe directory('/usr/local/android-sdk/tools') do
  it { should exist }
  its('mode') { should cmp '0755' }
end

describe directory('/usr/local/android-sdk/tools/bin') do
  it { should exist }
  its('mode') { should cmp '0755' }
end

# build-tools;22.0.1
describe directory('/usr/local/android-sdk/build-tools/22.0.1') do
  it { should exist }
end

# platforms;android-22
describe directory('/usr/local/android-sdk/platforms/android-22') do
  it { should exist }
end

# system-images;android-22;default;armeabi-v7a
describe directory('/usr/local/android-sdk/system-images/android-22/default/armeabi-v7a') do
  it { should exist }
end

describe file('/etc/profile.d/android-sdk.sh') do
  it { should exist }
  its('mode') { should cmp '0644' }
end
