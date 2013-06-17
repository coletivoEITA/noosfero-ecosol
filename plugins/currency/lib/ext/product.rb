require_dependency 'product'

class Product

  has_many :product_currencies
  has_many :currencies, :through => :product_currencies

  def prices
    product_currencies.map{ |pc| [pc.price, pc.currency] }
  end

end
