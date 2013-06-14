class CurrencyPlugin::Currency < Noosfero::Plugin::ActiveRecord

  belongs_to :environment

  has_many :currency_enterprises, :class_name => 'CurrencyPlugin::CurrencyEnterprise'
  has_many :acceptors, :through => :currency_enterprises, :source => :enterprise,
    :conditions => ['currency_plugin_currency_enterprises.is_organizer <> ?', true], :order => 'id ASC'
  has_many :organizers, :through => :currency_enterprises, :source => :enterprise,
    :conditions => ['currency_plugin_currency_enterprises.is_organizer = ?', true], :order => 'id ASC'

  validates_presence_of :environment
  validates_presence_of :symbol, :name, :description

  validates_uniqueness_of :symbol, :scope => :environment_id
  validates_uniqueness_of :name, :scope => :environment_id

  def name_with_symbol
    _('%{name} (%{symbol})') % {:name => self.name, :symbol => self.symbol}
  end
end
