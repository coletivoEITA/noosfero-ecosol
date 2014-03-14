
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
    add_supplier: function(html) {
      jQuery("#network-suppliers").append(html);
      jQuery.colorbox.close();
    },

    add_node: function(html) {
      jQuery("#network-nodes").append(html);
      jQuery.colorbox.close();
    },

  }
};
