require File.dirname(__FILE__) + '/../../../../test/test_helper'

class OrdersCyclePlugin::OrderTest < ActiveSupport::TestCase

  def setup
    @order = build(OrdersPlugin::Order)
  end

  should 'format code with cycle code' do
    @order.save!
    assert_equal "#{@order.cycle.code}.#{@order.attributes['code']}", @order.code
  end

  should 'use as draft default status' do
    @order = create(OrdersPlugin::Order, :status => nil)
    assert_equal 'draft', @order.status
  end

  ###
  # Status
  ###

  should 'define and validate list of statuses' do
    @order.status = 'blah'
    @order.valid?
    assert @order.errors.invalid?('status')

    ['draft', 'planned', 'confirmed', 'cancelled'].each do |i|
      @order.status = i
      @order.valid?
      assert !@order.errors.invalid?('status')
    end
  end

  should 'define status question methods' do
    ['draft', 'planned', 'confirmed', 'cancelled'].each do |i|
      @order.status = i
      assert @order.send("#{@order.status}?")
    end
  end

  should 'define forgotten and open status' do
    @order.status = 'draft'
    assert @order.draft?
    assert @order.cycle.orders?
    assert @order.open?
    @order.cycle.status = 'closed'
    assert !@order.open?
    assert @order.forgotten?
  end

  should 'return current status using forgotten and open too' do
    @order.status = 'draft'
    assert @order.open?
    assert_equal 'open', @order.current_status
    @order.cycle.status = 'closed'
    assert @order.forgotten?
    assert_equal 'forgotten', @order.current_status
  end

  should 'define status_message method' do
    assert @order.respond_to?(:status_message)
  end

  ###
  # Delivery
  ###

  should 'give default value to supplier delivery if not present' do
    @order.save!
    @order.profile.save!

    @order.cycle.delivery_methods = []
    @order.supplier_delivery = nil
    assert_nil @order.supplier_delivery

    default = @order.cycle.delivery_methods.create! :profile => @order.profile, :name => 'method', :delivery_type => 'deliver'
    assert_equal default, @order.supplier_delivery
    assert_equal default.id, @order.supplier_delivery_id
  end

  ###
  # Totals
  ###

  should 'give total price and quantity asked' do
    @order.cycle.profile.save!
    product = create(SuppliersPlugin::DistributedProduct, :price => 2.0, :profile => @order.cycle.profile, :supplier => @order.cycle.profile.self_supplier)
    @order.save!
    @order.products.create! :product => @order.cycle.products.first, :quantity_asked => 2.0
    assert_equal 2.0, @order.total_quantity_asked
    assert_equal 4.0, @order.total_price_asked
  end

end
