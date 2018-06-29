# platform-tools
describe directory('/usr/local/android-sdk/platform-tools') do
  it { should exist }
end

# build-tools;26.0.1
describe directory('/usr/local/android-sdk/build-tools/26.0.1') do
  it { should exist }
end

# platforms;android-23
describe directory('/usr/local/android-sdk/platforms/android-23') do
  it { should exist }
end

# On VM we must use ARM
# system-images;android-23;google_apis;armeabi-v7a
describe directory('/usr/local/android-sdk/system-images/android-23/google_apis/armeabi-v7a') do
  it { should exist }
end
