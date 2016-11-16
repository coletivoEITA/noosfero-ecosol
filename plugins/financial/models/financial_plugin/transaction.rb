class FinancialPlugin::Transaction < ApplicationRecord
  attr_accessible :origin_id, :target, :target_profile, :target_profile, :order, :operator_id, :description, :date, :value, :direction, :balance

  belongs_to :target,         polymorphic: true
  belongs_to :target_profile, class_name: "Profile"
  belongs_to :order,          class_name: "OrdersPlugin::Order"
  belongs_to :payment,        class_name: "PaymentsPlugin::Payment"
  belongs_to :operator,       class_name: "Profile"
  belongs_to :profile

  scope :outputs, -> { where direction: :out }
  scope :inputs,  -> { where direction: :in }

  validates_presence_of :direction, :value, :date
end
