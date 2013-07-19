# FIXME remove Delivery when plugins scope problem is solved
class DeliveryPlugin::DeliveryMethod < Noosfero::Plugin::ActiveRecord

  def self.table_name
    'delivery_plugin_methods'
  end

  belongs_to :profile

  has_many :delivery_options, :class_name => 'DeliveryPlugin::DeliveryOption', :foreign_key => :delivery_method_id, :dependent => :destroy

  validates_presence_of :profile
  validates_presence_of :name
  validates_inclusion_of :delivery_type, :in => ['pickup', 'deliver']

  named_scope :pickup, :conditions => {:delivery_type => 'pickup'}
  named_scope :delivery, :conditions => {:delivery_type => 'deliver'}

  def pickup?
    delivery_type == 'pickup'
  end
  def deliver?
    delivery_type == 'deliver'
  end

end
