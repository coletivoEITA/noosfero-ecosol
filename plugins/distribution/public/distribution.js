function sessionProductSetFocus(id) {
  jQuery(id).find('input').focus();

}

function distributionSessionRowSetSelected(event) {
  it=jQuery(this);
  jQuery('.value_row').find('.quantity_entry').hide();
  jQuery('.value_row').find('.quantity_number').show();
  jQuery('.value_row').find('.session_product_more_info').hide();
  if (it.find('.value_row').hasClass('selected')) {
    it.find('.value_row').removeClass('selected');
  }
  else {
    jQuery('#session_column').find('.value_row').removeClass('selected');
    it.find('.value_row').addClass('selected');
    it.find('.session_product_more_info').show();
    it.find('.quantity_number').hide();
    it.find('.quantity_entry').show();
  }
}

function distributionOrderedRowSetSelected(event) {
  jQuery('#inside_box_order_products').find('.value_row').removeClass('selected');
  jQuery('.value_row').find('.ordered_product_more_actions').hide();
  jQuery(this).find('.value_row').addClass('selected');
  jQuery(this).find('.ordered_product_more_actions').show();
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

