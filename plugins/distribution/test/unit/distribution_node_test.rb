require File.dirname(__FILE__) + '/../../../../test/test_helper'

class DistributionNodeTest < Test::Unit::TestCase

  def setup
    @p = create(Profile)
  end

  should 'create necessary roles before instance creation' do
    d = create(DistributionNode, :profile => @p)
    d.save!
    assert_not_nil DistributionNode::Roles.consumer(d.profile.environment)
  end

  should 'add and remove a consumer' do
    p2 = create(Profile)
    d1 = create(DistributionNode, :profile => @p)
    d2 = create(DistributionNode, :profile => p2)
    d1.add_consumer(d2)
    assert d1.consumers.include?(d2)
    assert d2.suppliers.include?(d1)

    d1.remove_consumer(d2)
    assert !d1.consumers.include?(d2)
  end

  should 'have a product' do
    d = create(DistributionNode, :profile => @p)
    pr = create(DistributionProduct, :node_id => d.id)
    assert d.products.include? pr
    assert pr.node_id == d.id
  end

  should 'have a valid role' do
     roles = ['supplier', 'consumer', 'colective'] 
  end

  should '' do 
  end

  should '' do 
  end
end
