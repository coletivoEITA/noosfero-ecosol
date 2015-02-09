
open_graph = {

  track: {

    config: {

      init: function() {
        jQuery('#track-form .panel-heading input[type=checkbox]').each(function(i, checkbox) {
          open_graph.track.config.toggleParent(checkbox)
        })
      },

      toggle: function(context) {
        var panel = $(context).parents('.panel')
        var panelBody = panel.find('.panel-body')
        var checkboxes = panel.find('input[type=checkbox]')
        var open = !panelBody.hasClass('in')

        checkboxes.prop('checked', open)
      },

      toggleParent: function(context) {
        var panel = $(context).parents('.panel')
        var panelBody = panel.find('.panel-body')
        var parentCheckbox = panel.find('.panel-heading input[type=checkbox]')
        var checkboxes = panel.find('.panel-body input[type=checkbox]')
        var profilesInput = panel.find('.panel-body .select-profiles')

        var nObjects = checkboxes.filter(':checked').length
        var nProfiles = profilesInput.length ? profilesInput.tokenfield('getTokens').length : 0;
        var nChecked = nObjects + nProfiles;
        var nTotal = checkboxes.length + nProfiles

        parentCheckbox.prop('indeterminate', false)
        if (nChecked === 0) {
          panelBody.removeClass('in')
          parentCheckbox.prop('checked', false)
        } else {
          panelBody.addClass('in')
          if (nChecked >= nTotal)
            parentCheckbox.prop('checked', true)
          else
            parentCheckbox.prop('indeterminate', true)
        }
      },

      initAutocomplete: function(track, url, items) {
        var selector = '#select-'+track
        var tokenField = open_graph.autocomplete.init(url, selector, items)
        open_graph.track.config.toggleParent(tokenField)

        tokenField
          .on('tokenfield:createdtoken tokenfield:removedtoken', function() {
            open_graph.track.config.toggleParent(this)
          }).on('tokenfield:createtoken', function(event) {
            var existingTokens = $(this).tokenfield('getTokens')
            $.each(existingTokens, function(index, token) {
              if (token.value === event.attrs.value)
                event.preventDefault()
            })
          })
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
      bloodhoundOptions.remote = {
        url: url,
        replace: function(url, uriEncodedQuery) {
          return jQuery.param.querystring(url, {query:uriEncodedQuery});
        },
      }
      var engine = new Bloodhound(bloodhoundOptions)
      engine.initialize()

      tokenfieldOptions.typeahead = [typeaheadOptions, { displayKey: 'label', source: engine.ttAdapter() }]

      var tokenField = input.tokenfield(tokenfieldOptions)
      input.tokenfield('setTokens', data);

      return tokenField
    },
  },
}

