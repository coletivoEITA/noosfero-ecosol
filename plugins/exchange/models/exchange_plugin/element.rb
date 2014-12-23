class ExchangePlugin::Element < ActiveRecord::Base

  attr_accessible *self.column_names

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

  protected

  def build_object *args
    if self.object
      self.object
    else
      self.object_type.constantize.new *args
    end
  end

end
