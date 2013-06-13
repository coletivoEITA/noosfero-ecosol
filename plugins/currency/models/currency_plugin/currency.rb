class CurrencyPlugin::Currency < Noosfero::Plugin::ActiveRecord

  belongs_to :environment

  has_many :acceptances, :class_name => 'CurrencyPlugin::CurrencyEnterprise'
  has_many :acceptors, :through => :acceptances, :source => :enterprise,
    :conditions => ['currency_plugin_currency_enterprises.is_organizer <> ?', true]
  has_many :organizers, :through => :acceptances, :source => :enterprise,
    :conditions => ['currency_plugin_currency_enterprises.is_organizer = ?', true]

  validates_presence_of :environment
  validates_presence_of :symbol, :name, :description

end
