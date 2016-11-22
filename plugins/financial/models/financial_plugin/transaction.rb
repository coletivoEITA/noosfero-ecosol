class FinancialPlugin::Transaction < ApplicationRecord
  attr_accessible :origin_id, :target, :target_profile, :target_profile, :order, :operator_id, :description, :date, :value, :direction, :balance, :cycle_id

  default_scope { order(date: :asc) }

  belongs_to :target,         polymorphic: true
  belongs_to :target_profile, class_name: "Profile"
  belongs_to :order,          class_name: "OrdersPlugin::Order"
  belongs_to :payment,        class_name: "PaymentsPlugin::Payment"
  belongs_to :payment_method, class_name: "PaymentsPlugin::PaymentMethod"
  belongs_to :operator,       class_name: "Profile"
  belongs_to :profile

  scope :outputs, -> { where direction: :out }
  scope :inputs,  -> { where direction: :in }
  scope :manual,  -> { where(order_id: nil).where(payment_id: nil) }
  scope :orders,  -> { outputs.where("order_id is not NULL").where(payment_id: nil) }
  scope :payments,  -> { inputs.where("order_id is not NULL").where("payment_id is not NULL").eager_load(:payment_method, :payment) }

  validates_presence_of :direction, :value, :date
end
