class FinancialPlugin < Noosfero::Plugin

  def stylesheet?
    true
  end

  def self.plugin_name
    _("Financial")
  end

  def self.plugin_description
    _("Organize financial movement in the orders and orders_cycle plugins")
  end

end
