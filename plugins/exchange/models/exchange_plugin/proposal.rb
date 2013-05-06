class ExchangePlugin::Proposal < Noosfero::Plugin::ActiveRecord

  validates_presence_of :enterprise_origin, :enterprise_target

  has_many :exchange_elements, :class_name => "ExchangePlugin::ExchangeElement" #, :dependent => :destroy, :order => "id asc"
#  has_many :enterprises
  has_many :products, :through => :exchange_elements, :source => :element_np, :class_name => 'Product',
    :conditions => "exchange_plugin_exchange_elements.element_type = 'Product'"
  has_many :messages, :dependent => :destroy, :order => "created_at desc"


  belongs_to :enterprise_origin, :class_name => "Enterprise"
  belongs_to :enterprise_target, :class_name => "Enterprise"
  belongs_to :exchange, :class_name => "ExchangePlugin::Exchange"
  
  
  def target_elements
    self.exchange_elements.all :conditions => {:enterprise_id => self.enterprise_target_id}, :include => :element
  end

  def origin_elements
    self.exchange_elements.all :conditions => {:enterprise_id => self.enterprise_origin_id}, :include => :element
  end

  def target?(profile)
    (profile.id == self.enterprise_target_id) 
  end

  def the_other(profile)
    target?(profile) ? self.enterprise_origin : self.enterprise_target
  end

  def my_elements(profile)
    target?(profile) ? self.target_elements : self.origin_elements
  end

  def other_elements(profile)
    target?(profile) ? self.origin_elements : self.target_elements 
  end




end
