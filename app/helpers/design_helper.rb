module DesignHelper

  extend ActiveSupport::Concern

  included do
    next unless self.is_a? ActionController::Base
    extend ClassMethods
    include InstanceMethods
    before_filter :load_custom_design
  end

  module ClassMethods

    def no_design_blocks
      @no_design_blocks = true
    end

    def use_custom_design options = {}
      @custom_design = options
    end

    def custom_design
      @custom_design ||= {}
    end

    def uses_design_blocks?
      !@no_design_blocks
    end

  end

  module InstanceMethods

    def custom_design
      self.class.custom_design
    end

    protected

    def uses_design_blocks?
      !@no_design_blocks && self.class.uses_design_blocks?
    end

    def load_custom_design
      @layout_template = self.class.custom_design[:layout_template]
    end

  end

end
