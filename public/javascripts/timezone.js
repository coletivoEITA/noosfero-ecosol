//= require_self

noosfero.timezone = {

  setCookie: function() {
    var offset = - new Date().getTimezoneOffset()/60
    $.cookie("browser.tzoffset", offset, { expires: 30, path: '/' })
  },

}

$(document).ready(function() {
  noosfero.timezone.setCookie()
})
