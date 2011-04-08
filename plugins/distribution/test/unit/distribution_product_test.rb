require File.dirname(__FILE__) + '/../../../../test/test_helper'

class DistributionProductTest < ActiveSupport::TestCase
  fixtures :products

  should 'have a product and a distribution node' do
    d = DistributionProduct.create
    assert !d.valid?
  end
end
