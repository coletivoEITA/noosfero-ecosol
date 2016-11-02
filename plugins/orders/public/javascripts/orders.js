//= require ./views/items-table
//= require ./views/item-quantity-price
//= require ./views/item
//= require ./views/payment

orders = {

  t: function (key, options) {
    return I18n.t(key, $.extend(options, {scope: 'orders_plugin'}))
  },

  locales: {
    noneSelected: '',
  },

  order: {

    reload: function(context, url) {
      var order = $(context).parents('.order-view')

      loading_overlay.show(order)
      $.getScript(url, function () {
        loading_overlay.hide(order)
      })
    },

    submit: function(form) {
      var order = $(form).parents('.order-view')

      $(form).ajaxSubmit({dataType: 'script',
        beforeSubmit: function(){ loading_overlay.show(order) },
        success: function(){ loading_overlay.hide(order) },
      })

      return false
    },

    add_payment: function(context) {
      var data = $(context).siblings(".order-input-data")
      $('#payment_orders_plugin_order_id').val(data.attr('data-id'))
      $('#payment_value').val("")
      $('#payment_description').val("")

      var pm = $('#payment_payment_method_id')
      var slug = data.attr('data-payment-method')
      var option = pm.find('option').filter(function() { return $(this).html() == slug })
      if (option) { pm.val(option.val()) }
    },

    payment: {
      submit: function() {
        var id = $("#payment_orders_plugin_order_id").val()
        var order = $('#order-'+id)
        var form = order.find('form')
        orders.order.submit(form)
      }
    },
  },

  item: {

    edit_quantity: function (item) {
      item = $(item);
      toggle_edit.edit(item);

      var quantity = item.find('.quantity input');
      quantity.focus();
    },

    admin_add: {
      search_url: null,
      add_url: null,
      source: null,

      load: function (id) {
        var self = this
        var input = $('#order-row-'+id+' .order-product-add .add-input')
        this.source = new Bloodhound({
          datumTokenizer: Bloodhound.tokenizers.obj.whitespace('value'),
          queryTokenizer: Bloodhound.tokenizers.whitespace,
          remote: this.search_url+'&query=%QUERY',
        })
        this.source.initialize()

        input.typeahead({
          minLength: 2, highlight: true,
        }, {
          displayKey: 'label',
          source: this.source.ttAdapter(),
        }).on('typeahead:selected', function(e, item) {
          $('#order-'+id+' order-items-table').get(0)._tag.adminAdd(item.value)
          input.val("")
          $(input).typeahead('val', '');
          display_notice(window.orders.t("views.item._index.product_added"))
        })
      },
    },
  },

  admin: {

    toggle_edit: function () {
      sortable_table.edit_arrow_toggle(toggle_edit.editing(), toggle_edit.isEditing());
    },

    load_edit: function(order, url) {
      var edit = $(order).find('.box-edit')
      edit.load(url, function() {
        edit.removeClass('loading')
      });
      $(order).attr('onclick', '')
    },

    select: {
      all: function() {
        $('.order #order_ids_').attr('checked', true)
      },
      none: function() {
        $('.order #order_ids_').attr('checked', false)
      },

      selection: function() {
        return $('.order #order_ids_:checked').parents('.order')
      },

      report: function(url) {
        var ids = this.selection().map(function (i, el) { return $(el).attr('data-id') }).toArray();
        if (ids.length === 0) {
          alert(orders.locales.noneSelected)
          return
        }
        window.location.href = url + '&' + $.param({ids: ids})
      },

    },
  },

  setOrderMaxHeight: function()
  {
    ordersH = $(window).height();
    ordersH -= $('#cirandas-top-bar').outerHeight()
    ordersH -= $('.order-view form > .actions').outerHeight(true)
    $('.order-view .order-data').css('max-height', ordersH);
  },

  daterangepicker: {

    defaultOptions: {},

    init: function(rangeSelector, _options) {
      var options    = $.extend({}, orders.daterangepicker.defaultOptions, _options);
      var rangeField = $(rangeSelector)
      var container  = rangeField.parents('.daterangepicker-field-container')

      var startField = container.find('input[data-field=start]')
      var endField   = container.find('input[data-field=end]')
      var startDate  = moment(startField.val(), moment.ISO_8601).format(options.locale.format)
      var endDate    = moment(endField.val(), moment.ISO_8601).format(options.locale.format)

      options.startDate = startDate
      options.endDate   = endDate

      rangeField.daterangepicker(options)
    },
  },

  set_other_payment_method_field: function(ev) {
    if (ev)
      var target = ev.target
    else
      var target = $(".payment-edition select")[0]

    if (target.value == 'other')
      $("#order_payment_data_other_method").show()
    else {
      $("#order_payment_data_other_method").val('')
      $("#order_payment_data_other_method").hide()
    }
  },
};

$(window).resize(orders.setOrderMaxHeight);
$('#order_supplier_delivery_id').change(orders.setOrderMaxHeight);

$(document).ready(function(){
  orders.setOrderMaxHeight();
});
