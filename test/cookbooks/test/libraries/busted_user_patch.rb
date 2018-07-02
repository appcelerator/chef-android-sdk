# Hack a monkeypatch to workaround a bug in creating a user on mac.
# I'm using Chef 12.19 where it fails in a different, but related
# way to https://github.com/chef/chef/pull/6225
# Basically, they're not careful enough passing around current_resource.home
# without checking for nil
class Chef
  class Provider
    class User
      class Dscl < Chef::Provider::User
        old_load_current_resource = instance_method(:load_current_resource)

        define_method(:load_current_resource) do
          result = old_load_current_resource.bind(self).call()
          result.home('') if result.home.nil?
          result
        end
      end
    end
  end
end
