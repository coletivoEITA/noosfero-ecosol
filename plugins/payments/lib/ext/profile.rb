require_dependency 'profile'

class Profile

  attr_accessible :payment_method_ids

  has_and_belongs_to_many :payment_methods, class_name: "PaymentsPlugin::PaymentMethod"

end
