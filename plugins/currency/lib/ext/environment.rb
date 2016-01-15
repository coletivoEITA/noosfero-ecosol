require_dependency 'environment'

class Environment

  has_many :currencies, class_name: 'CurrencyPlugin::Currency'

  def currencies_names
    [self.currency_unit] + currencies.map(&:name_with_symbol)
  end

  def currencies_with_environment_default
    self.default_currency # create default currency
    self.currencies_without_environment_default
  end
  alias_method_chain :currencies, :environment_default

  def default_currency
    currency = self.currencies_without_environment_default.find_by_symbol self.currency_unit
    if currency.nil?
      currency = self.currencies_without_environment_default.build symbol: self.currency_unit
      currency.save(false)
    end
    currency
  end

end
