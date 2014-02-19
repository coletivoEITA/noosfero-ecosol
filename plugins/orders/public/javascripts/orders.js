
orders = {

  item: {

    edit: function () {
      toggle_edit.editing().find('.more').toggle(toggle_edit.isEditing());
    },

    quantity_keyup: function(context, event) {
      if (event.keyCode == 13) {
        var item = jQuery(context).parents('.item');
        item.find('.more .action-button').get(0).onclick();

        event.preventDefault();
        return false;
      }
    },

    submit: function(context, url) {
      var container = jQuery(context).parents('.order-items-container');
      var item = jQuery(context).parents('.item');
      var quantity_asked = item.find('.quantity-edit input');

      loading_overlay.show(container);
      jQuery.post(url, {'item[quantity_asked]': quantity_asked.val()}, 'script');
    },
  },

  admin: {

    toggle_edit: function () {
      toggle_edit.editing().find('.box-edit').toggle(toggle_edit.isEditing());
      sortable_table.edit_arrow_toggle(toggle_edit.editing(), toggle_edit.isEditing());
    },
  },

  set_orders_container_max_height: function()
  {
    cirandasTopBarH = jQuery('#cirandas-top-bar').outerHeight();
    deliveryH = jQuery('#order-column #delivery-box').outerHeight();
    headerH = jQuery('#order-column .order-message-title.status-open').outerHeight();
    totalH = jQuery('#order-column .order-total').last().outerHeight();
    screenH = jQuery(window).height();
    ordersH = screenH - deliveryH - totalH - headerH - cirandasTopBarH;
    jQuery('.order-items-container .order-items').css('max-height', ordersH);
  }

};


jQuery(document).ready(function() {
  orders.set_orders_container_max_height();
});
