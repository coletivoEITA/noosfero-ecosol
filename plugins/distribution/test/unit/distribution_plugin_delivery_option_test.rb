require File.dirname(__FILE__) + '/../../../../test/test_helper'

class DistributionDeliveryOptionTest < ActiveSupport::TestCase
  def setup
    @profile = Enterprise.create!(:name => "trocas verdes", :identifier => "trocas-verdes")
    @pc = ProductCategory.create!(:name => 'cat', :environment_id => 1)
    @profile.products = [Product.create!(:name => 'banana', :product_category => @pc),
      Product.new(:name => 'mandioca', :product_category => @pc), Product.new(:name => 'alface', :product_category => @pc)]

    @node = DistributionPluginNode.create!(:profile => @profile, :role => 'collective')
    @node.products = @profile.products.map { |p| DistributionPluginProduct.create!(:product => p) }
    @session = DistributionPluginSession.create!(:node => @node)

    @dm = DistributionPluginDeliveryMethod.create!(:node => @node, :name => 'metodo de envio', :delivery_type => 'delivery')
  end

  should 'add an option to an session' do
    assert_includes @node.delivery_methods, @dm

    option = DistributionPluginDeliveryOption.create!(:session => @session, :delivery_method => @dm)
    assert_includes @session.delivery_options, option
    assert_includes @session.delivery_methods, @dm
  end
end
