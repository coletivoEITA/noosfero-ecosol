class ExchangePlugin::ExchangeEnterprise < Noosfero::Plugin::ActiveRecord

  belongs_to :exchange, :class_name => "ExchangePlugin::Exchange"
  belongs_to :enterprise, :class_name => "Enterprise"

end
