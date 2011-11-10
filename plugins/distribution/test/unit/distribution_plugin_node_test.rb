require File.dirname(__FILE__) + '/../test_helper'

class DistributionPluginNodeTest < ActiveRecord::TestCase

  before :each do
    @p = create(Profile)
    @p2 = create(Profile)
  end
  after :each do
    @p.destroy
    @p2.destroy
  end

  it 'should create necessary roles before instance creation' do
    d = create(DistributionPluginNode, :profile => @p)
    d.save!
    assert_not_nil DistributionPluginNode::Roles.consumer(d.profile.environment)
  end

  describe "Roles" do 
    it "should have a valid role" do
      d = DistributionPluginNode.create :profile => @p, :role => 'bla'
      assert d.errors.invalid?('role')

      ['supplier', 'consumer', 'collective'] .each do |i|
        d = DistributionPluginNode.create :profile => @p, :role => i
        assert !d.errors.invalid?('role')
      end
    end

    it "should define a consumer role" do
    end

    it "should assign consumer role to suppliers and consumer" do
    end
  end

  describe "Suppliers" do 
    before :each do
      @node = create(DistributionPluginNode, :profile => @p)
      @supplier_node = create(DistributionPluginNode, :profile => @p2)
      @supplier = @node.add_consumer(@supplier_node)
    end
    after :each do
      @supplier.destroy
      @node.destroy
    end

    it 'should add and remove a consumer' do
      assert @node.consumers_nodes.include?(@supplier_node)
      assert @supplier_node.suppliers_nodes.include?(@node)

      @node.remove_consumer(@supplier_node)
      assert !@node.consumers_nodes.include?(@supplier_node)
    end

    describe "Products" do 
      before :each do
        @product = create(DistributionPluginDistributedProduct, :node => @node, :supplier => @supplier)
      end
      after :each do
        @product.destroy!
      end

      it 'should have a product' do
        assert @node.products.include? @product
      end
    end

  end

end
