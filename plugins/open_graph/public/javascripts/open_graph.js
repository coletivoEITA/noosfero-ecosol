
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

}

