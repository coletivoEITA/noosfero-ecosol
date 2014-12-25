require_dependency 'profile'

# subclass problem on development and production
if Rails.env.development?
  require_dependency 'enterprise'
  require_dependency 'community'
end
Profile.descendants.each do |subclass|
  subclass.class_eval do
    attr_accessible :sniffer_interested_product_category_string_ids
  end
end

# FIXME: this should be on core
class Profile
  attr_accessor :distance
end

class Profile

  has_many :sniffer_opportunities, class_name: 'SnifferPlugin::Opportunity', dependent: :destroy
  has_many :sniffer_interested_product_categories, through: :sniffer_opportunities, source: :product_category, class_name: 'ProductCategory',
    conditions: ['sniffer_plugin_opportunities.opportunity_type = ?', 'ProductCategory']

  attr_accessible :sniffer_interested_product_category_string_ids
  # getter for form_for, filled after via JS
  def sniffer_interested_product_category_string_ids
    ''
  end
  def sniffer_interested_product_category_string_ids= ids
    ids = ids.split ','
    self.sniffer_interested_product_categories = self.environment.product_categories.find ids
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
