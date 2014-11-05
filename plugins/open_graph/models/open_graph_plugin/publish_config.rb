class OpenGraphPlugin::PublishConfig < ActiveRecord::Base

  Syncs = {
    my_activities: {
      objects: {
        blog_post: 'true',
        friendship: 'true',
        gallery_image: 'true',
        uploaded_file: 'true',
      },
    },
    my_enterprises: {
      objects: [
        products: 'true',
      ],
      profiles: [],
    },
    my_friends: {
      objects: [
      ],
      profiles: [],
    },
    my_communities: {
      objects: [
      ],
      profiles: [],
    },
  }

  belongs_to :profile

  validates_presence_of :profile

  acts_as_having_settings field: :config
  Syncs.each do |group, data|
    attr_accessible group
    settings_items group, type: HashWithIndifferentAccess, default: Syncs[group]
  end

end
