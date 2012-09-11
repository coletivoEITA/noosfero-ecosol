require File.dirname(__FILE__) + '/../../../../test/test_helper'

class DistributionPluginNodeTest < ActiveRecord::TestCase

  def setup
    @profile = build(Profile)
    @invisible_profile = build(Enterprise, :visible => false)
    @other_profile = build(Enterprise)
    @node = build(DistributionPluginNode, :profile => @profile)
    @dummy_node = build(DistributionPluginNode, :profile => @invisible_profile)
    @other_node = build(DistributionPluginNode, :profile => @other_profile)
    @self_supplier = build(DistributionPluginSupplier, :consumer => @node, :node => @node)
    @dummy_supplier = build(DistributionPluginSupplier, :consumer => @node, :node => @dummy_node)
    @other_supplier = build(DistributionPluginSupplier, :consumer => @node, :node => @other_node)
  end

  attr_accessor :profile, :invisible_profile, :other_profile,
    :node, :dummy_node, :other_node, :self_supplier, :dummy_supplier, :other_supplier

  should 'respond to name methods' do
    profile.expects(:name).returns('name')
    assert_equal 'name', node.name
  end

  should 'respond to dummy methods' do
    node.dummy = true
    assert_equal true, node.dummy?
    node.dummy = false
    assert_equal false, node.dummy
  end

  should "return closed sessions' date range" do
    DateTime.expects(:now).returns(1).at_least_once
    assert_equal 1..1, node.closed_sessions_date_range
    s1 = create(DistributionPluginSession, :node => node, :start => Time.now-1.days, :finish => nil)
    s2 = create(DistributionPluginSession, :node => node, :finish => Time.now+1.days, :start => Time.now)
    assert_equal (s1.start.to_date..s2.finish.to_date), node.closed_sessions_date_range
  end

  should 'return abbreviation or the name' do
    node.name_abbreviation = 'coll.'
    node.profile.name = 'collective'
    assert_equal 'coll.', node.abbreviation_or_name
    node.name_abbreviation = nil
    assert_equal 'collective', node.abbreviation_or_name
  end

  ###
  # Products
  ###

  should "default products's margins when asked" do
    node.update_attributes! :margin_percentage => 10, :margin_fixed => 1
    product = create(DistributionPluginDistributedProduct, :node => node, :supplier => node.self_supplier,
                     :price => 10, :default_margin_percentage => false, :default_margin_fixed => true)
    session = create(DistributionPluginSession, :node => node)
    sproduct = session.products.first
    sproduct.update_attributes! :margin_percentage => 5, :margin_fixed => 2
    sessionclosed = create(DistributionPluginSession, :node => node, :status => 'closed')

    node.default_products_margins
    product.reload
    sproduct.reload
    assert_equal true, product.default_margin_fixed
    assert_equal true, product.default_margin_percentage
    assert_equal sproduct.margin_percentage, node.margin_percentage
    assert_equal sproduct.margin_fixed, node.margin_fixed
  end

  should 'return not yet distributed products' do
    node.save!
    other_node.save!
    other_supplier.save!
    product = create(DistributionPluginDistributedProduct, :node => other_node, :supplier => other_node.self_supplier)
    node.add_supplier_products other_supplier
    product2 = create(DistributionPluginDistributedProduct, :node => other_node, :supplier => other_node.self_supplier)
    assert_equal [product2], node.not_distributed_products(other_supplier)
  end

  ###
  # Roles
  ###

  should 'have role question methods' do
    node.role = 'consumer'
    assert_equal true, node.consumer?
    node.role = 'supplier'
    assert_equal true, node.supplier?
    node.role = 'collective'
    assert_equal true, node.collective?
  end

  should "should have a valid role" do
    node.role = 'blah'
    node.valid?
    assert node.errors.invalid?('role')

    ['supplier', 'consumer', 'collective'].each do |i|
      node = build(DistributionPluginNode, :profile => @profile, :role => i)
      assert !node.errors.invalid?('role')
    end
  end

  should 'create necessary roles before instance creation' do
    assert_nil DistributionPluginNode::Roles.consumer(profile.environment)
    node.save!
    assert_not_nil DistributionPluginNode::Roles.consumer(node.profile.environment)
  end

  ###
  # Suppliers
  ###

  should 'add supplier' do
    @node.save!
    @other_node.save!

    assert_difference DistributionPluginSupplier, :count do
      assert_difference RoleAssignment, :count do
        @node.add_supplier @other_node
      end
    end
    assert @node.suppliers_nodes.include?(@other_node)
    assert @other_node.consumers_nodes.include?(@node)
  end

  should "add all supplier's products when supplier is added" do
    @node.save!
    @other_node.save!
    product = create(DistributionPluginDistributedProduct, :node => @other_node)
    @node.add_supplier @other_node
    assert_equal [product], @node.from_products
  end

  should 'remove supplier' do
    @node.save!
    @other_node.save!

    @node.add_supplier @other_node
    assert_difference DistributionPluginSupplier, :count, -1 do
      assert_difference RoleAssignment, :count, -1 do
        @node.remove_supplier @other_node
      end
    end
    assert !@node.suppliers_nodes.include?(@other_node)
  end

  should "archive supplier's products when supplier is removed" do
    @node.save!
    @other_node.save!
    product = create(DistributionPluginDistributedProduct, :node => @other_node)
    @node.add_supplier @other_node
    @node.remove_supplier @other_node
    assert_equal [product], @node.from_products
    assert_equal 1, @node.products.distributed.archived.count
  end

  should 'create self supplier automatically' do
    node = create(DistributionPluginNode, :profile => @profile)
    assert_equal 1, node.suppliers.count
  end

end
