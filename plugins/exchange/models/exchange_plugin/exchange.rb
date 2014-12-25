class ExchangePlugin::Exchange < ActiveRecord::Base

  attr_accessible *self.column_names
  attr_accessible :origin, :target

  validates_inclusion_of :state, in: ["proposal", "negociation", "evaluation",
    "concluded",  "cancelled"]

  has_many :proposals, class_name: "ExchangePlugin::Proposal", dependent: :destroy

  has_many :profile_exchanges, class_name: "ExchangePlugin::ProfileExchange", dependent: :destroy
  has_many :profiles, through: :profile_exchanges

  has_many :closed_proposals, class_name: "ExchangePlugin::Proposal", conditions: "exchange_plugin_proposals.state = 'closed'"
  has_many :products, through: :elements, source: :object_np, class_name: 'Product',
    conditions: "exchange_plugin_elements.object_type = 'Product'"

  has_many :evaluations, class_name: "EvaluationPlugin::Evaluation", foreign_key: "object_id", dependent: :destroy

  belongs_to :origin, class_name: "Profile"
  belongs_to :target, class_name: "Profile"

  def target? profile
    profile.id == self.target_id
  end

end
