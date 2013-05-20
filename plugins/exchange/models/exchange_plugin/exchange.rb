class ExchangePlugin::Exchange < Noosfero::Plugin::ActiveRecord

  validates_inclusion_of :state, :in => ["proposal", "negociation", "eavluation", 
    "finished",  "cancelled"]  

  has_many :exchange_elements, :dependent => :destroy, :order => "id asc"
  
  has_many :exchanges_enterprises, :class_name => "ExchangePlugin::ExchangeEnterprise"
  has_many :enterprises, :through => :exchanges_enterprises

  has_many :proposals, :class_name => "ExchangePlugin::Proposal"
  has_many :products, :through => :exchange_elements, :source => :element_np, :class_name => 'Product',
    :conditions => "exchange_plugin_exchange_elements.element_type = 'Product'"

  has_many :evaluations, :class_name => "EvaluationPlugin::Evaluation", :foreign_key => "object_id"

  belongs_to :enterprise_origin, :class_name => "Enterprise"
  belongs_to :enterprise_target, :class_name => "Enterprise"

  def self.state
    name = {"proposed" => _('Proposed'), "happening" => _('Happening'), "conclusion_proposed_by_origin" => _('Conclusion Proposed'), 
      "conclusion_proposed_by_target" => _('Conclusion Proposed'), "concluded" => _('Concluded'), 
      "evaluated_by_origin" => _('Evaluated by proposer'), "evaluated_by_target" => _('Evaluated by proposed'), 
      "evaluated" => _('Evaluated'), "cancelled" => _('Cancelled'),  "cancelled_by_origin" => _('Cancelled by Proposer'), "cancelled_by_target" => _('Cancelled by Proposed')}
  end

  def target_elements
    self.exchange_elements.all :conditions => {:enterprise_id => self.enterprise_target_id}, :include => :element
  end

  def origin_elements
    self.exchange_elements.all :conditions => {:enterprise_id => self.enterprise_origin_id}, :include => :element
  end

  def target?(profile)
    (profile.id == self.enterprise_target_id) 
  end



  def my_elements(profile)
    target?(profile) ? self.target_elements : self.origin_elements
  end

  def other_elements(profile)
    target?(profile) ? self.origin_elements : self.target_elements 
  end




end
