class PaymentsPlugin::Payment < ApplicationRecord
  attr_accessible :orders_plugin_order_id, :profile_id, :payment_method_id, :operator_id, :value, :description

  # ASSOCIATIONS
  belongs_to :order, class_name: OrdersPlugin::Order, foreign_key: :orders_plugin_order_id
  belongs_to :profile
  belongs_to :operator, class_name: "Profile"
  belongs_to :payment_method, class_name: PaymentsPlugin::PaymentMethod

  validates_presence_of :profile_id
  validates_presence_of :payment_method_id
  validates_presence_of :operator_id
  validates :value, numericality: {greater_than: 0}

  # FINANCIAL CALLBACK AND ASSOCIATION
  has_one      :financial_transaction, class_name: "FinancialPlugin::Transaction", dependent: :destroy, foreign_key: :payment_id
  after_create :create_transaction


  protected

  def create_transaction
    # when Order is from OrdersPlugin, it doesn't have the cycle method defined, do it by hand so
    if defined? self.order.cycle
      cycle = self.order.cycle
    else
      cycle_order = OrdersCyclePlugin::CycleOrder.where(sale_id: self.order.id).includes(cycle: :profile).first
      cycle = cycle_order.cycle
    end
    target_profile = cycle.present? ? cycle.profile : nil
    self.create_financial_transaction!(
      origin_id: self.profile_id,
      target: cycle,
      target_profile: target_profile,
      operator_id: self.operator_id,
      order: self.order,
      value: self.value,
      description: "Payment of value " + self.value.to_s,
      date: DateTime.now,
      direction: :in,
      payment_method_id: self.payment_method_id
    )
  end

end
