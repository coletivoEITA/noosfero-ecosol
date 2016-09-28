require_dependency 'profile'

class Profile

  has_and_belongs_to_many :payment_methods, class_name: "PaymentsPlugin::PaymentMethod"

end
