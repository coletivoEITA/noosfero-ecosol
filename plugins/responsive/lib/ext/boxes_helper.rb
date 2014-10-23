require_dependency 'boxes_helper'
require_relative 'application_helper'

module BoxesHelper

  extend ActiveSupport::Concern
  protected

  module ResponsiveMethods
    def insert_boxes(content)
      return super unless theme_responsive?

      if controller.send(:boxes_editor?) && controller.send(:uses_design_blocks?)
        content + display_boxes_editor(controller.boxes_holder)
      else
        maybe_display_custom_element(controller.boxes_holder, :custom_header_expanded, id: 'profile-header') +
          if controller.send(:uses_design_blocks?)
            display_boxes(controller.boxes_holder, content)
        else
          content_tag(:div,
                      content_tag('div',
                                  content_tag('div',
                                              content_tag('div', wrap_main_content(content), class: 'no-boxes-inner-2'),
                                              class: 'no-boxes-inner-1'
                                             ),
                                             class: 'no-boxes col-lg-12 col-md-12 col-sm-12'
                                 ),
                                 class: 'row',
                                 id: 'content')
        end +
        maybe_display_custom_element(controller.boxes_holder, :custom_footer_expanded, id: 'profile-footer')
      end
    end

    def display_boxes(holder, main_content)
      return super unless theme_responsive?

      boxes = holder.boxes.with_position.order('boxes.position ASC').first(holder.boxes_limit)

      template = profile.nil? ? environment.layout_template : profile.layout_template
      template = 'default' if template.blank?

      render partial: "templates/boxes_#{template}", locals: {boxes: boxes, main_content: main_content}, use_cache: use_cache?
    end
  end

  include ResponsiveChecks
  extend ActiveSupport::Concern
  included do
    include ResponsiveMethods
  end

end

module ApplicationHelper

  include BoxesHelper::ResponsiveMethods

end

