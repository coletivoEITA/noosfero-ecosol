
orders_cycle = {

  cycle: {

    edit: function () {
      options = {isoTime: true};
      jQuery('#cycle_start_date, #cycle_start_time, #cycle_finish_date, #cycle_finish_time').calendricalDateTimeRange(options);
      jQuery('#cycle_delivery_start_date, #cycle_delivery_start_time, #cycle_delivery_finish_date, #cycle_delivery_finish_time').calendricalDateTimeRange(options);
    },

    products: {
      load_url: null,

      load: function () {
        jQuery.get(orders_cycle.cycle.products.load_url, function(data) {
          if (data.length > 10)
            jQuery('#cycle-products .table').html(data)
          else
            setTimeout(orders_cycle.cycle.products.load, 5*1000);
        });
      },
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
        toggle_edit.value_row.reload();
        return product;
      },

      showMore: function (url) {
        jQuery.get(url, function (data) {
          var newProducts = jQuery(data).filter('#cycle-products').find('.table-content').children()
          jQuery('.pagination').replaceWith(newProducts)
          pagination.loading = false
        })
      },

      checkbox_click: function (check_box, id) {
        this.click(null, id);
        return true;
      },
      click: function (event, id) {
        // was this a child click?
        if (event != null && event.target != this && event.target.onclick)
          return;

        var product = jQuery('#cycle-product-'+id);
        if (! product.hasClass('editable'))
          return;

        var state = !product.hasClass('in-order');
        if (state == true)
          this.add(id);
        else
          this.remove(id);
        product.find('input').get(0).checked = state;
      },

      setEditable: function (editable) {
        jQuery('.order-cycle-product').toggleClass('editable', editable)
        if (editable)
          jQuery('.order-cycle-product #product_ids_').removeAttr('disabled')
        else
          jQuery('.order-cycle-product #product_ids_').attr('disabled', 'disabled')
      },

      add: function (id) {
        var product = this.load(id, true);

        if (this.include_message)
          alert(this.include_message);

        loading_overlay.show(product);
        jQuery.post(this.add_url, {order_id: this.order_id, redirect: this.redirect_after_include, offered_product_id: id}, function () {
          loading_overlay.hide(product);
        }, 'script');
      },
      remove: function (id) {
        var product = this.load(id, false);

        loading_overlay.show(product);
        jQuery.post(this.remove_url, {id: id, order_id: this.order_id}, function () {
          loading_overlay.hide(product);
        }, 'script');
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
    if ($('#cycle-new-mail-send').prop('checked')) {
      jQuery('#cycle-new-mail').removeClass('disabled');
      jQuery('#cycle-new-mail textarea').removeAttr('disabled');
    } else {
      jQuery('#cycle-new-mail').addClass('disabled');
      jQuery('#cycle-new-mail textarea').attr('disabled', true);
    }
  },

  ajaxifyPagination: function(selector) {
    jQuery(selector).find(".pagination a").click(function() {
      loading_overlay.show(selector);
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
    jQuery('.consumers-coop .consumer-order.cancelled').not('.comsumer-order.active-order').toggle();
  },

};
