class DistributionPluginDeliveryMethod < ActiveRecord::Base
  belongs_to :node, :class_name => 'DistributionPluginNode'
  belongs_to :order, :class_name => 'DistributionPluginOrder'

  validates_presence_of :node
  validates_presence_of :name
  validates_inclusion_of :delivery_type, :in => ['pickup', 'deliver']
  validates_presence_of :address_line1, :if => :pickup?
  validates_presence_of :state, :if => :pickup?
  validates_presence_of :country, :if => :pickup?

  named_scope :pickup, :conditions => {:delivery_type => 'pickup'}
  named_scope :delivery, :conditions => {:delivery_type => 'deliver'}

  def pickup?
    delivery_type == 'pickup'
  end
  def deliver?
    delivery_type == 'deliver'
  end

end
