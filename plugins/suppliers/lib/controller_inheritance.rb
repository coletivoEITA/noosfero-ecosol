module ControllerInheritance

  class ActionView < ActionView::Base

    private

    def _pick_partial_template_with_template_super partial_path
      if partial_path.include? '/'
        _pick_partial_template_without_template_super partial_path
      elsif controller
        begin
          path = "#{controller.class.controller_path}/_#{partial_path}"
          self.view_paths.find_template path, self.template_format
        rescue
          path = "#{controller.class.superclass.controller_path}/_#{partial_path}"
          self.view_paths.find_template path, self.template_format
        end
      else
        _pick_partial_template_without_template_super partial_path
      end
    end
    alias_method_chain :_pick_partial_template, :template_super

  end

  def self.included base

    base.send :define_method, :default_template_with_super do |*args|
      begin
        default_template_without_super *args
      rescue ::ActionView::MissingTemplate => e
        self.view_paths.find_template "#{self.class.superclass.controller_path}/#{action_name}", default_template_format
      end
    end
    base.alias_method_chain :default_template, :super

    base.send :define_method, :initialize_template_class do |response|
      response.template = ControllerInheritance::ActionView.new self.class.view_paths, {}, self
      response.template.helpers.send :include, self.class.master_helper_module
      response.redirected_to = nil
      @performed_render = @performed_redirect = false
    end

  end

end
