require File.dirname(__FILE__) + '/../../../../test/test_helper'

class DistributionPluginProductTest < ActiveSupport::TestCase

  def setup
    @product = build(SuppliersPlugin::BaseProduct)
  end

  should 'return first from product as supplier product' do
    fp = build(SuppliersPlugin::BaseProduct, :node => @product.node)
    @product.from_products = [fp]
    assert_equal fp, @product.from_product
    assert_equal fp, @product.supplier_product
  end

  should 'respond to dummy and own' do
    assert !@product.dummy?
    assert @product.own?
  end

  should 'return price with margins' do
    supplier_product = build(SuppliersPlugin::DistributedProduct, :price => 10, :margin_percentage => 10, :node => @product.node, :supplier => @product.node.self_supplier)
    product = build(SuppliersPlugin::DistributedProduct, :price => 10, :margin_percentage => 10, :supplier_product => supplier_product, :node => @product.node, :supplier => @product.node.self_supplier)

    product.default_margin_percentage = false
    assert_equal 11.0, product.price_with_margins
    @product.node.margin_percentage = 20
    product.default_margin_percentage = true
    assert_equal 12.0, product.price_with_margins
  end

  should 'build default unit if none exists' do
    assert_equal 0, Unit.count
    assert 'unit', @product.unit.singular
  end

  should 'avoid destroy by raising an exception' do
    assert_raise RuntimeError do
      @product.destroy
    end
  end

  should 'accept price in different formats' do
    @product.price = '2,45'
    assert_equal 2.45, @product.price
  end


end
