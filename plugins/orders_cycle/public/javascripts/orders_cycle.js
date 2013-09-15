
orders_cycle = {

  cycle: {

    edit: function (destroy_url) {
      options = {isoTime: true};
      jQuery('#cycle_start_date, #cycle_start_time, #cycle_finish_date, #cycle_finish_time').calendricalDateTimeRange(options);
      jQuery('#cycle_delivery_start_date, #cycle_delivery_start_time, #cycle_delivery_finish_date, #cycle_delivery_finish_time').calendricalDateTimeRange(options);

      var saveClick = false;
      if (destroy_url) {
        jQuery(window).bind('beforeunload', function () {
          if (!saveClick)
            jQuery.ajax({type: 'POST', async: false, url: destroy_url});
        });
      }
    },
  },

  /* ----- cycle ----- */

  in_cycle_order_toggle: function (context) {
    container = jQuery(context).hasClass('cycle-orders') ? jQuery(context) : jQuery(context).parents('.cycle-orders');
    container.toggleClass('show');
    container.find('.order-content').toggle();
    sortable_table.edit_arrow_toggle(container);
  },

  /* ----- order ----- */

  order_product: {
    include: function (message, url) {
      if (message)
        alert(message);
      return false;
    },
  },

  /* ----- cycle editions ----- */

  offered_product: {

    pmsync: function (context, to_price) {
      p = jQuery(context).parents('.cycle-product .box-edit');
      margin = p.find('#product_margin_percentage');
      price = p.find('#product_price');
      buy_price = p.find('#product_buy_price');
      original_price = p.find('#product_original_price');
      base_price = unlocalize_currency(buy_price.val()) ? buy_price : original_price;

      if (to_price)
        suppliers.price.calculate(price, margin, base_price);
      else
        suppliers.margin.calculate(margin, price, base_price);
    },

    edit: function () {
      toggle_edit.editing().find('.box-edit').toggle(toggle_edit.isEditing());
    },

    order: {
      toggle: function () {
        toggle_edit.editing().find('.box-edit').toggle(toggle_edit.isEditing());
        toggle_edit.editing().find('.quantity-label').toggle(!toggle_edit.isEditing());
        toggle_edit.editing().find('.quantity-entry').toggle(toggle_edit.isEditing());
      },
    },
  },

  /* ----- toggle edit ----- */

  cycle_mail_message_toggle: function () {
    if ($('cycle-new-mail-send').checked) {
      jQuery('#cycle-new-mail').removeClass('disabled');
      jQuery('#cycle-new-mail textarea').removeAttr('disabled');
    } else {
      jQuery('#cycle-new-mail').addClass('disabled');
      jQuery('#cycle-new-mail textarea').attr('disabled', true);
    }
  },

  colorbox: function (options) {
    options.innerWidth = 500;
    jQuery.colorbox(options);
  },

  ajaxifyPagination: function(elementId) {
    jQuery(".pagination a").click(function() {
      loading_overlay.show(elementId);
      jQuery.ajax({
        type: "GET",
        url: jQuery(this).attr("href"),
        dataType: "script"
      });
      return false;
    });
  },

  toggleCancelledOrders: function () {
    jQuery('.consumers-coop #show-cancelled-orders a').toggle();
    jQuery('.consumers-coop #hide-cancelled-orders a').toggle();
    jQuery('.consumers-coop .consumer-order:not(.edit) .status-cancelled').toggle();
  },

};
