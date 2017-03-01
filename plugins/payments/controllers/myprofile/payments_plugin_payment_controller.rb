class PaymentsPluginPaymentController < MyProfileController

  def create
    @payment = PaymentsPlugin::Payment.new params.require(:payment).permit(:orders_plugin_order_id, :payment_method_id, :value, :description)
    @payment.profile_id = profile.id
    @payment.operator_id = user.id
    @payment.save!
  end
end
