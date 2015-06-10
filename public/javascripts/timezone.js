//= require moment
//= require_self

noosfero.timezone = {

  setCookie: function() {
    var offset = moment.parseZone(Date.now()).utcOffset()/60
    $.cookie("browser.tzoffset", offset, { expires: 30, path: '/' })
  },

}

$(document).ready(function() {
  noosfero.timezone.setCookie()
})
