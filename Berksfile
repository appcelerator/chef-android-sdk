source 'https://supermarket.chef.io'

metadata

group :test do
  cookbook 'apt'
  cookbook 'homebrew'

  cookbook 'test', path: './test/cookbooks/test'
end

group :first_party do
  # dependencies
  # FIXME: Why isn't this using the versions from our chef server?
  # For now that forces us to point to git!
  cookbook 'env', git: 'git@github.com:appcelerator/chef-env.git' # Need to use ssh URI since it's private and build machines will fail clone
  #cookbook 'env', path: "../chef-env"
end
