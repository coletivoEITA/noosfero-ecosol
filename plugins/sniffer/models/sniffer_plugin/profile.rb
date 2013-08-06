class SnifferPlugin::Profile < Noosfero::Plugin::ActiveRecord

  belongs_to :profile

  has_many :opportunities, :class_name => 'SnifferPlugin::Opportunity', :foreign_key => 'profile_id', :dependent => :destroy
  has_many :product_categories, :through => :opportunities, :source => :product_category, :foreign_key => 'profile_id', :class_name => 'ProductCategory',
    :conditions => ['sniffer_plugin_opportunities.opportunity_type = ?', 'ProductCategory']

  validates_presence_of :profile

  def self.find_or_create profile
    sniffer = SnifferPlugin::Profile.find_by_profile_id profile.id
    if sniffer.nil?
      sniffer = SnifferPlugin::Profile.new(:profile => profile, :enabled => true)
      sniffer.profile = profile
      sniffer.save!
    end
    sniffer
  end

  attr_accessible :product_category_string_ids
  def product_category_string_ids
    ''
  end
  def product_category_string_ids=(ids)
    ids = ids.split(',')
    self.product_categories = []
    r = ProductCategory.find(ids)
    self.product_categories = ids.collect {|id| r.detect {|x| x.id == id.to_i}}
    self.opportunities.find(:all, :conditions => {:opportunity_id => ids}).each{|o| o.opportunity_type = 'ProductCategory'; o.save! }
  end

  def profile_input_categories
    profile.input_categories
  end

  def profile_product_categories
    profile.product_categories
  end

  def all_categories
    (profile_product_categories + profile_input_categories + product_categories).uniq
  end

  def suppliers_products
    products = []

    products += Product.suppliers_products profile if profile.enterprise?
    products += Product.interests_suppliers_products profile
    if defined?(CmsLearningPlugin)
      products += Product.knowledge_suppliers_inputs profile
      products += Product.knowledge_suppliers_interests profile
    end

    products
  end

  def consumers_products
    products = []

    products += Product.consumers_products profile if profile.enterprise?
    products += Product.interests_consumers_products profile
    if defined?(CmsLearningPlugin)
      products += Product.knowledge_consumers_inputs profile
      products += Product.knowledge_consumers_interests profile
    end

    products
  end

end
