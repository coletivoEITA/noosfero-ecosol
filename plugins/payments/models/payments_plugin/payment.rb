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
  validates_presence_of :value
  validates_presence_of :orders_plugin_order_id

  # FINANCIAL CALLBACKS
  if defined? FinancialPlugin
    has_one      :financial_transaction, class_name: "FinancialPlugin::Transaction", as: :source, dependent: :destroy
    after_create :create_transaction
    after_save   :update_transaction
  end


  protected

  def create_transaction
    self.create_financial_transaction(
      profile_id: self.profile_id,
      operator_id: self.operator_id,
      value: self.value,
      description: "new payment"
    )
  end

  def update_transaction
    self.create_transaction unless self.financial_transaction
    if self.financial_transaction.value != self.value
      self.financial_transaction.value = self.value
      self.financial_transaction.save
    end
  end

end
