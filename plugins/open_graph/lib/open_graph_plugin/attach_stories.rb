require_dependency 'open_graph_plugin/stories'

# DEPRECATED: all hooks are directly attached to ProfileActivity
module OpenGraphPlugin::AttachStories

  module ClassMethods

    def open_graph_attach_stories
      klass = self.name
      callbacks = OpenGraphPlugin::Stories::ModelStories[klass.to_sym]
      return if callbacks.blank?

      callbacks.each do |on, stories|
        # subclasses may overide this, but the callback is called only once
        method = "open_graph_after_#{on}"

        if Rails.env.development?
          # on development, crash on errors
          self.send "after_#{on}", method
        else
          self.send "after_commit", method, on: on
        end

        self.send :define_method, method do
          OpenGraphPlugin::Stories.publish self, stories
        end
      end
    end

  end

  module InstanceMethods

  end

end
