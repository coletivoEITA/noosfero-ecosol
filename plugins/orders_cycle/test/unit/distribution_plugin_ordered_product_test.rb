require File.dirname(__FILE__) + '/../../../../test/test_helper'

class OrdersCyclePluginOrderedProductTest < ActiveSupport::TestCase

  def setup
    @product = build(OrdersPlugin::OrderedProduct,
     :quantity_payed => 1.0, :quantity_asked => 2.0, :quantity_allocated => 3.0,
     :price_payed => 10.0, :price_asked => 20.0, :price_allocated => 30.0)
  end

  should 'calculate prices' do
    @product.product.stubs(:price).returns(3)
    assert_equal 3.0, @product.price_payed
    assert_equal 6.0, @product.price_asked
    assert_equal 9.0, @product.price_allocated

    @product.save!
    assert_equal 3.0, @product.attributes['price_payed']
    assert_equal 6.0, @product.attributes['price_asked']
    assert_equal 9.0, @product.attributes['price_allocated']
  end

end
