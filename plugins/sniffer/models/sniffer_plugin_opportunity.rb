class SnifferPluginOpportunity < ActiveRecord::Base

  belongs_to :sniffer_profile, :class_name => 'SnifferPluginProfile', :foreign_key => 'profile_id'
  has_one :profile, :through => :sniffer_profile

  belongs_to :opportunity, :polymorphic => true

  # for has_many :through
  belongs_to :product_category, :class_name => 'ProductCategory', :foreign_key => 'opportunity_id',
    :conditions => ['opportunity_type = ?', 'ProductCategory']
  # getter
  def product_category
    opportunity_type == 'ProductCategory' ? opportunity : nil
  end

  named_scope :product_categories, {
    :conditions => ['opportunity_type = ?', 'ProductCategory']
  }

end
