
module Noosfero
  class Plugin
    module HotSpot
      module Dispatchers

        def plugins_extra_blocks params = {}
          specs = plugins.dispatch :extra_blocks
          blocks = specs.flat_map do |spec|
            spec.map do |block, options|
              type = options[:type]
              type = type.is_a?(Array) ? type : [type].compact
              type = type.map do |x|
                x.is_a?(String) ? x.capitalize.constantize : x
              end
              raise "This is not a valid type" if !type.empty? && ![Person, Community, Enterprise, Environment].detect{|m| type.include?(m)}

              position = options[:position]
              position = position.is_a?(Array) ? position : [position].compact
              position = position.map{|p| p.to_i}
              raise "This is not a valid position" if !position.empty? && ![1,2,3].detect{|m| position.include?(m)}

              if !type.empty? && (params[:type] != :all)
                block = type.include?(params[:type]) ? block : nil
              end

              if !position.empty? && !params[:position].nil?
                block = position.detect{ |p| [params[:position]].flatten.include?(p)} ? block : nil
              end

              block
            end
          end
          blocks.compact!
          blocks
        end

        def plugins_macros
          plugins.flat_map do |plugin|
            plugin.class.constants.map do |constant_name|
              plugin.class.const_get constant_name
            end.select {|const| const.is_a?(Class) && const < Noosfero::Plugin::Macro}
          end
        end

      end
    end
  end
end
