require_dependency 'fb_app_plugin/open_graph'

module FbAppPlugin::AttachStories

  module ClassMethods

    AllSubclassProc = proc do |klass|
      subclasses = klass.subclasses
      subclasses += subclasses.map{ |k| AllSubclassProc.call k }.flatten
      subclasses
    end

    def fb_app_attach_stories
      events = FbAppPlugin::OpenGraph::Stories[self.name.to_sym]
      return if events.blank?
      events.each do |on, handler|
        self.send "after_#{on}" do |record|
          # this time we have all plugins loaded, can't do it before
          all_subclasses = AllSubclassProc.call self
          # STI check
          break if all_subclasses.any?{ |k| FbAppPlugin::OpenGraph::Stories[k.name.to_sym][on] }

          actor = User.current.person rescue nil
          # TODO: do via delayed_job
          handler.call record, actor if actor
        end
      end
    end

  end

  module InstanceMethods

  end

end
