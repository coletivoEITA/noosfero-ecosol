require File.dirname(__FILE__) + '/../../../../test/test_helper'

class SuppliersPluginDistributedProductTest < ActiveSupport::TestCase

  def setup
    @profile = build(Enterprise)
    @invisible_profile = build(Enterprise, :visible => false)
    @other_profile = build(Enterprise)
    @node = build(SuppliersPlugin::Node, :profile => @profile)
    @dummy_node = build(SuppliersPlugin::Node, :profile => @invisible_profile)
    @other_node = build(SuppliersPlugin::Node, :profile => @other_profile)
    @self_supplier = build(SuppliersPlugin::Supplier, :consumer => @node, :node => @node)
    @dummy_supplier = build(SuppliersPlugin::Supplier, :consumer => @node, :node => @dummy_node)
    @other_supplier = build(SuppliersPlugin::Supplier, :consumer => @node, :node => @other_node)
  end

  attr_accessor :profile, :invisible_profile, :other_profile,
    :node, :dummy_node, :other_node, :self_supplier, :dummy_supplier, :other_supplier

  should 'return default settings considering dummy supplier' do
    product = build(SuppliersPlugin::DistributedProduct, :node => @node, :supplier => @dummy_supplier)
    assert_equal nil, product.default_name
    assert_equal nil, product.default_description
    product = build(SuppliersPlugin::DistributedProduct, :node => @node, :supplier => @other_supplier)
    assert_equal true, product.default_name
    assert_equal true, product.default_description
  end

  should 'return price without margins if it is own product' do
    product = build(SuppliersPlugin::DistributedProduct, :price => 10, :margin_percentage => 10, :node => @node, :supplier => @self_supplier)
    assert_equal 10.0, product.price.to_f
  end

  should 'return price without margins if supplier product has no price' do
    supplier_product = build(SuppliersPlugin::DistributedProduct, :node => @other_node, :supplier => @other_node.self_supplier)
    product = build(SuppliersPlugin::DistributedProduct, :price => 10, :margin_percentage => 10, :node => @node, :supplier => @other_supplier)
    assert_equal 10.0, product.price.to_f
  end

  should 'return price with margins' do
    supplier_product = build(SuppliersPlugin::DistributedProduct, :price => 10, :margin_percentage => 10, :node => @other_node, :supplier => @other_node.self_supplier)
    product = build(SuppliersPlugin::DistributedProduct, :price => 10, :margin_percentage => 10, :supplier_product => supplier_product, :node => @node, :supplier => @other_supplier)

    product.default_margin_percentage = false
    assert_equal 11.0, product.price.to_f
    node.margin_percentage = 20
    product.default_margin_percentage = true
    assert_equal 12.0, product.price.to_f
  end

  should 'allow set of supplier product' do
    product = build(SuppliersPlugin::DistributedProduct, :price => 10, :margin_percentage => 10, :node => @node, :supplier => @self_supplier)

    product.from_product = build(SuppliersPlugin::DistributedProduct, :node => @node, :supplier => @self_supplier)
    assert_nothing_raised do
      product.supplier_product = {:price => 10, :margin_percentage => 10}
      product.supplier_product = SuppliersPlugin::DistributedProduct.new :price => 5
    end
  end

  should 'create a supplier product for a dummy supplier' do
    product = build(SuppliersPlugin::DistributedProduct, :node => @node, :supplier => @dummy_supplier)
    assert product.supplier_product
    # negative assertion
    product = build(SuppliersPlugin::DistributedProduct, :node => @node, :supplier => @other_supplier)
    assert !product.supplier_product
  end

  should 'respond to supplier_product_id setter and getter' do
    product = create(SuppliersPlugin::DistributedProduct, :node => @node, :supplier => @dummy_supplier)
    assert_equal product.supplier_product.id, product.supplier_product_id
    product.expects(:distribute_from)
    product.supplier_product_id = 1
  end

  should 'respond to distribute_from' do
    product = create(SuppliersPlugin::DistributedProduct, :node => @node, :supplier => @node.self_supplier)

    assert_raise RuntimeError do
      supplier_product = build(SuppliersPlugin::DistributedProduct, :node => @other_node)
      product.distribute_from(supplier_product)
    end

    supplier_product = create(SuppliersPlugin::DistributedProduct, :node => @other_node)
    product.node.add_supplier @other_node
    product.distribute_from supplier_product
    assert_equal product.supplier.node, supplier_product.node
    assert_equal product.supplier.node, supplier_product.node
  end

  should 'return json for category hierarchy' do
    grandparent = create(ProductCategory, :name => 'grand parent')
    parent = create(ProductCategory, :name => 'parent')
    child = create(ProductCategory, :name => 'child')

    product = SuppliersPlugin::DistributedProduct.new :category => parent
    hash = {:own_name => "parent", :id => "2", :subcats => [], :name => "parent",
            :hierarchy => [{:own_name => "parent", :subcats => [], :name => "parent", :id => "2"}]}
    assert_equal hash, product.json_for_category
  end

end
