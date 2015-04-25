
orders = {

  locales: {
    noneSelected: '',
  },

  order: {

    reload: function(context, url) {
      var order = jQuery(context).parents('.order-view')

      loading_overlay.show(order)
      jQuery.getScript(url, function () {
        loading_overlay.hide(order)
      })
    },

    submit: function(form) {
      var order = jQuery(form).parents('.order-view')

      jQuery(form).ajaxSubmit({dataType: 'script',
        beforeSubmit: function(){ loading_overlay.show(order) },
        success: function(){ loading_overlay.hide(order) },
      })

      return false
    },

    delivery: {

      select: function(element, url) {
        element = $(element)
        params = {order: {supplier_delivery_id: element.val()}}
        deliveryBox = element.parents('.delivery-box')
        $.get(url, params, function(data) {
          deliveryBox.replaceWith(data)
        })
      }

    },

  },

  item: {

    edit: function () {
    },

    edit_quantity: function (item) {
      item = jQuery(item);
      toggle_edit.edit(item);

      var quantity = item.find('.quantity input');
      quantity.focus();
    },

    // keydown prevents form submit, keyup don't
    quantity_keydown: function(context, event) {
      if (event.keyCode == 13) {
        var item = jQuery(context).parents('.item');
        item.find('.more .action-button').get(0).onclick();

        event.preventDefault();
        return false;
      }
    },

    admin_remove: function(context, url) {
      var container = jQuery(context).parents('.order-items-container');
      var item = jQuery(context).parents('.item');
      var quantity = item.find('.quantity input');
      quantity.val('0')
      this.submit(context, url)
    },

    submit: function(context, url) {
      var container = jQuery(context).parents('.order-items-container');
      var item = jQuery(context).parents('.item');
      var quantity = item.find('.quantity input');
      var data = {}
      data[quantity[0].name] = quantity.val()

      loading_overlay.show(container);
      jQuery.post(url, data, function(){}, 'script');
    },
  },

  admin: {

    toggle_edit: function () {
      sortable_table.edit_arrow_toggle(toggle_edit.editing(), toggle_edit.isEditing());
    },

    load_edit: function(order, url) {
      var edit = jQuery(order).find('.box-edit')
      edit.load(url, function() {
        edit.removeClass('loading')
      });
      jQuery(order).attr('onclick', '')
    },

    select: {
      all: function() {
        jQuery('.order #order_ids_').attr('checked', true)
      },
      none: function() {
        jQuery('.order #order_ids_').attr('checked', false)
      },

      selection: function() {
        return jQuery('.order #order_ids_:checked').parents('.order')
      },

      report: function(url) {
        var ids = this.selection().map(function (i, el) { return jQuery(el).attr('data-id') }).toArray();
        if (ids.length === 0) {
          alert(orders.locales.noneSelected)
          return
        }
        window.location.href = url + '&' + jQuery.param({ids: ids})
      },

    },
  },

  set_orders_container_max_height: function()
  {
    ordersH = jQuery(window).height();
    ordersH -= 100
    ordersH -= jQuery('#cirandas-top-bar').outerHeight()
    ordersH -= jQuery('.order-status-message').outerHeight()
    ordersH -= jQuery('.order-message-title').outerHeight()
    ordersH -= jQuery('#order-column .order-items .table-header').last().outerHeight()
    ordersH -= jQuery('#order-column .order-total').last().outerHeight()
    ordersH -= jQuery('#order-column #actor-data-box').last().outerHeight()
    ordersH -= jQuery('#order-column .delivery-box').outerHeight()
    ordersH -= jQuery('#order-column .order-message-text').outerHeight()
    ordersH -= jQuery('#order-column .order-message-actions').outerHeight()
    ordersH -= jQuery('#order-column .actions').outerHeight()
    jQuery('.order-items-container .order-items-scroll').css('max-height', ordersH);
  }

};

jQuery(document).ready(orders.set_orders_container_max_height);
jQuery(window).resize(orders.set_orders_container_max_height);

