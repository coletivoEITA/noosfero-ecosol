require File.dirname(__FILE__) + '/../../../../test/test_helper'

class OrdersCyclePluginCycleTest < ActiveSupport::TestCase

  def setup
    @profile = Enterprise.create!(:name => "trocas verdes", :identifier => "trocas-verdes")
    @pc = ProductCategory.create!(:name => 'frutas', :environment_id => 1)
    @profile.products = [Product.create!(:name => 'banana', :product_category => @pc),
      Product.new(:name => 'mandioca', :product_category => @pc), Product.new(:name => 'alface', :product_category => @pc)]

    @node = OrdersCyclePlugin::Node.create!(:profile => @profile, :role => 'collective')
    @node.products = @profile.products.map { |p| OrdersCyclePlugin::OfferedProduct.create!(:product => p) }
    DeliveryPlugin::Method.create! :name => 'at home', :delivery_type => 'pickup', :node => @node
    @cycle = OrdersCyclePlugin::Cycle.create!(:node => @node)
  end

  should 'add products from node after create' do
    assert_equal @cycle.products.collect(&:product_id), @node.products.collect(&:id)
  end

  should 'have at least one delivery method unless in edition status' do
    cycle = OrdersCyclePlugin::Cycle.create! :node => @node, :name => "Testes batidos", :start => DateTime.now, :status => 'edition'
    assert cycle
    cycle.status = 'orders'
    assert_nil cycle.save!
  end

end
