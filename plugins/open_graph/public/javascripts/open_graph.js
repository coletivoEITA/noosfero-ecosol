
open_graph = {

  track: {

    config: {

      view: {
        form: null,
      },

      init: function() {
        this.view.form = jQuery('#track-form form')

        this.view.form.find('.panel-heading').each(function(i, context) {
          open_graph.track.config.headingToggle(context)
        })

        setTimeout(this.watchChanges(), 1000)
      },

      watchChanges: function() {
        this.view.form.find('input').change(this.save)
      },

      save: function() {
        open_graph.track.config.view.form.submit()
      },

      headingToggle: function(context, open) {
        var panel = $(context).parents('.panel')
        var parentCheckbox = panel.find('.config-check')
        var input = panel.find('.track-config-toggle')
        if (open === undefined)
          open = input.val() == 'true'

        parentCheckbox.toggleClass('fa-toggle-on', open)
        parentCheckbox.toggleClass('fa-toggle-off', !open)
        input.prop('value', open)
        input.trigger('change')
      },

      open: function(context) {
        var panel = $(context).parents('.panel')
        var panelBody = panel.find('.panel-body')
        panelBody.addClass('in').show()
      },

      toggle: function(context, event) {
        var panel = $(context).parents('.panel')
        var panelBody = panel.find('.panel-body')
        var checkboxes = panelBody.find('input[type=checkbox]')
        var open = panel.find('.track-config-toggle').val() == 'true'
        open = !open;

        checkboxes.prop('checked', open)
        this.headingToggle(context, open)
        if (!open)
          panelBody.hide()
        return false;
      },

      // DEPRECATED: the panel-body is hidden by default
      toggleParent: function(context) {
        var panel = $(context).parents('.panel')
        var panelBody = panel.find('.panel-body')
        var checkboxes = panel.find('.panel-body input[type=checkbox]')
        var profilesInput = panel.find('.panel-body .select-profiles')

        var nObjects = checkboxes.filter(':checked').length
        var nProfiles = profilesInput.length ? profilesInput.tokenfield('getTokens').length : 0;
        var nChecked = nObjects + nProfiles;
        var nTotal = checkboxes.length + nProfiles

        if (nChecked === 0) {
          panelBody.removeClass('in')
          this.headingToggle(context, false)
        } else {
          panelBody.addClass('in')
          this.headingToggle(context, true)
        }
      },

      enterprise: {
        see_all: function(context) {
          var panel = $(context).parents('.panel')
          var panelBody = panel.find('.panel-body')
          noosfero.modal.html(panelBody.html())
        },
      },

      initAutocomplete: function(track, url, items) {
        var selector = '#select-'+track
        var tokenField = open_graph.autocomplete.init(url, selector, items)

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

        return tokenField;
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
      input.tokenfield('setTokens', data)

      return input
    },
  },
}

