
networks = {

  orders_forward: {
    orders_managers: null,
    network: null,

    toggle_representatives: function() {
      var checked = networks.orders_forward.orders_managers.get(0).checked;
      jQuery('#orders-managers').toggle(checked);
    },

    load: function() {
      this.orders_managers = jQuery('#orders_forward_orders_managers');
      this.orders_network = jQuery('#orders_forward_network');

      this.orders_managers.change(this.toggle_representatives);
      this.orders_network.change(this.toggle_representatives);
      this.toggle_representatives();
    },
  },

  structure: {

  },

  join: {
    url: '',

    confirm: function(form) {
      jQuery(form).ajaxSubmit({dataType: 'script'})
      return false
    },

    choose: function(item) {
      item = jQuery(item)
      jQuery('#network-join').load(this.url, {enterprise_id: item.attr('data-id')})
    },

  },

  participation: {
    disassociate: function(context, url, confirm_message) {
      if (confirm(confirm_message)) {
        loading_overlay.show('#networks-participation')
        jQuery.getScript(url)
        loading_overlay.hide('#networks-participation')
      }
    }
  },
};
