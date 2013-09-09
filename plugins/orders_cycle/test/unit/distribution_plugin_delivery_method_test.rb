require File.dirname(__FILE__) + '/../../../../test/test_helper'

class OrdersCyclePluginMethodTest < ActiveSupport::TestCase

  def setup
    @profile = build(Profile)
    @node = build(OrdersCyclePlugin::Node, :role => 'supplier', :profile => @profile)
  end

  attr_accessor :profile
  attr_accessor :node

  should 'have a name and a delivery type' do
    dm = DeliveryPlugin::Method.new :name => 'Delivery Deluxe', :delivery_type => 'deliver', :node => node
    assert dm.valid?
    dm = DeliveryPlugin::Method.new :node => node
    assert !dm.valid?
  end

  should 'accept only pickup and deliver as delivery types' do
    dm = build(DeliveryPlugin::Method, :name => 'Delivery Deluxe', :delivery_type => 'unkown', :node => node)
    assert !dm.valid?
    dm = build(DeliveryPlugin::Method, :name => 'Delivery Deluxe', :delivery_type => 'pickup', :node => node)
    assert dm.valid?
    dm = build(DeliveryPlugin::Method, :name => 'Delivery Deluxe', :delivery_type => 'deliver', :node => node)
    assert dm.valid?
  end

  should 'filter by delivery types' do
    dm_deliver = create(DeliveryPlugin::Method, :name => 'Delivery Deluxe', :delivery_type => 'deliver', :node => node)
    dm_pickup = create(DeliveryPlugin::Method, :name => 'Delivery Deluxe', :delivery_type => 'pickup', :node => node)
    assert_equal [dm_deliver], DeliveryPlugin::Method.delivery
    assert_equal [dm_pickup], DeliveryPlugin::Method.pickup
  end

  should 'have many delivery options' do
    dm = create(DeliveryPlugin::Method, :name => 'Delivery Deluxe', :delivery_type => 'deliver', :node => node)
    cycle = build(OrdersCyclePlugin::Cycle, :name => 'cycle name', :node => node)
    option = create(DeliveryPlugin::Option, :cycle => cycle, :delivery_method => dm)

    assert_equal [option], dm.reload.delivery_options
  end

end
