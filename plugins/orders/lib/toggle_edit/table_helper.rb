module ToggleEdit

  module TableHelper

    def edit_arrow anchor, toggle = true, options = {}
      options[:class] ||= ''
      options[:onclick] ||= ''
      options[:class] += ' actions-circle'
      options['toggle-edit'] = ''
      options[:onclick] = "r = sortable_table.edit_arrow_toggle(this); #{options[:onclick]}; return r;" if toggle

      content_tag 'div',
        link_to(content_tag('div', '', :class => 'action-hide') + content_tag('div', '', :class => 'action-show'), anchor, options),
        :class => 'box-field actions'
    end

  end

end
