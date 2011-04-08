require File.dirname(__FILE__) + '/../../../../test/test_helper'

class DistributionDeliveryMethodTest < ActiveSupport::TestCase

  should 'have a delivery method' do
    dm = DistributionDeliveryMethod.create
    assert !dm.valid?
  end
end
