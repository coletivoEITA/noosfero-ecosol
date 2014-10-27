volunteers = {

  periods: {
    load: function() {
      jQuery('#volunteers-periods .period').each(function() {
        volunteers.periods.applyCalendrial(this)
      })
      jQuery('#period-new input').prop('disabled', true)
    },

    new: function() {
      var period = jQuery('#volunteers-periods-template').html()
      period = period.replace(/_new_/g, new Date().getTime())
      period = jQuery(period)
      period.find('input').prop('disabled', false)
      this.applyCalendrial(period)
      return period
    },

    add: function() {
      jQuery('.periods').append(this.new())
    },

    remove: function(link) {
      link = jQuery(link)
      var period = link.parents('.period')
      period.find('input[name*=_destroy]').prop('value', '1')
      period.hide()
    },

    applyCalendrial: function(period) {
      options = {isoTime: true}
      jQuery(period).find('.date-select, .time-select').calendricalDateTimeRange(options)
    },

  },

  assignments: {
    toggle: function(period) {
      period = jQuery(period)
      jQuery.get(period.attr('data-toggle-url'), function(data) {
        jQuery(period).replaceWith(data)
      })
    },

  },

};
