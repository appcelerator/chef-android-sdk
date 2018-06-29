android_home = '/usr/local/android-sdk'

# platforms;android-23
describe directory(File.join(android_home, 'platforms', 'android-23')) do
  it { should exist }
end

# On VM we must use ARM
# system-images;android-23;google_apis;armeabi-v7a
describe directory(File.join(android_home, 'system-images', 'android-23', 'google_apis', 'armeabi-v7a')) do
  it { should exist }
end
