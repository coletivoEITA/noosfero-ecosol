require File.dirname(__FILE__) + '/../../../../test/test_helper'

class DistributionOrderTest < ActiveSupport::TestCase
  should 'have an order' do
    os = build(DistributionOrderSession)
    p = build(Profile)
    d = build(DistributionNode)
    dm = build(DistributionDeliveryMethod)
    d = build(DistributionOrder)
    assert d.valid?
  end
end
