// extend form to support data-update and data-loading

jQuery(document).delegate('form[data-update]', 'ajax:success', function(event, data, status, xhr) {
  var element = jQuery(jQuery(this).data('update'));
  if (element.length > 0) element.html(data);
});

jQuery(document).delegate('[data-loading]', 'ajax:before', function() {
  if (jQuery(this).data('loading') == true)
    loading_overlay.show(jQuery(this));
  else
    loading_overlay.show(jQuery(this).data('loading'));
});
jQuery(document).delegate('[data-loading]', 'ajax:complete', function() {
  if (jQuery(this).data('loading') == true)
    loading_overlay.hide(jQuery(this));
  else
    loading_overlay.hide(jQuery(this).data('loading'));
});

