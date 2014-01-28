require_dependency 'profile'

# FIXME: this should be on core
class Profile
  attr_accessor :distance
end

class Profile

  has_many :sniffer_opportunities, :class_name => 'SnifferPlugin::Opportunity', :dependent => :destroy
  has_many :sniffer_interested_product_categories, :through => :sniffer_opportunities, :source => :product_category, :class_name => 'ProductCategory',
    :conditions => ['sniffer_plugin_opportunities.opportunity_type = ?', 'ProductCategory']

  attr_accessor :sniffer_interested_product_category_string_ids
  def sniffer_interested_product_category_string_ids
    ''
  end
  def sniffer_interested_product_category_string_ids=(ids)
    ids = ids.split(',')
    self.sniffer_interested_product_categories = []
    r = environment.product_categories.find ids
    self.sniffer_interested_product_categories = ids.collect{ |id| r.detect {|x| x.id == id.to_i} }
    self.sniffer_opportunities.where(:opportunity_id => ids).each{|o| o.opportunity_type = 'ProductCategory'; o.save! }
  end

  def sniffer_categories
    (self.product_categories + self.input_categories + self.sniffer_interested_product_categories).uniq
  end

  def sniffer_suppliers_products
    products = []

    products += Product.suppliers_products self if self.enterprise?
    products += Product.interests_suppliers_products self
    if defined?(CmsLearningPlugin)
      products += Product.knowledge_suppliers_inputs self
      products += Product.knowledge_suppliers_interests self
    end

    products
  end

  def sniffer_consumers_products
    products = []

    products += Product.consumers_products self if self.enterprise?
    products += Product.interests_consumers_products self
    if defined?(CmsLearningPlugin)
      products += Product.knowledge_consumers_inputs self
      products += Product.knowledge_consumers_interests self
    end

    products
  end

end
