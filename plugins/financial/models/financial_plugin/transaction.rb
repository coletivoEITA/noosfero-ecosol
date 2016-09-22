class FinancialPlugin::Transaction < ApplicationRecord
  attr_accessible :profile_id, :target_id, :operator_id, :description, :category, :value, :direction, :balance

  belongs_to :source,  polymorphic: true
  belongs_to :context, polymorphic: true
  belongs_to :target,  polymorphic: true
  belongs_to :profile
  belongs_to :target,   class_name: "Profile"
  belongs_to :operator, class_name: "Profile"

  scope :outputs, -> { where direction: :out }
  scope :inputs,  -> { where direction: :in }
end
