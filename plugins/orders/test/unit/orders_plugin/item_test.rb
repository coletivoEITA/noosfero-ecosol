require File.dirname(__FILE__) + '/../../../../test/test_helper'

class OrdersPlugin::ItemTest < ActiveSupport::TestCase

  def setup
    @item = build(OrdersPlugin::Item,
     :quantity_shipped => 1.0, :quantity_asked => 2.0, :quantity_accepted => 3.0,
     :price_shipped => 10.0, :price_asked => 20.0, :price_accepted => 30.0)
  end

  should 'calculate prices' do
    @item.product.stubs(:price).returns(3)
    assert_equal 3.0, @item.price_shipped
    assert_equal 6.0, @item.price_asked
    assert_equal 9.0, @item.price_accepted

    @item.save!
    assert_equal 3.0, @item.attributes['price_shipped']
    assert_equal 6.0, @item.attributes['price_asked']
    assert_equal 9.0, @item.attributes['price_accepted']
  end

end
