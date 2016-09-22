require_dependency 'profile'

class Profile

  has_and_belongs_to_many :payment_types, class_name: "PaymentsPlugin::PaymentType"

end
