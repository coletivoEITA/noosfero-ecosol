require File.dirname(__FILE__) + '/../../../../test/test_helper'

class DistributionDeliveryMethodTest < ActiveSupport::TestCase
  should 'have an order' do
    o = build(DistributionOrder)
    dm = build(DistributionDeliveryMethod, :orders => [o])
    assert !dm.errors.invalid?(:orders)
  end

  should 'have a name' do
    dm = build(DistributionDeliveryMethod, :name => 'Delivery Deluxe')
    assert !dm.errors.invalid?(:name)
    dm = DistributionDeliveryMethod.create
    assert !dm.valid?
  end

  # required fields
  should 'have a name, a description and a type and belong to a node' do
    node = build(DistributionNode)
    dm = build(DistributionDeliveryMethod, :name => 'Delivery Deluxe', :description => 'Oi', :type => 'delivery', :node => node)
    puts dm.errors.to_yaml
    assert dm.valid?
  end

  should 'have an address if type is pickup' do
    node = build(DistributionNode)
    dm = build(DistributionDeliveryMethod, :name => 'Delivery Deluxe', :description => 'Oi', :type => 'pickup', :node => node)
    assert !dm.valid?
    dm = build(DistributionDeliveryMethod, :name => 'Delivery Deluxe', :address_line1 => 'Rua dos bobos', :state => 'SP',
	      				   :country => 'Brasil', :description => 'Oi', :type => 'pickup', :node => node)
    assert dm.valid?
  end

end
