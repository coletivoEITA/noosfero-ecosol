

exchange = {

  add_unregistered_item_show_form: function (enterprise) {
    var money = jQuery('exchange-add-money-'+enterprise);
    var unreg = jQuery('exchange-add-unreg-item-'+enterprise);
    money.addClass('exchange-add-money-active');
    unreg.addClass('exchange-add-unreg-item-active');
  },

  add_unregistered_item_hide_form: function (enterprise) {
    var money = jQuery('exchange-add-money-'+enterprise);
    var unreg = jQuery('exchange-add-unreg-item-'+enterprise);
    money.revomeClass('exchange-add-money-active');
    unreg.removeClass('exchange-add-unreg-item-active');
  },
};
