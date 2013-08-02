require File.dirname(__FILE__) + '/../../../../test/test_helper'

class DistributionPluginDeliveryMethodTest < ActiveSupport::TestCase

  def setup
    @profile = build(Profile)
    @node = build(DistributionPlugin::Node, :role => 'supplier', :profile => @profile)
  end

  attr_accessor :profile
  attr_accessor :node

  should 'have a name and a delivery type' do
    dm = DeliveryPlugin::DeliveryMethod.new :name => 'Delivery Deluxe', :delivery_type => 'deliver', :node => node
    assert dm.valid?
    dm = DeliveryPlugin::DeliveryMethod.new :node => node
    assert !dm.valid?
  end

  should 'accept only pickup and deliver as delivery types' do
    dm = build(DeliveryPlugin::DeliveryMethod, :name => 'Delivery Deluxe', :delivery_type => 'unkown', :node => node)
    assert !dm.valid?
    dm = build(DeliveryPlugin::DeliveryMethod, :name => 'Delivery Deluxe', :delivery_type => 'pickup', :node => node)
    assert dm.valid?
    dm = build(DeliveryPlugin::DeliveryMethod, :name => 'Delivery Deluxe', :delivery_type => 'deliver', :node => node)
    assert dm.valid?
  end

  should 'filter by delivery types' do
    dm_deliver = create(DeliveryPlugin::DeliveryMethod, :name => 'Delivery Deluxe', :delivery_type => 'deliver', :node => node)
    dm_pickup = create(DeliveryPlugin::DeliveryMethod, :name => 'Delivery Deluxe', :delivery_type => 'pickup', :node => node)
    assert_equal [dm_deliver], DeliveryPlugin::DeliveryMethod.delivery
    assert_equal [dm_pickup], DeliveryPlugin::DeliveryMethod.pickup
  end

  should 'have many delivery options' do
    dm = create(DeliveryPlugin::DeliveryMethod, :name => 'Delivery Deluxe', :delivery_type => 'deliver', :node => node)
    session = build(DistributionPlugin::Session, :name => 'session name', :node => node)
    option = create(DeliveryPlugin::DeliveryOption, :session => session, :delivery_method => dm)

    assert_equal [option], dm.reload.delivery_options
  end

end
