#from http://apidock.com/rails/ActionView/Helpers/PrototypeHelper/JavaScriptGenerator/GeneratorMethods/replace_html
module ActionView
  module Helpers
    module PrototypeHelper
      class JavaScriptGenerator #:nodoc:
        module GeneratorMethods
          def replace_html_if_exists(id, *options_for_render)
            call "if($('#{id}')) Element.update", id, render(*options_for_render)
          end
        end
      end
    end
  end
end
