module DistributionPlugin::DistributionDisplayHelper

  def labelled_field(form, field, label, field_html, options = {})
    content_tag('div', form.label(field, label) +
                content_tag('div', field_html, :class => 'field-box') +
                content_tag('div', '', :style => 'clear: both'),
                options.merge(:class => options[:class].to_s + ' field'))
  end

  def labelled_period_field(form, start_field, end_field, label, options = {})
    labelled_field(form, label.to_sym, label, form.text_field(start_field.to_s+'_date', :class => 'distribution-plugin-date-select') +
                   form.text_field(start_field.to_s+'_time', :class => 'distribution-plugin-time-select') +
                   content_tag('span', _('to'), :class => "distribution-plugin-date-to") +
                   form.text_field(end_field.to_s+'_date', :class => 'distribution-plugin-date-select') +
                   form.text_field(end_field.to_s+'_time', :class => 'distribution-plugin-time-select'))
  end

end
