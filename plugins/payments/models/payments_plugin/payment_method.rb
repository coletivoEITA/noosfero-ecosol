class PaymentsPlugin::PaymentMethod < ApplicationRecord

  attr_accessible :slug, :name, :description

  has_many :payments
  has_and_belongs_to_many :profiles

  def self.as_hash_n_translation
    all.each_with_object({}){|pm,h| h[pm.slug.to_sym] = proc{ _(pm.name) } }
  end
end
