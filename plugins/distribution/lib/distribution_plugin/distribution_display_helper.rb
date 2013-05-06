module DistributionPlugin::DistributionDisplayHelper

  include ActionView::Helpers::JavaScriptHelper # we want the original button_to_function!

  def labelled_field(form, field, label, field_html, options = {})
    help = options.delete(:help)
    content_tag('div', (form ? form.label(field, label) : label_tag(field, label)) +
                content_tag('div', help, :class => 'field-help') +
                content_tag('div', field_html, :class => 'field-box') +
                content_tag('div', '', :style => 'clear: both'),
                options.merge(:class => options[:class].to_s + ' field'))
  end

  def labelled_radio(form, field, label_text, value, options = {})
    content_tag('div',
                form.radio_button(field, value) +
                form.label("#{field}_#{value}", label_text) +
                content_tag('div', '', :class => 'cleaner'),
                options.merge(:class => options[:class].to_s + ' field-radio'))
  end

  def labelled_period_field(form, start_field, end_field, label, options = {})
    labelled_field(form, label.to_sym, label, form.text_field(start_field.to_s+'_date', :class => 'date-select') +
                   form.text_field(start_field.to_s+'_time', :class => 'time-select') +
                   content_tag('span', I18n.t('distribution_plugin.lib.distribution_display_helper.to') + ' ', :class => "date-to") +
                   form.text_field(end_field.to_s+'_date', :class => 'date-select') +
                   form.text_field(end_field.to_s+'_time', :class => 'time-select'))
  end

  def datetime_period(start, finish)
    I18n.t('distribution_plugin.lib.distribution_display_helper.start_to_finish') % {
     :start => start.to_time.strftime(I18n.t('distribution_plugin.lib.distribution_display_helper.m_d_y_at_hh_m')),
     :finish => finish.to_time.strftime(I18n.t('distribution_plugin.lib.distribution_display_helper.m_d_y_at_hh_m')),
    }
  end

  def datetime_period_with_from(start, finish)
    I18n.t('distribution_plugin.lib.distribution_display_helper.from_start_to_finish') % {
     :start => start.to_time.strftime(I18n.t('distribution_plugin.lib.distribution_display_helper.m_d_y_hh_m')),
     :finish => finish.to_time.strftime(I18n.t('distribution_plugin.lib.distribution_display_helper.m_d_y_hh_m')),
    }
  end

  def date_period(start, finish)
    I18n.t('distribution_plugin.lib.distribution_display_helper.start_finish') % {
     :start => start.to_time.strftime(I18n.t('distribution_plugin.lib.distribution_display_helper.m_d')),
     :finish => finish.to_time.strftime(I18n.t('distribution_plugin.lib.distribution_display_helper.m_d')),
    }
  end

  def day_time(time)
    time.strftime I18n.t('distribution_plugin.lib.distribution_display_helper.b_d_at_hh_m')
  end

  def day_time_period(start, finish)
    start.strftime(I18n.t('distribution_plugin.lib.distribution_display_helper.b_d_from_time_start_t') % {
      :time_start => start.strftime(I18n.t('distribution_plugin.lib.distribution_display_helper.hh_m')), :time_finish => finish.strftime(I18n.t('distribution_plugin.lib.distribution_display_helper.hh_m'))
    })
  end

  def day_time_short(time)
    time.strftime time.min > 0 ? I18n.t('distribution_plugin.lib.distribution_display_helper.m_d_hh_m') : I18n.t('distribution_plugin.lib.distribution_display_helper.m_d_hh')
  end

  def datetime_period_with_day(start, finish)
    (start.to_date == finish.to_date ?
      I18n.t('distribution_plugin.lib.distribution_display_helper.start_day_from_start_') :
      I18n.t('distribution_plugin.lib.distribution_display_helper.start_day_start_datet')
    ) % {
      :start_day => start.strftime(I18n.t('distribution_plugin.lib.distribution_display_helper.a')),
      :start_datetime => start.strftime(I18n.t('distribution_plugin.lib.distribution_display_helper.m_d_hh_m')),
      :start_time => start.strftime(I18n.t('distribution_plugin.lib.distribution_display_helper.hh_m')),
      :finish_day => finish.strftime(I18n.t('distribution_plugin.lib.distribution_display_helper.a')),
      :finish_datetime => finish.strftime(I18n.t('distribution_plugin.lib.distribution_display_helper.m_d_hh_m')),
      :finish_time => finish.strftime(I18n.t('distribution_plugin.lib.distribution_display_helper.hh_m')),
    }
  end

  def datetime_period_short(start, finish)
    I18n.t('distribution_plugin.lib.distribution_display_helper.start_finish') % {
      :start => day_time_short(start),
      :finish => day_time_short(finish)
    }
  end

  def month_with_time(time)
    time.strftime(I18n.t('distribution_plugin.lib.distribution_display_helper.m_y_hh_m'))
  end

  def edit_arrow(anchor, toggle = true, options = {})
    options[:class] ||= ''
    options[:onclick] ||= ''
    options[:class] += ' actions-circle toggle-edit'
    options[:onclick] = "r = distribution.edit_arrow_toggle(this); #{options[:onclick]}; return r;" if toggle

    link_to content_tag('div', '', :class => 'actions-arrow'), anchor, options
  end

  def price_span(price, options = {})
    return nil if price.blank?
    content_tag 'span',
      content_tag('span', price, :class => 'price-value'),
      options
  end

  def price_with_unit_span(price, unit, detail=nil)
    return nil if price.blank?
    detail ||= ''
    detail = " (#{detail})" unless detail.blank?
    I18n.t('distribution_plugin.lib.distribution_display_helper.price_unit') % {:price => price_span(price), :unit => content_tag('span', I18n.t('distribution_plugin.lib.distribution_display_helper./') + unit.singular + detail, :class => 'price-unit')}
  end

  def excerpt_ending(text, length)
    return nil if text.blank?
    excerpt text, text.first(3), length
  end

  # come on, you can't replace a rails api method (button_to_function was)!
  def submit_to_function(name, function, html_options={})
    content_tag 'input', '', html_options.merge(:onclick => function, :type => 'submit', :value => name)
  end

  include ColorboxHelper

  def colorbox_link_to label, url, options = {}
    link_to label, url, colorbox_options(options)
  end

  def colorbox_close_link text, options = {}
    link_to text, '#', colorbox_options(options, :close)
  end


end
