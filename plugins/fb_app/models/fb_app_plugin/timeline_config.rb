class FbAppPlugin::TimelineConfig < Noosfero::Plugin::ActiveRecord

  belongs_to :profile

  validates_presence_of :profile

  acts_as_having_settings field: :config

end
