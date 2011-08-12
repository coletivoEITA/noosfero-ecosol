require File.dirname(__FILE__) + '/../../../../test/test_helper'

class DistributionPluginSessionTest < ActiveSupport::TestCase
  def setup
    @profile = Enterprise.create!(:name => "trocas verdes", :identifier => "trocas-verdes")
    @pc = ProductCategory.create!(:name => 'cat', :environment_id => 1)
    @profile.products = [Product.create!(:name => 'banana', :product_category => @pc),
      Product.new(:name => 'mandioca', :product_category => @pc), Product.new(:name => 'alface', :product_category => @pc)]

    @node = DistributionPluginNode.create!(:profile => @profile, :role => 'collective')
    @node.products = @profile.products.map { |p| DistributionPluginProduct.create!(:product => p) }
    @session = DistributionPluginSession.create!(:node => @node)
  end

  should 'add products from node after create' do
    assert_equal @session.products.collect(&:product_id), @node.products.collect(&:id)
  end
end
