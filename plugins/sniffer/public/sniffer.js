function sniffer_plugin_interest_enable(enabled) {
  el = jQuery('#sniffer-plugin-product-select');
  el.toggleClass('disabled', !enabled);

  margin = 10;
  return jQuery('#sniffer-plugin-disable-pane').css({
    top: el.position().top - margin,
    left: el.position().left - margin,
    width: el.innerWidth() + margin*2,
    height: el.innerHeight() + margin*2,
  }).toggle(!enabled);
}

function sniffer_plugin_show_hide_toggle(context, hideText, showText, element) {
  isShow = (jQuery(context).text() == showText);
  element.fadeToggle();
  jQuery(context).text(isShow ? hideText : showText);
}
