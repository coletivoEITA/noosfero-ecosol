class ExchangePlugin::Element < Noosfero::Plugin::ActiveRecord

  belongs_to :proposal, :class_name => "ExchangePlugin::Proposal"
  has_one :exchange, :through => :proposal

  belongs_to :object, :polymorphic => true

  validates_presence_of :proposal
  validates_presence_of :object

  # don't use directly
  belongs_to :element_np, :foreign_key => :object_id
  def element_np
    raise 'Dont use me'
  end

end
