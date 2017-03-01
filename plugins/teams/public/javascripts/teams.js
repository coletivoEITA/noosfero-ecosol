//= require views/teams-context
//= require views/team-edit
//= require views/team-view

teams = {

  t: function (key, options) {
    return I18n.t(key, $.extend(options, {scope: 'teams_plugin'}))
  },

}

//@ sourceURL=plugins/teams/javascripts/teams.js
