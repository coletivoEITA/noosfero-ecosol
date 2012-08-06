Dir.glob(File.join(Rails.root, 'config', 'plugins', '*', 'controllers')) do |dir|
  plugin_name = File.basename(File.dirname(dir))

  Dir.glob(File.join(dir, '*')) do |controller|
    controller_name = File.basename(controller).sub(/_controller\.rb$/, '')
    controller_name_unprefixed = "#{controller_name.sub(/^#{plugin_name}_plugin_/, '')}"

    map.connect "plugin/:plugin_name/#{controller_name_unprefixed}/:action/:id", :controller => controller_name
    map.connect "plugin/#{plugin_name}/#{controller_name_unprefixed}/:action/:id", :controller => controller_name
  end

  map.connect "plugin/:plugin_name/:action/:id", :controller => plugin_name + '_plugin'
  map.connect "plugin/#{plugin_name}/:action/:id", :controller => plugin_name + '_plugin'
  map.connect "profile/:profile/plugins/:plugin_name/:action/:id", :controller => plugin_name + '_plugin_profile'
  map.connect "profile/:profile/plugins/#{plugin_name}/:action/:id", :controller => plugin_name + '_plugin_profile'
  map.connect "myprofile/:profile/plugin/:plugin_name/:action/:id", :controller => plugin_name + '_plugin_myprofile'
  map.connect "myprofile/:profile/plugin/#{plugin_name}/:action/:id", :controller => plugin_name + '_plugin_myprofile'
  map.connect "admin/plugin/:plugin_name/:action/:id", :controller => plugin_name + '_plugin_admin'
  map.connect "admin/plugin/#{plugin_name}/:action/:id", :controller => plugin_name + '_plugin_admin'

end

