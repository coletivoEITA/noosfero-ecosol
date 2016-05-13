require_dependency 'enterprise'

class Enterprise

  has_many :enterprise_currencies, -> { includes(:currency).order('id ASC') },
    class_name: 'CurrencyPlugin::EnterpriseCurrency'

  has_many :accepted_currencies, -> {
    where('currency_plugin_enterprise_currencies.is_organizer <> ?', true).order('id ASC')
  }, through: :enterprise_currencies, source: :currency

  has_many :organized_currencies, -> {
    where('currency_plugin_enterprise_currencies.is_organizer = ?', true).order('id ASC')
  }, through: :enterprise_currencies, source: :currency

  has_many :currencies, -> { order('id ASC') }, through: :enterprise_currencies, source: :currency

  def currencies_with_environment_default
    self.currencies_without_environment_default + [self.environment.default_currency]
  end
  alias_method_chain :currencies, :environment_default

  def other_currencies
    self.environment.currencies - self.currencies
  end

end
