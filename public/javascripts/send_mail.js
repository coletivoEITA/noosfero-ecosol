send_mail = {

  init: function (members) {
    var input = $('#mailing_recipient_ids')
    _.each(members, function(m) {
      m.label = '<img src="'+m.image+'"/>&nbsp;'+m.name
    })

    var engine = new Bloodhound({
      local: members, datumTokenizer: function(d) {
        return Bloodhound.tokenizers.whitespace(d.name)
      }, queryTokenizer: Bloodhound.tokenizers.whitespace
    });
    engine.initialize();

    input.tokenfield({
      minLength: 1, highlight: true, html: true,
      typeahead: [null, { displayKey: 'label', source: engine.ttAdapter() }],
    }).on('tokenfield:createtoken tokenfield:removetoken', function(event) {
      input.val('')
    }).on('tokenfield:createtoken', function(event) {
      var existingTokens = $(this).tokenfield('getTokens')
      $.each(existingTokens, function(index, token) {
        if (token.value != event.attrs.value) return
        event.preventDefault()
        input.val('')
      })
    })
    input.tokenfield('disable')
  },

  toggleAllMembers: function (checkbox) {
    var input = $('#mailing_recipient_ids')
    input.tokenfield(checkbox.checked ? 'disable' : 'enable')
  },

}

