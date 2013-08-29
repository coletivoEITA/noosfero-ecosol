require File.dirname(__FILE__) + '/../../../../test/test_helper'

class DistributionPluginOptionTest < ActiveSupport::TestCase

  def setup
    @profile = build(Profile)
    @node = build(DistributionPluginNode, :profile => @profile)
    @session = build(DistributionPluginSession, :node => @node)
    @delivery_method = build(DistributionPluginMethod, :node => @node)
  end

  attr_accessor :profile
  attr_accessor :node
  attr_accessor :session
  attr_accessor :delivery_method

  should 'be associated with a session and a delivery method' do
    option = DistributionPluginOption.new :session => @session, :delivery_method => @delivery_method
    assert option.valid?
    option = DistributionPluginOption.new
    :wa

    assert !option.valid?
  end

end
