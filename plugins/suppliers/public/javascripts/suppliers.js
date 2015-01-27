
suppliers = {

  filter: {

    submit: function(field) {
      setTimeout(function () {
        field.form.onsubmit();
      }, 300);
    },
  },

  add_link: function () {
    if (toggle_edit.isEditing())
      toggle_edit.value_row.toggle_edit();

    var supplier_add = jQuery('#supplier-add');
    toggle_edit.setEditing(supplier_add);
    toggle_edit.value_row.toggle_edit();
  },

  toggle_edit: function () {
    if (toggle_edit.editing().is('#supplier-add'))
      toggle_edit.editing().toggle(toggle_edit.isEditing());
    toggle_edit.editing().find('.box-view').toggle(!toggle_edit.isEditing());
    toggle_edit.editing().find('.box-edit').toggle(toggle_edit.isEditing());
  },

  add: {
    supplier_added: function () {
      jQuery('#results').html('');
    },
    create_dummy: function () {
      jQuery('#find-enterprise, #create-dummy, #create-dummy .box-edit').toggle();
    },

    search: function (input) {
      query = jQuery(input).val();
      if (query.length < 3)
        return;
      input.form.onsubmit();
    },
  },

  our_product: {

    toggle_edit: function () {
      toggle_edit.editing().find('.box-edit').toggle(toggle_edit.isEditing());
    },

    default_change: function (event) {
      block = jQuery(this).parents('.block');
      block.find('div[data-non-defaults]').toggle(!this.checked);
    },

    load: function(id) {
      jQuery('#our-product-'+id+' div[data-default-toggle] input').change(suppliers.our_product.default_change).change();
    },

    pmsync: function (context, to_price) {
      var p = jQuery(context).parents('.our-product');
      var margin_input = p.find('.product-margin-percentage');
      var price_input = p.find('.product-price');
      var buy_price_input = p.find('.product-base-price');

      if (to_price)
        suppliers.price.calculate(price_input, margin_input, buy_price_input);
      else
        suppliers.margin.calculate(margin_input, price_input, buy_price_input);
    },

    select: {
      all: function() {
        jQuery('.our-product #product_ids_').attr('checked', true)
      },
      none: function() {
        jQuery('.our-product #product_ids_').attr('checked', false)
      },

      activate: function(state) {
        var selection = jQuery('.our-product #product_ids_:checked').parents('.our-product')
        selection.find('.available input[type=checkbox]').each(function() {
          this.checked = state
          jQuery(this.form).submit()
        });
      },
    },
  },

  price: {

    calculate: function (price_input, margin_input, base_price_input) {
      var price = unlocalize_currency(jQuery(price_input).val());
      var base_price = unlocalize_currency(jQuery(base_price_input).val());
      var margin = unlocalize_currency(jQuery(margin_input).val());

      var value = base_price + (margin / 100) * base_price;
      if (isNaN(value))
        value = unlocalize_currency(base_price_input.val());
      jQuery(price_input).val(localize_currency(value));
    },
  },

  margin: {

    calculate: function (margin_input, price_input, base_price_input) {
      var price = unlocalize_currency(jQuery(price_input).val());
      var base_price = unlocalize_currency(jQuery(base_price_input).val());
      var margin = unlocalize_currency(jQuery(margin_input).val());

      var value = ((price - base_price) / base_price ) * 100;
      value = !isFinite(value) ? '' : localize_currency(value);
      jQuery(margin_input).val(value);
    },
  },

  supplier: {
    select: {
      all: function() {
        jQuery('#suppliers-page input.entity-cb').attr('checked', true)
      },
      none: function() {
        jQuery('#suppliers-page input.entity-cb').attr('checked', false)
      },

      activate: function(state) {
        var selection = jQuery('#suppliers-page input.entity-cb:checked').parents('.our-product')
        selection.find('.available input[type=checkbox]').each(function() {
          this.checked = state
          jQuery(this.form).submit()
        });
      },
    },

    toggle_open: function(event) {
      event.preventDefault();
      t = jQuery(event.target);
      t.parents('.entity').toggleClass('open');
      t.parent().find('.action-show').toggle();
      t.parent().find('.action-hide').toggle();
    },

    toggle_edit: function(event) {
      event.preventDefault();
      t = jQuery(event.target);
      t.parents('.entity').toggleClass('edit');
    },

    cancel_edition: function(event) {
      event.preventDefault();
      t = jQuery(event.target);
      t.parents('.entity').removeClass('edit');
    },

    create_tokens: function(type, input) {
      if (input == undefined)
        input = $(this);
      q = jQuery(input).parents('.qualifiers');
      view = q.find('.view');
      text = input.value;
      input.value = '';

      text = suppliers.supplier.filter_new_input(text, view);
      text.each(function(el) {
        el = el.strip();
        div = jQuery('<div class=token>').appendTo(view);
        jQuery('<input type="hidden" name="qualifiers[]">').appendTo(div).value = el;
        jQuery('<span>').text(el).appendTo(div);
        jQuery('<a href="#" class="remove-token">').appendTo(div).text("X");
      });
    },

    filter_new_input: function(qualifiers, view) {
      q = [];
      qualifiers.split(',').each(function(qualifier){
        qualifier.strip();
        if (qualifier) {
          // check if we already have that qualifier
          have = false;
          view.find('span').each(function(i,span){
            if (jQuery(span).text().strip() == qualifier) {
              have = true;
              return;
            }
          });
          if (!have)
            q.push(qualifier);
        }
      });
      return q;
    },

    remove_tokens: function(event) {
      event.preventDefault();
      $(this).parents('div.token').remove();
    }
  }
};

// EVENTS
jQuery(document).ready(function() {

  jQuery('#suppliers-page .entity a.actions-circle').click(suppliers.supplier.toggle_open);
  jQuery('#suppliers-page .entity a.action-button.edit-button').click(suppliers.supplier.toggle_edit);
  jQuery('#suppliers-page .entity a.action-button.cancel-button').click(suppliers.supplier.cancel_edition);

  // page load first create of qualifiers tokens
  jQuery('#suppliers-page .entity .qualifiers input.qualifier').each(function(i,el){ suppliers.supplier.create_tokens('qualifier', el)});
  jQuery('#suppliers-page .entity .qualifiers input.qualifier').keypress(function(event) {
    if (event.which == 13 || event.which ==  44) {// enter or comma
      event.preventDefault();
      suppliers.supplier.create_tokens('qualifier', $(this));
    }
  });

  // page load first create of qualifiers tokens
  jQuery('#suppliers-page .entity .tags input.tag').each(function(i,el){ suppliers.supplier.create_tokens('tag', el)});
  jQuery('#suppliers-page .entity .tags input.tag').keypress(function(event) {
    if (event.which == 13 || event.which ==  44) {// enter or comma
      event.preventDefault();
      suppliers.supplier.create_tokens('tag', $(this));
    }
  });

  jQuery('#suppliers-page .entity .qualifiers a.remove-token').click(suppliers.supplier.remove_tokens);
  jQuery('#suppliers-page .entity .tags       a.remove-token').click(suppliers.supplier.remove_tokens);

});

