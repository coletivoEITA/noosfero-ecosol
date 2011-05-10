require File.dirname(__FILE__) + '/../../../../test/test_helper'

class DistributionOrderTest < ActiveSupport::TestCase
  fixtures :profiles, :distribution_order_session, :distribution_node, :distribution_order, :distribution_delivery_method

  should 'have an order' do
    os = distribution_order_session()
    p os.to_yaml
    p = build(Profile)
    d = build(DistributionNode)
    dm = build(DistributionDeliveryMethod)
    d = build(DistributionOrder)
    assert d.valid?
  end
end
