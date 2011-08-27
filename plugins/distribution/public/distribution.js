function distributionRowSetSelected(event) {
  jQuery('.value_row').removeClass('selected');
  jQuery('.value_row').find('.ordered_product_more_actions').hide();
  jQuery('.value_row').find('.session_product_more_info').hide();
  jQuery(this).addClass('selected');
  jQuery(this).find('.ordered_product_more_actions').show();
  jQuery(this).find('.session_product_more_info').show();
}

var session_product_editing = jQuery();
function distribution_plugin_session_product_edit(id) {
  editing = jQuery(id);
  stop_editing = editing.index(session_product_editing) ? false : true;

  session_product_editing.removeClass('session-product-editing');
  session_product_editing.find('.session-product-edit').hide();
  if (!stop_editing) {
    editing.addClass('session-product-editing');
    editing.find('.session-product-edit').show();
    session_product_editing = editing;
  }
}

