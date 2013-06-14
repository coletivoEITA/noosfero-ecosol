require_dependency 'enterprise'

class Enterprise

  has_many :currency_enterprises, :class_name => 'CurrencyPlugin::CurrencyEnterprise'
  has_many :accepted_currencies, :through => :currency_enterprises, :source => :currency,
    :conditions => ['currency_plugin_currency_enterprises.is_organizer <> ?', true], :order => 'id ASC'
  has_many :organized_currencies, :through => :currency_enterprises, :source => :currency,
    :conditions => ['currency_plugin_currency_enterprises.is_organizer = ?', true], :order => 'id ASC'
  has_many :currencies, :through => :currency_enterprises, :source => :currency, :order => 'id ASC'

end
