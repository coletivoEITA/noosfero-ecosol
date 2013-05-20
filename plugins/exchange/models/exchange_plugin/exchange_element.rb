class ExchangePlugin::ExchangeElement < Noosfero::Plugin::ActiveRecord
  belongs_to :element, :polymorphic => true
  belongs_to :exchange

  # don't use directly
  belongs_to :element_np, :foreign_key => 'element_id'
  def element_np
    raise 'Dont use me'
  end

  def enterprise_id
    return (eval(self.element_type).find self.element_id).enterprise_id
  end
  
end
