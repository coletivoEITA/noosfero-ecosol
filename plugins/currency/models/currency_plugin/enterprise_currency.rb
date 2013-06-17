class CurrencyPlugin::EnterpriseCurrency < Noosfero::Plugin::ActiveRecord

  belongs_to :currency, :class_name => 'CurrencyPlugin::Currency'
  belongs_to :enterprise

  validates_presence_of :currency
  validates_presence_of :enterprise

  def organizer?
    self.is_organizer
  end

end
