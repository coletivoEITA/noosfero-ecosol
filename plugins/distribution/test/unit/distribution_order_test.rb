require File.dirname(__FILE__) + '/../../../../test/test_helper'

class DistributionOrderTest < ActiveSupport::TestCase
  fixtures :profiles

  should 'have an order' do
    os = DistributionOrderSession.create
    p = build(Profile)
    d = DistributionNode.create! :profile => p
    dm = DistributionDeliveryMethod.create
    d = DistributionOrder.create! :node => d, \
      :order_session => os, \
      :delivery_method => dm
    assert d.valid?
  end
end
