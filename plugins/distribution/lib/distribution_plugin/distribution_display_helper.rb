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

  def labelled_radio(form, field, label, value, options = {})
    content_tag('div', 
                form.radio_button(:role, value) +
                form.label("#{field}_#{value}", label) +
                content_tag('div', '', :class => 'cleaner'),
                options.merge(:class => options[:class].to_s + ' field-radio'))
  end

  def labelled_period_field(form, start_field, end_field, label, options = {})
    labelled_field(form, label.to_sym, label, form.text_field(start_field.to_s+'_date', :class => 'date-select') +
                   form.text_field(start_field.to_s+'_time', :class => 'time-select') +
                   content_tag('span', _('to') + ' ', :class => "date-to") +
                   form.text_field(end_field.to_s+'_date', :class => 'date-select') +
                   form.text_field(end_field.to_s+'_time', :class => 'time-select'))
  end

  def datetime_period(start, finish)
    _('%{start} to %{finish}') % {
     :start => start.to_time.strftime(_("%m/%d/%y at %Hh%M")),
     :finish => finish.to_time.strftime(_("%m/%d/%y at %Hh%M")),
    }
  end

  def date_period(start, finish)
    _('%{start} - %{finish}') % {
     :start => start.to_time.strftime(_("%m/%d")),
     :finish => finish.to_time.strftime(_("%m/%d")),
    }
  end

  def day_time(time)
    time.strftime _('%B %d, at %Hh%M')
  end

  def day_time_period(start, finish)
    start.strftime(_('%B %d, from %{time_start} to %{time_finish}') % {
      :time_start => start.strftime(_('%Hh%M')), :time_finish => finish.strftime(_('%Hh%M'))
    })
  end

  def day_time_short(time)
    time.strftime time.min > 0 ? _('%-m/%-d %Hh%M') : _('%-m/%-d %Hh')
  end

  def datetime_period_with_day(start, finish)
    (start.to_date == finish.to_date ?
      _("%{start_day}, from %{start_time} to %{finish_time}") :
      _("%{start_day}, %{start_datetime} - %{finish_day}, %{finish_datetime}")
    ) % {
      :start_day => start.strftime(_('%A')),
      :start_datetime => start.strftime(_('%m/%d %Hh%M')),
      :start_time => start.strftime(_('%Hh%M')),
      :finish_day => finish.strftime(_('%A')),
      :finish_datetime => finish.strftime(_('%m/%d %Hh%M')),
      :finish_time => finish.strftime(_('%Hh%M')),
    }
  end

  def datetime_period_short(start, finish)
    _("%{start} - %{finish}") % {
      :start => day_time_short(start),
      :finish => day_time_short(finish)
    }
  end

  def month_with_time(time)
    time.strftime(_('%m/%y - %Hh%M'))
  end

  def edit_arrow(anchor, toggle = true, options = {})
    options[:class] ||= ''
    options[:onclick] ||= ''
    options[:class] += ' actions-circle toggle-edit'
    options[:onclick] = "r = distribution_edit_arrow_toggle(this); #{options[:onclick]}; return r;" if toggle

    link_to content_tag('div', '', :class => 'actions-arrow'), anchor, options
  end

  def price_span(price, options = {})
    return nil if price.blank?
    content_tag 'span',
      content_tag('span', environment.currency_unit, :class => 'price-currency-unit') +
      content_tag('span', number_to_currency(price, :unit => '', :delimiter => environment.currency_delimiter, :separator => environment.currency_separator), :class => 'price-value'),
      options
  end

  def price_with_unit_span(price, unit)
    return nil if price.blank?
    _("%{price}%{unit}") % {:price => price_span(price), :unit => content_tag('span', _('/') + unit.singular, :class => 'price-unit')}
  end

  def excerpt_ending(text, length)
    return nil if text.blank?
    excerpt text, text.first(3), length
  end

  # come on, you can't replace a rails api method (button_to_function was)!
  def submit_to_function(name, function, html_options={})
    content_tag 'input', '', html_options.merge(:onclick => function, :type => 'submit', :value => name)
  end

end
