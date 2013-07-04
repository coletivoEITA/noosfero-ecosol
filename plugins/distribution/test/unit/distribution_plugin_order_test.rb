require File.dirname(__FILE__) + '/../../../../test/test_helper'

class DistributionPlugin::OrderTest < ActiveSupport::TestCase

  def setup
    @order = build(DistributionPlugin::Order)
  end

  should 'format code with session code' do
    @order.save!
    assert_equal "#{@order.session.code}.#{@order.attributes['code']}", @order.code
  end

  should 'use as draft default status' do
    @order = create(DistributionPlugin::Order, :status => nil)
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
    assert @order.session.orders?
    assert @order.open?
    @order.session.status = 'closed'
    assert !@order.open?
    assert @order.forgotten?
  end

  should 'return current status using forgotten and open too' do
    @order.status = 'draft'
    assert @order.open?
    assert_equal 'open', @order.current_status
    @order.session.status = 'closed'
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
    @order.node.save!

    @order.session.delivery_methods = []
    @order.supplier_delivery = nil
    assert_nil @order.supplier_delivery

    default = @order.session.delivery_methods.create! :node => @order.node, :name => 'method', :delivery_type => 'deliver'
    assert_equal default, @order.supplier_delivery
    assert_equal default.id, @order.supplier_delivery_id
  end

  ###
  # Totals
  ###

  should 'give total price and quantity asked' do
    @order.session.node.save!
    product = create(SuppliersPlugin::DistributedProduct, :price => 2.0, :node => @order.session.node, :supplier => @order.session.node.self_supplier)
    @order.save!
    @order.products.create! :session_product => @order.session.products.first, :quantity_asked => 2.0
    assert_equal 2.0, @order.total_quantity_asked
    assert_equal 4.0, @order.total_price_asked
  end

end
