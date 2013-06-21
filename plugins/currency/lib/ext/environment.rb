require_dependency 'environment'

class Environment

  has_many :currencies, :class_name => 'CurrencyPlugin::Currency'

  def currencies_names
    [self.currency_unit] + currencies.map(&:name_with_symbol)
  end

end
