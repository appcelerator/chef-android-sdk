describe directory('/home/random/.android') do
  it { should exist }
  it { should be_owned_by 'random' }
end

describe directory('/home/random/.android/avd') do
  it { should exist }
  it { should be_owned_by 'random' }
end

describe directory('/home/random/.android/avd/android-23-armeabi-v7a.avd') do
  it { should exist }
  it { should be_owned_by 'random' }
end

describe file('/home/random/.android/avd/android-23-armeabi-v7a.avd/config.ini') do
  it { should exist }
  it { should be_owned_by 'random' }
  its('mode') { should cmp '0644' }
end
