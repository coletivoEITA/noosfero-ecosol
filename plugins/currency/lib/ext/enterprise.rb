require_dependency 'enterprise'

class Enterprise
  has_many :currency_acceptances, :class_name => 'CurrencyPlugin::CurrencyEnterprise'
  has_many :accepted_currencies, :through => :currency_acceptances, :source => :currency,
    :conditions => ['currency_plugin_currency_enterprises.is_organizer <> ?', true]
  has_many :organized_currencies, :through => :currency_acceptances, :source => :currency,
    :conditions => ['currency_plugin_currency_enterprises.is_organizer = ?', true]
end
