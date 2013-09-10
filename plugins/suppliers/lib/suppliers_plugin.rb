require_dependency "#{File.dirname __FILE__}/ext/profile"
require_dependency "#{File.dirname __FILE__}/ext/product"
require_dependency "#{File.dirname __FILE__}/ext/organization"

if defined? OrdersPlugin
  require_dependency "#{File.dirname __FILE__}/ext/orders_plugin/product"
end

class SuppliersPlugin < Noosfero::Plugin

  def self.plugin_name
    I18n.t('suppliers_plugin.lib.plugin.name')
  end

  def self.plugin_description
    I18n.t('suppliers_plugin.lib.plugin.description')
  end

  def stylesheet?
    true
  end

  def js_files
    ['loading-overlay', 'locale', 'toggle_edit', 'sortable-table', 'suppliers'].map{ |j| "javascripts/#{j}" }
  end

end
