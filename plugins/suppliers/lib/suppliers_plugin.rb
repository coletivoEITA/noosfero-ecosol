require_dependency "#{File.dirname __FILE__}/ext/profile"
require_dependency "#{File.dirname __FILE__}/ext/product"

if defined? OrdersPlugin
  require_dependency "#{File.dirname __FILE__}/ext/orders_plugin/product"
end

class SuppliersPlugin < Noosfero::Plugin

  def self.plugin_name
    "Suppliers"
  end

  def self.plugin_description
    t('suppliers_plugin.lib.plugin.description')
  end

  def stylesheet?
    true
  end

  def js_files
    ['toggle_edit', 'suppliers']
  end

end
