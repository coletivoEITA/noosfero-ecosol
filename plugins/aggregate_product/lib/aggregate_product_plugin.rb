module AggregateProductPlugin

  extend Noosfero::Plugin::ParentMethods

  def self.plugin_name
    I18n.t'aggregate_product_plugin.lib.plugin.name'
  end

  def self.plugin_description
    I18n.t'aggregate_product_plugin.lib.plugin.description'
  end

end
