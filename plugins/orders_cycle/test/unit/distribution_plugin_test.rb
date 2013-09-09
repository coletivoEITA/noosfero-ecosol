require File.dirname(__FILE__) + '/../../../../test/test_helper'

class OrdersCyclePluginTest < ActiveSupport::TestCase

  def setup
    @distribution = OrdersCyclePlugin.new
    @context = mock()
    @profile = mock()
    @profile.stubs(:identifier).returns('random-user')
    @context.stubs(:profile).returns(@profile)
    @distribution.context = @context
    @distribution.stubs(:profile).returns(@profile)
  end

  attr_reader :distribution
  attr_reader :context
  attr_reader :profile

  should 'return true to stylesheet' do
    assert distribution.stylesheet?
  end

end
