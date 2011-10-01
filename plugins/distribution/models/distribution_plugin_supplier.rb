class DistributionPluginSupplier < ActiveRecord::Base
  belongs_to :node,  :class_name => 'DistributionPluginNode'
  belongs_to :consumer,  :class_name => 'DistributionPluginNode'

  named_scope :from_node, lambda { |n| { :conditions => {:node_id => n.id} } }
  named_scope :from_node_id, lambda { |id| { :conditions => {:node_id => id} } }

  validates_presence_of :node
  validates_presence_of :consumer
  validates_presence_of :name

  def self?
    node == consumer
  end

  has_one :profile, :through => :node
  def profile
    node.profile
  end

  def dummy?
    node.dummy?
  end

  def name
    attributes['name'] || self.profile.name
  end

  def abbreviation_or_name
    name_abbreviation.blank? ? name : name_abbreviation
  end

  def name=(value)
    self['name'] = value
    if dummy?
      self.profile.name = value
      self.profile.save!
    end
  end

  alias_method :destroy!, :destroy
  def destroy
    node.remove_consumer consumer
    if node.dummy?
      node.profile.destroy
      node.destroy
    end
    super
  end

  protected

  after_create :complete
  def complete
    return if self?
    consumer.profile.admins.each{ |a| node.profile.add_admin(a) } if node.dummy?
    node.add_consumer consumer
  end

  #delegate to node
  def method_missing(method, *args, &block)
    if self.respond_to? method
      send(method, *args, &block)
    else
      node.send(method, *args, &block)
    end
  end

end
