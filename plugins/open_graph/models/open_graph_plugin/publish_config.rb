class OpenGraphPlugin::PublishConfig < ActiveRecord::Base

  Syncs = OpenGraphPlugin::Syncs::Spec

  belongs_to :profile

  validates_presence_of :profile

  acts_as_having_settings field: :config
  Syncs.each do |group, data|
    attr_accessible "synced_#{group}"
    settings_items "synced_#{group}", type: Hash, default: Syncs[group]
  end

end
