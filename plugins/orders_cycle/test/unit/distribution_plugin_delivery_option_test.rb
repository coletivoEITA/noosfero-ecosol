require File.dirname(__FILE__) + '/../../../../test/test_helper'

class OrdersCyclePluginOptionTest < ActiveSupport::TestCase

  def setup
    @profile = build(Profile)
    @node = build(OrdersCyclePluginNode, :profile => @profile)
    @cycle = build(OrdersCyclePluginCycle, :node => @node)
    @delivery_method = build(OrdersCyclePluginMethod, :node => @node)
  end

  attr_accessor :profile
  attr_accessor :node
  attr_accessor :cycle
  attr_accessor :delivery_method

  should 'be associated with a cycle and a delivery method' do
    option = OrdersCyclePluginOption.new :cycle => @cycle, :delivery_method => @delivery_method
    assert option.valid?
    option = OrdersCyclePluginOption.new
    :wa

    assert !option.valid?
  end

end
