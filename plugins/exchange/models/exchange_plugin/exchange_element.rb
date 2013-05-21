class ExchangePlugin::ExchangeElement < Noosfero::Plugin::ActiveRecord
  belongs_to :element, :polymorphic => true
  belongs_to :proposal, :class_name => "ExchangePlugin::Proposal"

  # don't use directly
  belongs_to :element_np, :foreign_key => 'element_id'
  def element_np
    raise 'Dont use me'
  end

  def enterprise_id
    #not good!!! profile_id x enterprise_id
    if (self.element_type == "Product")
      return (eval(self.element_type).find self.element_id).enterprise_id
    else
      return (eval(self.element_type).find self.element_id).profile_id  
    end
  end
  
end
