# monkey patch to fix Rails bug
# this was solved in rails 3.x, then remove this patch when upgrade to it
#
# https://github.com/rails/rails/commit/fb0bd8c1092db51888ec4bb72af6c595e13c31fa
require 'action_view/helpers/form_helper'

ActionView::Helpers::InstanceTag.class_eval do
  class << self
    def value_before_type_cast(object, method_name)
      unless object.nil?
        object.respond_to?(method_name) ?
          object.send(method_name) :
          object.send(method_name + "_before_type_cast")
      end
    end
  end
end
