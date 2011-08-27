module DistributionPlugin::SessionHelper
  def timeline_class(session, status, selected)
    klass = ""
    klass += " distribution-plugin-session-timeline-passed-item" if session.passed_by?(status)
    klass += " distribution-plugin-session-timeline-current-item" if session.status == status
    klass += " distribution-plugin-session-timeline-selected-item" if selected == status
    klass
  end

  def labelled_field(form, field, label, field_html, options = {})
    content_tag('div', form.label(:field, label) +
                content_tag('div', field_html, :class => 'session-field-box') +
                content_tag('div', '', :style => 'clear: both'),
                options.merge(:class => options[:class].to_s + ' session-field'))
  end

  def labelled_period_field(form, start_field, end_field, label, options = {})
    labelled_field(form, label.to_sym, label, form.text_field(start_field.to_s+'_date', :class => 'distribution-plugin-date-select') +
                   form.text_field(start_field.to_s+'_time', :class => 'distribution-plugin-time-select') +
                   content_tag('span', _('to'), :class => "distribution-plugin-date-to") +
                   form.text_field(end_field.to_s+'_date', :class => 'distribution-plugin-date-select') +
                   form.text_field(end_field.to_s+'_time', :class => 'distribution-plugin-time-select'))
  end

end
