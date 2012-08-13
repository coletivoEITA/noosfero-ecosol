require File.dirname(__FILE__) + '/../../../../test/test_helper'

class DistributionPluginProductTest < ActiveSupport::TestCase

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
    :node, :dummy_node, :other_node, :self_supplier, :dummy_supplier, :other_node

  should 'return first from product as supplier product' do
    product = build(DistributionPluginProduct, :price => 10, :margin_percentage => 10, :node => @node, :supplier => @self_supplier,
                    :from_product => build(DistributionPluginProduct, :price => 10, :margin_percentage => 10, :node => @node, :supplier => @self_supplier))
    assert_equal product.from_product, product.supplier_product
  end

end
