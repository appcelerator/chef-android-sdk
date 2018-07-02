describe directory('/usr/local/android-ndk-r10e') do
  it { should exist }
  it { should be_owned_by 'random' }
end

# TODO: Can we source/execute this file and make sure it sets ANDROID_NDK_R10E?
describe file('/etc/profile.d/android-ndk-r10e.sh') do
  it { should exist }
  its('mode') { should cmp '0644' }
end
