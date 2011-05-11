require File.dirname(__FILE__) + '/../../../../test/test_helper'

class DistributionDeliveryMethodTest < ActiveSupport::TestCase
  should 'have a name' do
    dm = build(DistributionDeliveryMethod, :name => 'Delivery Deluxe')
    assert !dm.errors.invalid?(:name)
    dm = DistributionDeliveryMethod.create
    assert !dm.valid?
  end

  # required fields
  should 'have a name, a description and a delivery_type and belong to a node' do
    p = build(Profile)
    node = build(DistributionNode, :role => 'supplier', :profile => p)
    node.save!
    dm = build(DistributionDeliveryMethod, :name => 'Delivery Deluxe', :description => 'Oi', :delivery_type => 'delivery', :node_id => node.id)
    assert dm.valid?
  end

  should 'have an address if delivery_type is pickup' do
    node = build(DistributionNode)
    dm = build(DistributionDeliveryMethod, :name => 'Delivery Deluxe', :description => 'Oi', :delivery_type => 'pickup', :node => node)
    assert !dm.valid?
    dm = build(DistributionDeliveryMethod, :name => 'Delivery Deluxe', :address_line1 => 'Rua dos bobos', :state => 'SP',
	      				   :country => 'Brasil', :description => 'Oi', :delivery_type => 'pickup', :node => node)
    assert dm.valid?
  end

end
