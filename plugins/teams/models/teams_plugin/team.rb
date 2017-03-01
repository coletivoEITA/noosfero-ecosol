class TeamsPlugin::Team < ActiveRecord::Base

  attr_accessible :context, :name

  belongs_to :context, polymorphic: true

  has_many :members, class_name: 'TeamsPlugin::Member', dependent: :destroy
  has_many :profiles, through: :members

  has_many :works, class_name: 'TeamsPlugin::Work'

  validates_presence_of :context

  scope :by_context, -> context {
    where(context_id: context.id, context_type: context.class.base_class.name)
  }

  extend CodeNumbering::ClassMethods
  code_numbering :code, scope: -> { self.context.teams }

  # must come after code_numbering
  before_create :fill_name

  def destroy
    raise "Can't delete as there is associated works" if self.works.present?
    super
  end

  protected

  def fill_name
    self[:name] ||= I18n.t'teams_plugin.models.team.default_name', code: self.code
  end

end
