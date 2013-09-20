require_dependency "#{File.dirname __FILE__}/ext/environment"
require_dependency "#{File.dirname __FILE__}/ext/profile"
require_dependency "#{File.dirname __FILE__}/ext/organization"

require_dependency "#{File.dirname __FILE__}/ext/sub_organizations_plugin/relation"

class NetworksPlugin < Noosfero::Plugin

  def self.plugin_name
    I18n.t('networks_plugin.lib.plugin.name')
  end

  def self.plugin_description
    I18n.t('networks_plugin.lib.plugin.description')
  end

  def js_files
    ['networks'].map{ |j| "javascripts/#{j}" }
  end

  def stylesheet?
    true
  end

end
