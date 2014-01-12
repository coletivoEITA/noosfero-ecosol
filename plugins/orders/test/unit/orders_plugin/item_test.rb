require File.dirname(__FILE__) + '/../../../../test/test_helper'

class OrdersPlugin::ItemTest < ActiveSupport::TestCase

  def setup
    @item = build(OrdersPlugin::Item,
     :quantity_payed => 1.0, :quantity_asked => 2.0, :quantity_allocated => 3.0,
     :price_payed => 10.0, :price_asked => 20.0, :price_allocated => 30.0)
  end

  should 'calculate prices' do
    @item.product.stubs(:price).returns(3)
    assert_equal 3.0, @item.price_payed
    assert_equal 6.0, @item.price_asked
    assert_equal 9.0, @item.price_allocated

    @item.save!
    assert_equal 3.0, @item.attributes['price_payed']
    assert_equal 6.0, @item.attributes['price_asked']
    assert_equal 9.0, @item.attributes['price_allocated']
  end

end
