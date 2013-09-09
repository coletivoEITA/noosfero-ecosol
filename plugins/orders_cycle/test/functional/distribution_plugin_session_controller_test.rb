require File.dirname(__FILE__) + '/../../../../test/test_helper'

class OrdersCyclePluginCycleControllerTest < Test::Unit::TestCase

  def setup
    @controller = OrdersCyclePluginCycleController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  should 'create a new cycle' do
    p = create(Profile)
    n = create(OrdersCyclePluginNode, :profile => p)
    get :new, :node_id => n.id
    assert_equal ss, assigns(:cycle)
  end

  should 'edit cycle' do
    ss = create(OrdersCyclePluginCycle)
    get :edit, :id => ss.id
    assert_equal ss, assigns(:cycle)
  end
end
