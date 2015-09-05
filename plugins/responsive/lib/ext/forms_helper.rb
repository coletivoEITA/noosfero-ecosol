require_dependency 'forms_helper'

module FormsHelper

  protected

  module ResponsiveMethods

    # add -inline class
    def labelled_radio_button human_name, name, value, checked = false, options = {}
      return super unless theme_responsive?

      options[:id] ||= 'radio-' + FormsHelper.next_id_number
      content_tag( 'label', radio_button_tag( name, value, checked, options ) + '  ' +
 human_name, for: options[:id], class: 'radio-inline' )
    end

    # add -inline class
    def labelled_check_box human_name, name, value = "1", checked = false, options = {}
      return super unless theme_responsive?

      options[:id] ||= 'checkbox-' + FormsHelper.next_id_number
      hidden_field_tag(name, '0') +
        content_tag( 'label', check_box_tag( name, value, checked, options ) + '  ' + human_name, for: options[:id], class: 'checkbox-inline')
    end

    def submit_button type, label, html_options = {}
      return super unless theme_responsive?

      html_options[:class] = [html_options[:class], 'submit'].compact.join(' ')

      option = html_options.delete(:option) || 'default'
      size = html_options.delete(:size) || 'default'
      the_class = "with-text btn btn-#{size} btn-#{option} icon-#{type}"
      the_class << ' ' << html_options[:class] if html_options.has_key?(:class)

      bt_cancel = html_options[:cancel] ? button(:cancel, _('Cancel'), html_options[:cancel]) : ''
      html_options.delete :cancel

      bt_submit = button_tag(label, html_options.merge(class: the_class))
      bt_submit + bt_cancel
    end

    def responsive_add_field_class! options
      if options['class']
        options['class'] = "#{options['class']} form-control"
      else
        options[:class] = "#{options[:class]} form-control"
      end
    end

    %w[
      select_tag
      text_field_tag text_area_tag
      number_field_tag password_field_tag url_field_tag email_field_tag
      month_field_tag date_field_tag
    ].each do |method|
      define_method method do |name, value=nil, options={}, &block|
        #return super(*args, &block) unless theme_responsive?

        responsive_add_field_class! options
        super name, value, options, &block
      end
    end
    %w[select_month select_year].each do |method|
      define_method method do |date, options={}, html_options={}|
        responsive_add_field_class! html_options
        super date, options, html_options
      end
    end

  end

  include ResponsiveChecks
  if RUBY_VERSION >= '2.0.0'
    prepend ResponsiveMethods
  else
    extend ActiveSupport::Concern
    included { include ResponsiveMethods }
  end

end

