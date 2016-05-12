require 'test_helper'

class OrdersCyclePlugin::CycleTest < ActiveSupport::TestCase

  def setup
    @profile = create Enterprise, name: "trocas verdes", identifier: "trocas-verdes"
    @pc = create ProductCategory, name: 'frutas', environment_id: 1
    @profile.products = [
      Product.new(name: 'banana', product_category: @pc),
      Product.new(name: 'mandioca', product_category: @pc),
      Product.new(name: 'alface', product_category: @pc)
    ]

    @cycle = OrdersCyclePlugin::Cycle.create!(
      profile: @profile,
      name:    'cycle',
      start:   Time.now,
      status:  'edition',
    )
    @profile.offered_products = @profile.products.map do |p|
      OrdersCyclePlugin::OfferedProduct.create_from p, @cycle
    end
    DeliveryPlugin::Method.create! name: 'at home', delivery_type: 'pickup', profile: @profile
  end

  should 'add products from profile after create' do
    omit
    assert_equal @cycle.products.collect(&:product_id), @profile.products.collect(&:id)
  end

  should 'have at least one delivery method unless in edition status' do
    omit
    cycle = OrdersCyclePlugin::Cycle.create! profile: @profile, name: "Testes batidos", start: DateTime.now, status: 'edition'
    assert cycle
    cycle.status = 'orders'
    assert_nil cycle.save!
  end

end
