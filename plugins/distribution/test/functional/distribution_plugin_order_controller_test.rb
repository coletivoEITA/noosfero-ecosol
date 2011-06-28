require File.dirname(__FILE__) + '/../../../../test/test_helper'

class DistributionOrderControllerTest < Test::Unit::TestCase

  def setup
    @controller = DistributionOrderController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  should 'create a new order' do
    ss = create(DistributionOrderSession)
    get :new, :session_id => ss.id
    assert_equal ss, assigns(:session)

    #get :people, :filter => 'more_anything'
    #assert_equal 'More recent people' , assigns(:title)
    #assert_tag :h1, :content => 'More recent people'
  end

  should 'edit order' do
    ss = create(DistributionOrderSession)
    o = create(DistributionOrder, :order_session => ss)
    get :edit, :id => o.id
    assert_equal ss, assigns(:session)
  end
end
