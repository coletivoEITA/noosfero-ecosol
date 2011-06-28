require File.dirname(__FILE__) + '/../../../../test/test_helper'

class DistributionOrderSessionControllerTest < Test::Unit::TestCase

  def setup
    @controller = DistributionOrderSessionController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  should 'create a new session' do
    p = create(Profile)
    n = create(DistributionNode, :profile => p)
    get :new, :node_id => n.id
    assert_equal ss, assigns(:session)
  end

  should 'edit session' do
    ss = create(DistributionOrderSession)
    get :edit, :id => ss.id
    assert_equal ss, assigns(:session)
  end
end
