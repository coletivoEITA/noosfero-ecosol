require File.dirname(__FILE__) + '/../../../../test/test_helper'

class SnifferPluginProfileTest < ActiveSupport::TestCase
  should 'find consumer and its products for a profile' do
    SnifferPlugin::Profile.all.first.product_categories.collect(&:id)
  end

  should 'add find methods for input-products relations' do
    #e = Profile['acougue-comunitario']
    #pp = Product.scope(e.products.collect(&:product_ids))

    p = Product.find(33206)
    pu1 = p.products_used
    pu2 = Product.find(:all, :conditions => {:product_category_id => p.inputs.collect(&:product_category_id)} )
    assert_equal pu1, pu2

  end
end
