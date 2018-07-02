class Chef
  module AndroidSDK
    # Find the ANDROID_HOME we're pointing to on this node
    def self.home(node)
      setup_root = node['android']['setup_root'].to_s.empty? ? node['ark']['prefix_home'] : node['android']['setup_root']
      File.join(setup_root, node['android']['name']) # returned
    end

    module Component
      # Determine if a specific component is installed
      def self.installed?(android_sdk_dir, component_name)
        # installed(android_sdk_dir).include?(component_name)
        Dir.exist?(path(android_sdk_dir, component_name))
      end

      # Returns the expected directory for a component by it's name
      def self.path(android_sdk_dir, component_name)
        "#{android_sdk_dir}/#{component_name.split(';').join('/')}"
      end

      # Gather up the listing of components we have installed!
      def self.installed(android_home)
        return [] unless Dir.exist?(android_home)
        installed = []
        installed << 'tools' if Dir.exist?("#{android_home}/tools")
        installed << 'platform-tools' if Dir.exist?("#{android_home}/platform-tools")
        installed << 'docs' if Dir.exist?("#{android_home}/docs")
        installed << 'emulator' if Dir.exist?("#{android_home}/emulator")

        Dir["#{android_home}/build-tools/*/"].each { |d| installed << "build-tools;#{File.basename(d)}" } if Dir.exist?("#{android_home}/build-tools")
        Dir["#{android_home}/platforms/*/"].each { |d| installed << "platforms;#{File.basename(d)}" } if Dir.exist?("#{android_home}/platforms")
        Dir["#{android_home}/add-ons/*/"].each { |d| installed << "addons;#{File.basename(d)}" } if Dir.exist?("#{android_home}/add-ons")

        if Dir.exist?("#{android_home}/extras")
          Dir["#{android_home}/extras/*/"].each do |d|
            # need to recurse again
            Dir["#{d}/*/"].each do |subdir|
              installed << "extras;#{File.basename(d)};#{File.basename(subdir)}"
            end
          end
        end

        if Dir.exist?("#{android_home}/system-images")
          Dir["#{android_home}/system-images/*/"].each do |api_level_dir|
            # get android-apilevel
            api_level = File.basename(api_level_dir)
            Dir["#{api_level_dir}/*/"].each do |tag_dir|
              # tag is name of the dir
              tag = File.basename(tag_dir)
              Dir["#{tag_dir}/*/"].each do |abi_dir|
                abi = File.basename(abi_dir)
                # i.e. system-images;android-23;default;armeabi-v7a
                # sys-img-x86_64-google_apis-23
                installed << "system-images;#{api_level};#{tag};#{abi}"
              end
            end
          end
        end
        installed # returned
      end
    end

    module DSL
      # @see Chef::AndroidSDK::Component#installed?
      def component_installed?(android_sdk_dir, component_name)
        Chef::AndroidSDK::Component.installed?(android_sdk_dir, component_name)
      end

      # @see Chef::AndroidSDK::Component#path
      def component_path(android_sdk_dir, component_name)
        Chef::AndroidSDK::Component.path(android_sdk_dir, component_name)
      end

      # @see Chef::AndroidSDK::Component#installed
      def installed_components(android_sdk_dir)
        Chef::AndroidSDK::Component.installed(android_sdk_dir)
      end

      # @see Chef::AndroidSDK#home
      def android_home
        Chef::AndroidSDK.home(node)
      end

      def emulator_binary(android_sdk_dir)
        ["#{android_sdk_dir}/emulator/emulator", "#{android_sdk_dir}/tools/emulator"].detect { |d| ::File.exist?(d) }
      end
    end
  end
end

Chef::Recipe.send(:include, Chef::AndroidSDK::DSL)
Chef::Resource.send(:include, Chef::AndroidSDK::DSL)
