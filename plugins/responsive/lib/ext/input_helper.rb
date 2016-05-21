require_dependency 'application_helper'

module InputHelper

  protected

  def input_group_addon addon, options = {}, &block
    content_tag :div, class: 'input-group' do
      [
        content_tag(:span, addon, class: 'input-group-addon'),
        capture(&block),
      ].safe_join
    end
  end

end

ApplicationHelper.include InputHelper

