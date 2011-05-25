require File.dirname(__FILE__) + '/../../../../test/test_helper'

class DistributionOrderTest < ActiveSupport::TestCase

  def setup
    @p = create(Profile)
  end

  should 'only create an order for an open session' do
    dc = create(DistributionNode, :profile => @p, :role => 'consumer')
    p = create(Profile)
    ds = create(DistributionNode, :profile => p, :role => 'collective')
    dm = create(DistributionDeliveryMethod, :node => ds)
    os = create(DistributionOrderSession, :node => ds, :start => DateTime.now + 1.days, :finish => DateTime.now + 2.days)
    doption = create(DistributionDeliveryOption, :delivery_method => dm)
    os.delivery_methods = [doption]
    o1 = create(DistributionOrder, :order_session => os, :consumer => dc, :supplier_delivery => dm)
    # This test has a closed session and woudn't pass
    puts os.open?
    assert !o1.valid?
    os = create(DistributionOrderSession, :node => ds, :delivery_methods => [doption], :start => DateTime.now.ago(5.days), :finish => DateTime.now + 2.days)
    o2 = create(DistributionOrder, :order_session => os, :consumer => dc, :supplier_delivery => dm)
    puts o2.errors.to_yaml
    assert o2.valid?
  end

  should '' do
  end
end
