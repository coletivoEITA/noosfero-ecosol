require File.dirname(__FILE__) + '/../../../../test/test_helper'

class DistributionNodeTest < Test::Unit::TestCase

  def setup
    @p = build(Profile)
  end

  should 'have a profile' do
    d = DistributionNode.create
    assert !d.valid?
  end

  should 'create necessary roles before instance creation' do
    d = build(DistributionNode, :profile => @p)
    assert_not_nil DistributionNode::Roles.consumer(d.profile.environment)
  end

  should 'add and remove a consumer' do
    p2 = build(Profile)
    d1 = build(DistributionNode, :profile => @p)
    d2 = build(DistributionNode, :profile => p2)
    d1.add_consumer(d2)
    assert d1.consumers.include?(d2)
    #FIXME
    #assert d2.suppliers.include?(d1)

    d1.remove_consumer(d2)
    assert !d1.consumers.include?(d2)
  end

  should 'have a product' do
    d = build(DistributionNode, :profile => @p)
    p = build(DistributionProduct, :distribution_node => d)
    assert d.distribution_products.include? p
    assert p.distribution_node == d
  end

end
