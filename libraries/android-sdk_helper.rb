class Chef
  module AndroidSDK
    # Find the ANDROID_HOME we're pointing to on this node
    def self.home(node)
      setup_root       = node['android-sdk']['setup_root'].to_s.empty? ? node['ark']['prefix_home'] : node['android-sdk']['setup_root']
      android_home     = File.join(setup_root, node['android-sdk']['name'])
      return android_home
    end

    module Component
      # Determine if a specific component is installed
      def self.installed?(node, component_name)
        self.installed(node).include?(component_name)
      end

      # Gather up the listing of components we have installed!
      def self.installed(node)
        android_home = ::Chef::AndroidSDK.home(node)
        return [] if !Dir.exist?(android_home)
        installed = []
        if Dir.exist?("#{android_home}/tools")
          installed << 'tools'
        end
        if Dir.exist?("#{android_home}/platform-tools")
          installed << 'platform-tools'
        end
        # Look for specific version of docs
        if File.exist?("#{android_home}/docs/source.properties")
          contents = IO.read("#{android_home}/docs/source.properties")
          match = contents.match(/AndroidVersion\.ApiLevel=(\d+)/)
          installed << "doc-#{match[1]}" if match
        end
        if Dir.exist?("#{android_home}/build-tools")
          Dir["#{android_home}/build-tools/*/"].each {|d| installed << "build-tools-#{File.basename(d)}" }
        end
        if Dir.exist?("#{android_home}/platforms")
          Dir["#{android_home}/platforms/*/"].each {|d| installed << File.basename(d) }
        end
        if Dir.exist?("#{android_home}/extras")
          Dir["#{android_home}/extras/*/"].each do |d|
            # need to recurse again
            Dir["#{d}/*/"].each do |subdir|
              installed << "extra-#{File.basename(d)}-#{File.basename(subdir)}"
            end
          end
        end
        if Dir.exist?("#{android_home}/add-ons")
          Dir["#{android_home}/add-ons/*/"].each {|d| installed << File.basename(d) }
        end
        if Dir.exist?("#{android_home}/system-images")
          Dir["#{android_home}/system-images/*/"].each do |apiLevelDir|
            # strip leading 'android-' to get numeric apiLevel
            apiLevel = File.basename(apiLevelDir).sub('android-', '')
            Dir["#{apiLevelDir}/*/"].each do |tagDir|
              # tag is name of the dir, but 'default' should become 'android'
              tag = File.basename(tagDir).sub('default', 'android')
              Dir["#{tagDir}/*/"].each do |abiDir|
                abi = File.basename(abiDir)
                # i.e. sys-img-x86-android-23
                # sys-img-x86_64-google_apis-23
                installed << "sys-img-#{abi}-#{tag}-#{apiLevel}"
              end
            end
          end
        end
        return installed
      end
    end

    module DSL
      # @see Chef::AndroidSDK::Component#installed?
      def component_installed?(component_name); Chef::AndroidSDK::Component.installed?(node, component_name); end

      # @see Chef::AndroidSDK::Component#installed
      def installed_components; Chef::AndroidSDK::Component.installed(node); end

      # @see Chef::AndroidSDK#home
      def android_home; Chef::AndroidSDK.home(node); end
    end
  end
end


Chef::Recipe.send(:include, Chef::AndroidSDK::DSL)
Chef::Resource.send(:include, Chef::AndroidSDK::DSL)
