require File.dirname(__FILE__) + '/../../../../test/test_helper'

class DistributionNodeTest < Test::Unit::TestCase
  fixtures :profiles, :distribution_nodes

  should 'have a profile' do
    d = DistributionNode.create
    assert !d.valid?
  end

  should 'create necessary roles before instance creation' do
    p = build(Profile)
    d = DistributionNode.create! :profile => p
    assert_not_nil DistributionNode::Roles.consumer(d.profile.environment)
  end

  should 'add and remove a consumer' do
    p1 = build(Profile)
    p2 = build(Profile)
    d1 = DistributionNode.create! :profile => p1
    d2 = DistributionNode.create! :profile => p2
    d1.add_consumer(d2)
    assert d1.consumers.include?(d2)
    #assert d2.suppliers.include?(d1)

    d1.remove_consumer(d2)
    assert !d1.consumers.include?(d2)
  end

  should 'have a product' do
    p = build(Profile)
    d = DistributionNode.create! :profile => p
    p = DistributionProduct.create! :distribution_node => d
    assert d.distribution_products.include? p
    assert p.distribution_node == d
  end

end
