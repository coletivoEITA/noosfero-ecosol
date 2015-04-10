require File.dirname(__FILE__) + '/../../../../test/test_helper'

class SnifferPluginProfileTest < ActiveSupport::TestCase

  should 'register interest on a product cattegory for a profile' do
    # crate an entreprise
    coop = fast_create(Enterprise,
      :identifier => 'coop', :name => 'A Cooperative', :lat => 0, :lng => 0
    )
    # create categories
    c1 = fast_create(ProductCategory, :name => 'Category 1')
    c2 = fast_create(ProductCategory, :name => 'Category 2')
    # get the extended sniffer profile for the enterprise:
    sniffer_coop = SnifferPlugin::Profile.find_or_create coop
    sniffer_coop.product_category_string_ids = "#{c1.id},#{c2.id}"
    sniffer_coop.enabled = true
    sniffer_coop.save!

    # search for and instance again the profile sniffer for coop
    same_sniffer = SnifferPlugin::Profile.find_or_create coop

    categories = same_sniffer.product_categories
    assert_equal 2, categories.length
    assert_equal 'Category 1', categories[0].name
    assert_equal 'Category 2', categories[1].name
  end

  should 'find suppliers and consumers products' do
    # Enterprises:
    e1 = fast_create(Enterprise, :identifier => 'ent1' )
    e2 = fast_create(Enterprise, :identifier => 'ent2' )
    # Categories:
    c1 = fast_create(ProductCategory, :name => 'Category 1')
    c2 = fast_create(ProductCategory, :name => 'Category 2')
    c3 = fast_create(ProductCategory, :name => 'Category 3')
    c4 = fast_create(ProductCategory, :name => 'Category 4') # not used by products
    # Products (for enterprise 1):
    p1 = fast_create(Product, :product_category_id => c1.id, :profile_id => e1.id )
    p2 = fast_create(Product, :product_category_id => c2.id, :profile_id => e1.id )
    # Products (for enterprise 2):
    p3 = fast_create(Product, :product_category_id => c3.id, :profile_id => e2.id )
    p3.inputs.build.product_category = c1 # p3 uses p1 as input on its production
    p3.save!

    # get the extended sniffer profile for the enterprise:
    e1_sniffer = SnifferPlugin::Profile.find_or_create e1
    e2_sniffer = SnifferPlugin::Profile.find_or_create e2
    # register e2 interest for 'Category 2' use by p2
    e2_sniffer.product_category_string_ids = "#{c2.id},#{c4.id}"
    e2_sniffer.enabled = true
    e2_sniffer.save!

    # TODO: Review consumers_products. e1 is cazy supling p3 from c2. But works for mapping.
    assert_equal [p2.id, p3.id],
      e1_sniffer.consumers_products.sort{|a,b| a.id<=>b.id}.map(&:id)
    assert_equal [p1.id, p2.id],
      e2_sniffer.suppliers_products.sort{|a,b| a.id<=>b.id}.map(&:id)
    assert_equal [], e2_sniffer.consumers_products
  end
end
