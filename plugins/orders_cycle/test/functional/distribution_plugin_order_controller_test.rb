require File.dirname(__FILE__) + '/../../../../test/test_helper'

class OrdersCyclePluginOrderControllerTest < Test::Unit::TestCase

  def setup
    @controller = OrdersCyclePluginOrderController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  should 'create a new order' do
    ss = create(OrdersCyclePluginCycle)
    get :new, :cycle_id => ss.id
    assert_equal ss, assigns(:cycle)

    #get :people, :filter => 'more_anything'
    #assert_equal 'More recent people' , assigns(:title)
    #assert_tag :h1, :content => 'More recent people'
  end

  should 'edit order' do
    ss = create(OrdersCyclePluginCycle)
    o = create(OrdersCyclePluginOrder, :cycle => ss)
    get :edit, :id => o.id
    assert_equal ss, assigns(:cycle)
  end
end
