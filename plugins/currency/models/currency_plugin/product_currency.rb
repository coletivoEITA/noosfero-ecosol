class CurrencyPlugin::ProductCurrency < Noosfero::Plugin::ActiveRecord

  belongs_to :product
  belongs_to :currency, :class_name => 'CurrencyPlugin::Currency'

end
