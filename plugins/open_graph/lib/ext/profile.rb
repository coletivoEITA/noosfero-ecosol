require_dependency 'profile'

# STI workaround
Profile.subclasses.each do |subclass|
  subclass.class_eval do
    OpenGraphPlugin::Track::Config.each do |track, klass|
      attributes = "open_graph_#{track}_tracks_attributes"
      profile_ids = "open_graph_#{track}_profiles_ids"

      attr_accessible attributes
      attr_accessible profile_ids
    end
  end
end

class Profile

  has_many :open_graph_activities, class_name: 'OpenGraphPlugin::Activity', source: :tracker_id

  has_many :open_graph_tracks, class_name: 'OpenGraphPlugin::Track', source: :tracker_id

  OpenGraphPlugin::Track::Config.each do |track, klass|
    association = "open_graph_#{track}_tracks".to_sym
    attributes = "open_graph_#{track}_tracks_attributes"
    profile_ids = "open_graph_#{track}_profiles_ids"
    klass = "OpenGraphPlugin::#{klass}"

    attr_accessible attributes
    attr_accessible profile_ids
    has_many association, class_name: klass, foreign_key: :tracker_id
    accepts_nested_attributes_for association, allow_destroy: true, reject_if: :open_graph_reject_empty_object_type

    define_method "#{profile_ids}=" do |ids|
      self.send(association).destroy_all
      ids.split(',').each do |id|
        self.send(association).build type: klass, object_data_id: id, object_data_type: 'Profile'
      end
      #attrs = ids.split(',').map{ |id| {object_data_id: id, object_data_type: 'Profile'} }
      #self.send "#{attributes}=", attrs
    end

  end

  define_method "open_graph_reject_empty_object_type" do |attributes|
    exists = attributes[:id].present?
    empty = attributes[:object_type].empty?
    attributes.merge! _destroy: 1 if exists and empty
    return (!exists and empty)
  end
end
