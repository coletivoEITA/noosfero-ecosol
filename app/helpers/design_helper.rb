module DesignHelper

  def self.included base
    base.send :extend, ClassMethods
    base.send :include, InstanceMethods
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

    protected

    def uses_design_blocks?
      !@no_design_blocks && self.class.uses_design_blocks?
    end

  end

end
