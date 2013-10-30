
orders_cycle = {

  cycle: {

    edit: function () {
      options = {isoTime: true};
      jQuery('#cycle_start_date, #cycle_start_time, #cycle_finish_date, #cycle_finish_time').calendricalDateTimeRange(options);
      jQuery('#cycle_delivery_start_date, #cycle_delivery_start_time, #cycle_delivery_finish_date, #cycle_delivery_finish_time').calendricalDateTimeRange(options);
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

  order: {

    product: {
      include_message: '',
      order_id: 0,
      redirect_after_include: '',
      add_url: '',
      remove_url: '',
      balloon_url: '',

      load: function (id, state) {
        var product = jQuery('#cycle-product-'+id);
        product.toggleClass('in-order', state);
        product.find('input').get(0).checked = state;
        return product;
      },

      checkbox_click: function (check_box, id) {
        this.click(id, check_box.checked);
        return true;
      },
      click: function (event, id) {
        // was this a child click?
        if (event.target != this && event.target.onclick)
          return;

        var product = jQuery('#cycle-product-'+id);
        var state = !product.hasClass('in-order');
        if (state == true)
          this.add(id);
        else
          this.remove(id);
        product.find('input').get(0).checked = state;
      },

      add: function (id) {
        var product = this.load(id, true);

        if (this.include_message)
          alert(this.include_message);

        loading_overlay.show(product);
        jQuery.post(this.add_url, {order_id: this.order_id, redirect: this.redirect_after_include, offered_product_id: id}, function () {
          loading_overlay.hide(product);
        });
      },
      remove: function (id) {
        var product = this.load(id, false);

        loading_overlay.show(product);
        jQuery.post(this.remove_url, {id: id, order_id: this.order_id}, function () {
          loading_overlay.hide(product);
        });
      },

      supplier: {
        balloon_url: '',

        balloon: function (id) {
          var product = jQuery('#cycle-product-'+id);
          var target = product.find('.supplier');
          var supplier_id = product.attr('supplier-id');
          balloon.showFromGet(target, this.balloon_url+'/'+supplier_id, {position: 'above'});
        },
      },

      balloon: function (id) {
        var product = jQuery('#cycle-product-'+id);
        var target = product.find('.product');
        balloon.showFromGet(target, this.balloon_url+'/'+id, {position: 'above'});
      },
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
      loading_overlay.show('#'+elementId);
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
