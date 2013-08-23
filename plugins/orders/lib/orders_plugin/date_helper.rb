module OrdersPlugin::DateHelper

  protected

  include OrdersPlugin::FieldHelper

  def labelled_period_field form, start_field, end_field, label, options = {}
    labelled_field form, label.to_sym, label, form.text_field("#{start_field}_date", :class => 'date-select') +
                   form.text_field("#{start_field}_time", :class => 'time-select') +
                   content_tag('span', I18n.t('orders_plugin.lib.date_helper.to') + ' ', :class => "date-to") +
                   form.text_field("#{end_field}_date", :class => 'date-select') +
                   form.text_field("#{end_field}_time", :class => 'time-select')
  end

  def datetime_period start, finish
    I18n.t('orders_plugin.lib.date_helper.start_to_finish') % {
     :start => start.to_time.strftime(I18n.t('orders_plugin.lib.date_helper.m_d_y_at_hh_m')),
     :finish => finish.to_time.strftime(I18n.t('orders_plugin.lib.date_helper.m_d_y_at_hh_m')),
    }
  end

  def datetime_period_with_from start, finish
    I18n.t('orders_plugin.lib.date_helper.from_start_to_finish') % {
     :start => start.to_time.strftime(I18n.t('orders_plugin.lib.date_helper.m_d_y_hh_m')),
     :finish => finish.to_time.strftime(I18n.t('orders_plugin.lib.date_helper.m_d_y_hh_m')),
    }
  end

  def date_period start, finish
    I18n.t('orders_plugin.lib.date_helper.start_finish') % {
     :start => start.to_time.strftime(I18n.t('orders_plugin.lib.date_helper.m_d')),
     :finish => finish.to_time.strftime(I18n.t('orders_plugin.lib.date_helper.m_d')),
    }
  end

  def day_time time
    time.strftime I18n.t('orders_plugin.lib.date_helper.b_d_at_hh_m')
  end

  def day_time_period start, finish
    start.strftime(I18n.t('orders_plugin.lib.date_helper.b_d_from_time_start_t') % {
      :time_start => start.strftime(I18n.t('orders_plugin.lib.date_helper.hh_m')), :time_finish => finish.strftime(I18n.t('orders_plugin.lib.date_helper.hh_m'))
    })
  end

  def day_time_short time
    time.strftime time.min > 0 ? I18n.t('orders_plugin.lib.date_helper.m_d_hh_m') : I18n.t('orders_plugin.lib.date_helper.m_d_hh')
  end

  def datetime_period_with_day start, finish
    (start.to_date == finish.to_date ?
      I18n.t('orders_plugin.lib.date_helper.start_day_from_start_') :
      I18n.t('orders_plugin.lib.date_helper.start_day_start_datet')
    ) % {
      :start_day => start.strftime(I18n.t('orders_plugin.lib.date_helper.a')),
      :start_datetime => start.strftime(I18n.t('orders_plugin.lib.date_helper.m_d_hh_m')),
      :start_time => start.strftime(I18n.t('orders_plugin.lib.date_helper.hh_m')),
      :finish_day => finish.strftime(I18n.t('orders_plugin.lib.date_helper.a')),
      :finish_datetime => finish.strftime(I18n.t('orders_plugin.lib.date_helper.m_d_hh_m')),
      :finish_time => finish.strftime(I18n.t('orders_plugin.lib.date_helper.hh_m')),
    }
  end

  def datetime_period_short start, finish
    I18n.t('orders_plugin.lib.date_helper.start_finish') % {
      :start => day_time_short(start),
      :finish => day_time_short(finish)
    }
  end

  def month_with_time time
    time.strftime(I18n.t('orders_plugin.lib.date_helper.m_y_hh_m'))
  end

end
