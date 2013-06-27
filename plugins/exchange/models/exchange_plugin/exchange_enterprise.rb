class ExchangePlugin::ExchangeEnterprise < Noosfero::Plugin::ActiveRecord

  belongs_to :exchange, :class_name => "ExchangePlugin::Exchange"
  belongs_to :enterprise, :class_name => "Enterprise"

  def the_other
    the_other = ExchangePlugin::ExchangeEnterprise.find(:first, :conditions => ["exchange_id = ? AND enterprise_id != ?", self.exchange_id, self.enterprise_id]).enterprise
  end
end
