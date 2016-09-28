class PaymentsPlugin::PaymentMethod < ApplicationRecord

  attr_accessible :slug, :name, :description

  has_many :payments

  def self.all_in_a_list
    all.map{|p| [p.name, p.id]}
  end
end
