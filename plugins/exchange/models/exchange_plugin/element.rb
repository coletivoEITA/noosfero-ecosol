class ExchangePlugin::Element < Noosfero::Plugin::ActiveRecord

  belongs_to :proposal, :class_name => "ExchangePlugin::Proposal"
  belongs_to :object, :polymorphic => true

  # don't use directly
  belongs_to :element_np, :foreign_key => :object_id
  def element_np
    raise 'Dont use me'
  end

end
