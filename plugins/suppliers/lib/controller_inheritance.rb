module ControllerInheritance

  module ClassMethods

    def hmvc context
      cattr_accessor :hmvc_paths
      class_attribute :inherit_templates
      class_attribute :hmvc_inheritable
      class_attribute :hmvc_context

      #self.before_filter :set_hmvc_context

      self.inherit_templates = true
      self.hmvc_inheritable = true
      self.hmvc_context = context
      self.hmvc_paths ||= {}
      self.hmvc_paths[self.hmvc_context] ||= {} if self.hmvc_context

      # initialize other context's controllers paths
      #controllers = [self] + context.controllers.map{ |controller| controller.constantize }

      #controllers.each do |klass|
      #  context_klass = klass
      #  while ((klass = klass.superclass).hmvc_inheritable rescue false)
      #    self.hmvc_paths[self.hmvc_context][klass.controller_path] = context_klass.controller_path
      #  end
      #end

      #include InstanceMethods
    end

    def hmvc_controller_path hmvc_context = self.hmvc_context
      self.hmvc_paths[hmvc_context][self.controller_path] || self.controller_path
    end

    protected

  end

end
