class FinancialPlugin < Noosfero::Plugin

  def self.plugin_name
    _("Financial")
  end

  def self.plugin_description
    _("Organize financial movement in the orders and orders_cycle plugins")
  end

  def stylesheet?
    true
  end

  def js_files
    ['financial'].map{ |j| "javascripts/#{j}" }
  end

end
