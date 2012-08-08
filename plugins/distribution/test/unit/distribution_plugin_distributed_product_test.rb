require File.dirname(__FILE__) + '/../../../../test/test_helper'

class DistributionPluginDistributedProductTest < ActiveSupport::TestCase

  def setup
    @profile = build(Profile)
    @node = build(DistributionPluginNode, :profile => @profile)
    @supplier = build(DistributionPluginSupplier, :node => @node)
  end

  attr_accessor :profile
  attr_accessor :node
  attr_accessor :supplier

  should '' do
  end

end
