#
# Cookbook Name:: android
# Resource:: component
#
resource_name :android_component

default_action :install

property :timeout, Integer, default: 1800
property :sdk, String, default: ::File.join(node['ark']['prefix_home'], 'android-sdk')
property :user, String, default: lazy { |r| Etc.getpwuid(::File.stat(r.sdk).uid).name }
property :group, [String, Integer], default: lazy { |r| ::File.stat(r.sdk).gid }

def initialize(*args)
  super

  @run_context.include_recipe 'java' unless node['android-sdk']['java_from_system']
end

action :install do
  # Mac OS X already has expect
  package 'expect' do
    not_if { node['platform'] == 'mac_os_x' }
  end

  android_bin = ::File.join(new_resource.sdk, 'tools', 'bin', 'sdkmanager')

  script "Install Android SDK component #{new_resource.name}" do
    interpreter 'expect'
    user new_resource.user
    group new_resource.group
    environment lazy {
      {
        'USER' => new_resource.user,
        'HOME' => ::Dir.home(new_resource.user),
        'ANDROID_HOME' => new_resource.sdk,
        'PATH' => "#{::File.join(new_resource.sdk, 'tools')}:#{ENV['PATH']}",
      }
    }
    # TODO: use --force or not?
    code <<-EOF
      spawn #{android_bin} "#{new_resource.name}"
      set timeout #{new_resource.timeout}
      expect {
        "Accept? (y/N):" {
          exp_send "y\r"
          exp_continue
        }
        eof
      }
    EOF
    notifies :run, "execute[Fix ownership of android SDK component #{new_resource.name}]", :immediate
    not_if { component_installed?(new_resource.sdk, new_resource.name) }
    # TODO: Remove components that are installed that we didn't want! Loop through AndroidSDK.installed_components and remove any not in node['android-sdk']['components']
  end

  # FIXME: Use helper/library method to fix just the specific folder? It wouldn't "fix" parent dirs that may have gotten created with bad ownership too...
  execute "Fix ownership of android SDK component #{new_resource.name}" do
    command lazy { "chown -R #{new_resource.user} #{new_resource.sdk}" }
    action :nothing
  end
end
