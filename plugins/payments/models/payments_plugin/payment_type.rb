class PaymentsPlugin::PaymentType < ApplicationRecord

  attr_accessible :slug, :name, :description

  has_many :payments

end
