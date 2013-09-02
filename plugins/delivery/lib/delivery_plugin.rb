require_dependency "#{File.dirname __FILE__}/ext/profile"

class DeliveryPlugin < Noosfero::Plugin

  def self.plugin_name
    "Delivery"
  end

  def self.plugin_description
    t('delivery_plugin.lib.plugin.description')
  end

  def stylesheet?
    true
  end

  def js_files
    ['delivery']
  end

end

# workaround for plugin class scope problem
require_dependency 'delivery_plugin/method'

