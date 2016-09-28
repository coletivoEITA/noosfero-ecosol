class PaymentsPlugin::Payment < ApplicationRecord
  attr_accessible :orders_plugin_order_id, :profile_id, :payment_method_id, :operator_id, :value, :description

  # ASSOCIATIONS
  belongs_to :order
  belongs_to :profile
  belongs_to :operator, class_name: "Profile"
  belongs_to :payment_method


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
      quantity: self.value,
      description: "new payment"
    )
  end

  def update_transaction
   if self.transaction.value != self.value
      self.transaction.value = self.value
      self.transaction.save
   end
  end

end
