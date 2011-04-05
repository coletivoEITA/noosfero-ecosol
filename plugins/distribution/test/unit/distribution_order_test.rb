require File.dirname(__FILE__) + '/../../../../test/test_helper'

class DistributionOrderTest < ActiveSupport::TestCase

	should 'have an order session' do
		d = DistributionOrderSession.create
		assert !d.valid?
	end

	should 'have a buyer' do
		p = build(Profile)
    		d = DistributionNode.create! :profile => p
		assert !d.valid?
	end

	should 'have a delivery method' do
		d = DistributionDeliveryMethod.create
		assert !d.valid?
	end

	#should 'have ordered products' do
	#	d = DistributionOrderedProduct
end
