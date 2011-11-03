module DistributionPlugin::DistributionDisplayHelper

  include ActionView::Helpers::JavaScriptHelper #we want the original button_to_function!

  def labelled_field(form, field, label, field_html, options = {})
    content_tag('div', (form ? form.label(field, label) : label_tag(field, label)) +
                content_tag('div', field_html, :class => 'field-box') +
                content_tag('div', '', :style => 'clear: both'),
                options.merge(:class => options[:class].to_s + ' field'))
  end

  def labelled_period_field(form, start_field, end_field, label, options = {})
    labelled_field(form, label.to_sym, label, form.text_field(start_field.to_s+'_date', :class => 'date-select') +
                   form.text_field(start_field.to_s+'_time', :class => 'time-select') +
                   content_tag('span', _('to') + ' ', :class => "date-to") +
                   form.text_field(end_field.to_s+'_date', :class => 'date-select') +
                   form.text_field(end_field.to_s+'_time', :class => 'time-select'))
  end

  def datetime_period(start, finish)
    start.to_time.strftime(_("%m/%d/%y at %Hh%M")) + ' ' + _('to') + ' ' + finish.to_time.strftime(_("%m/%d/%y at %Hh%M"))
  end

  def datetime_period_with_day(start, finish)
    _("%{start_day}, %{start_datetime} - %{finish_day}, %{finish_datetime}") % {
      :start_day => @session.start.strftime(_('%A')),
      :start_datetime => @session.start.strftime(_('%m/%d %Hh%M')),
      :finish_day => @session.finish.strftime(_('%A')),
      :finish_datetime => @session.finish.strftime(_('%m/%d %Hh%M')),
    }
  end

  def month_with_time(time)
    time.strftime(_('%m/%y - %Hh%M'))
  end

  def edit_arrow(anchor, toggle = true, options = {})
    options[:class] ||= ''
    options[:onclick] ||= ''
    options[:class] += ' actions-circle'
    options[:onclick] = "r = distribution_edit_arrow_toggle(this); #{options[:onclick]}; return r;" if toggle

    link_to content_tag('div', '', :class => 'actions-arrow'), anchor, options
  end

  def price_with_unit_span(price, unit)
    _("%{price}%{unit}") % {:price => price_span(price), :unit => content_tag('span', _('/') + unit.singular, :class => 'price-unit')}
  end

  # come on, you can't replace a rails api method!
  def submit_to_function(name, function, html_options={})
    content_tag 'input', '', html_options.merge(:onclick => function, :type => 'submit', :value => name)
  end

end
