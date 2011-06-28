Dir.glob(File.join(Rails.root, 'config', 'plugins', '*', 'controllers')) do |dir|
  plugin_name = File.basename(File.dirname(dir))
  Dir.glob(File.join(dir, '*')) do |controller| 
    controller_name = File.basename(controller).sub(/_controller\.rb$/, '')
    map.connect plugin_name + "/#{controller_name.sub(/^#{plugin_name}_/, '')}/:action/:id", :controller => controller_name
  end
  map.connect 'plugin/' + plugin_name + '/:action/:id', :controller => plugin_name + '_plugin_environment'
  map.connect 'profile/:profile/plugins/' + plugin_name + '/:action/:id', :controller => plugin_name + '_plugin_profile'
  map.connect 'myprofile/:profile/plugin/' + plugin_name + '/:action/:id', :controller => plugin_name + '_plugin_myprofile'
end

