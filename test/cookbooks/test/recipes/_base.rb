if platform_family?('mac_os_x')
	include_recipe 'homebrew'
	homebrew_cask 'homebrew/cask-versions/adoptopenjdk8'
  else 
	apt_update 'update'
  end