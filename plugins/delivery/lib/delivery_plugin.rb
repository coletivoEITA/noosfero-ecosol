class DeliveryPlugin < Noosfero::Plugin

  def self.plugin_name
    I18n.t('delivery_plugin.lib.plugin.name')
  end

  def self.plugin_description
    I18n.t('delivery_plugin.lib.plugin.description')
  end

  def stylesheet?
    true
  end

  def js_files
    ['delivery'].map{ |j| "javascripts/#{j}" }
  end

end

# workaround for plugin class scope problem
require 'delivery_plugin/method'

