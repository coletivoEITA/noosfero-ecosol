require_dependency "#{File.dirname __FILE__}/ext/profile"

class OrdersPlugin < Noosfero::Plugin

  def self.plugin_name
    I18n.t('orders_plugin.lib.plugin.name')
  end

  def self.plugin_description
    I18n.t('orders_plugin.lib.plugin.description')
  end

  def stylesheet?
    true
  end

  def js_files
    ['loading-overlay', 'locale', 'toggle_edit', 'sortable-table', 'orders'].map{ |j| "javascripts/#{j}" }
  end

  def control_panel_buttons
    [
      { :title => I18n.t('orders_plugin.lib.plugin.panel_button'), :icon => 'orders-purchases-sales', :url => {:controller => :orders_plugin_admin, :action => :index} },
    ]
  end

end
