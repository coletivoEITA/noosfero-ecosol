
open_graph = {

  track: {

    config: {

      init: function() {
        jQuery('.panel-body input[type=checkbox]:first').each(function(i, checkbox) {
          open_graph.track.config.toggleParent(checkbox)
        })
      },

      toggle: function(checkbox) {
        var panel = $(checkbox).parents('.panel')
        var checkboxes = panel.find('.panel-body input[type=checkbox]')
        checkboxes.prop('checked', checkbox.checked)
      },

      toggleParent: function(checkbox) {
        var panel = $(checkbox).parents('.panel')
        var parentCheckbox = panel.find('.panel-heading input[type=checkbox]')
        var nChecked = panel.find('.panel-body input[type=checkbox]:checked').length
        var nTotal = panel.find('.panel-body input[type=checkbox]').length

        parentCheckbox.prop('indeterminate', false)
        if (nChecked == nTotal)
          parentCheckbox.prop('checked', true)
        else if (nChecked === 0)
          parentCheckbox.prop('checked', false)
        else
          parentCheckbox.prop('indeterminate', true)
      },

    },
  },

  autocomplete: {
    bloodhoundOptions: {
      datumTokenizer: Bloodhound.tokenizers.obj.whitespace('value'),
      queryTokenizer: Bloodhound.tokenizers.whitespace,
      ajax: {
        beforeSend: function() {
          input.addClass('small-loading')
        },
        complete: function() {
          input.removeClass('small-loading')
        },
      },
    },
    tokenfieldOptions: {

    },
    typeaheadOptions: {
      minLength: 1,
      highlight: true,
    },

    init: function(url, selector, data, options) {
      options = options || {}
      var bloodhoundOptions = jQuery.extend({}, this.bloodhoundOptions, options.bloodhound || {});
      var typeaheadOptions = jQuery.extend({}, this.typeaheadOptions, options.typeahead || {});
      var tokenfieldOptions = jQuery.extend({}, this.tokenfieldOptions, options.tokenfield || {});

      var input = $(selector)
      bloodhoundOptions.remote = jQuery.param.querystring(url, 'query=%QUERY')
      var engine = new Bloodhound(bloodhoundOptions)
      engine.initialize()

      tokenfieldOptions.typeahead = [typeaheadOptions, { displayKey: 'label', source: engine.ttAdapter() }]

      input.tokenfield(tokenfieldOptions)
      input.tokenfield('setTokens', data);
    },
  },
}

