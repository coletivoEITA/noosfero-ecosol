require_dependency 'open_graph_plugin/stories'

module OpenGraphPlugin::AttachStories

  module ClassMethods

    def open_graph_attach_stories
      events = OpenGraphPlugin::Stories::Spec[self.name.to_sym]
      return if events.blank?
      events.each do |on, handler|
        # subclasses may overide this, but the callback is called only once
        method = "open_graph_after_#{on}"

        send "after_#{on}", method
        define_method method do |record|
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
