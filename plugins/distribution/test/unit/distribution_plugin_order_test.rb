require File.dirname(__FILE__) + '/../../../../test/test_helper'

class DistributionOrderTest < ActiveSupport::TestCase

  def setup
    @p = build(Profile)
  end

  should 'only create an order for an open session' do
    dc = build(DistributionNode, :profile => @p, :role => 'consumer')
    p = build(Profile)
    ds = build(DistributionNode, :profile => p, :role => 'collective')
    dm = build(DistributionDeliveryMethod, :node => ds)
    os = build(DistributionOrderSession, :node => ds, :start => DateTime.now + 1.days, :finish => DateTime.now + 2.days)
    doption = create(DistributionDeliveryOption, :delivery_method => dm)
    os.delivery_methods = [doption]
    o1 = build(DistributionOrder, :order_session => os, :consumer => dc, :supplier_delivery => dm)
    # This test has a closed session and woudn't pass
    assert !o1.valid?
    os = build(DistributionOrderSession, :node => ds, :delivery_methods => [doption], :start => DateTime.now.ago(5.days), :finish => DateTime.now + 2.days)
    o2 = build(DistributionOrder, :order_session => os, :consumer => dc, :supplier_delivery => dm)
    assert o2.valid?
  end

  should '' do
  end
end
