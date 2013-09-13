module ControllerInheritance

  def self.included base

    base.send :define_method, :default_template_with_super do |*args|
      begin
        default_template_without_super *args
      rescue ActionView::MissingTemplate => e
        self.view_paths.find_template("#{self.class.superclass.controller_path}/#{action_name}", default_template_format)
      end
    end
    base.alias_method_chain :default_template, :super

  end

end
