//= require jstz
//= require_self

noosfero.timezone = {

  setCookie: function() {
    jQuery.cookie("browser.timezone", jstz.determine().name(), { expires: 30, path: '/' })
  },

}

jQuery(document).ready(function() {
  noosfero.timezone.setCookie()
})
