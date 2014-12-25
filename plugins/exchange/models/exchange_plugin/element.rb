class ExchangePlugin::Element < ActiveRecord::Base

  attr_accessible *self.column_names
  attr_accessible :proposal, :object, :object_np
  attr_accessible :object_attributes

  belongs_to :proposal, class_name: "ExchangePlugin::Proposal"
  has_one :exchange, through: :proposal

  belongs_to :object, polymorphic: true
  accepts_nested_attributes_for :object

  # np: non polymorphic version
  belongs_to :object_np, foreign_key: :object_id
  def object_np
    raise 'Dont use me'
  end

  validates_presence_of :proposal

  def build_object *args
    if self.object
      self.object
    else
      self.object_type.constantize.new *args
    end
  end

  # WORKAROUND bug in accepts_nested_attributes_for
  def object_attributes= attributes
    self.object.attributes = attributes
  end

  protected

end
