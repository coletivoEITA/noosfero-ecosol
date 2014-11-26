
class OpenGraphPlugin < Noosfero::Plugin

  def self.plugin_name
    I18n.t 'open_graph_plugin.lib.plugin.name'
  end

  def self.plugin_description
    I18n.t 'open_graph_plugin.lib.plugin.description'
  end

end

ActiveSupport.run_load_hooks :open_graph_plugin, OpenGraphPlugin
