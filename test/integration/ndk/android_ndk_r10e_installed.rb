describe directory('/usr/local/android-ndk-r10e') do
  it { should exist }
  it { should be_owned_by 'random' }
end

describe file('/etc/profile.d/ANDROID_NDK_R10E.sh') do
  it { should exist }
  its('mode') { should cmp '0755' }
  its('content') { should cmp 'export ANDROID_NDK_R10E=/usr/local/android-ndk-r10e\n' }
end
