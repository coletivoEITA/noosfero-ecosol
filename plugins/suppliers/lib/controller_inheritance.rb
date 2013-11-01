module ControllerInheritance

  class ActionView < ActionView::Base

    private

    def _pick_partial_template_with_template_super partial_path
      if partial_path.include? '/'
        _pick_partial_template_without_template_super partial_path
      elsif controller
        controller.send :each_template_with_inherit do |klass|
          begin
            path = "#{klass.controller_path}/_#{partial_path}"
            self.view_paths.find_template path, self.template_format
          rescue ::ActionView::MissingTemplate
            raise "Can't find '#{partial_path}' in any #{controller.class}'s parent" unless (klass.inherit_templates rescue nil)
          end
        end
      else
        _pick_partial_template_without_template_super partial_path
      end
    end
    alias_method_chain :_pick_partial_template, :template_super

  end

  module ClassMethods

    protected

    def replace_url_for *controllers
      self.send :define_method, :url_for do |options|
        controllers.each do |klass|
          options[:controller] = self.controller_path if options[:controller].to_s == klass.controller_path
        end
        super options
      end
    end

  end

  module InstanceMethods

    protected

    def each_template_with_inherit &block
      klass = self.class
      ret = nil
      loop do
        ret = yield klass
        break if ret
        klass = klass.superclass
      end
      ret
    end

  end

  def self.included base
    base.extend ClassMethods
    base.send :include, InstanceMethods

    base.cattr_accessor :inherit_templates
    base.inherit_templates = true

    base.send :define_method, :default_template do |*args|
      self.each_template_with_inherit do |klass|
        begin
          self.view_paths.find_template "#{klass.controller_path}/#{action_name}", default_template_format
        rescue ::ActionView::MissingTemplate => e
          # raise the same exception as rails will rescue it
          raise e unless (klass.inherit_templates rescue nil)
        end
      end
    end

    base.send :define_method, :initialize_template_class do |response|
      response.template = ControllerInheritance::ActionView.new self.class.view_paths, {}, self
      response.template.helpers.send :include, self.class.master_helper_module
      response.redirected_to = nil
      @performed_render = @performed_redirect = false
    end
  end
end
