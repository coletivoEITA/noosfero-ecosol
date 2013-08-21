require_dependency "#{File.dirname __FILE__}/ext/profile"

class OrdersPlugin < Noosfero::Plugin

  def self.plugin_name
    "Orders"
  end

  def self.plugin_description
    _('Orders management')
  end

  def stylesheet?
    true
  end

  def js_files
    ['toggle_edit', 'orders']
  end

end
