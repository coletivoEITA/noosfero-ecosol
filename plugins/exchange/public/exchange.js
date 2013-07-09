
exchange = {

  add_unregistered_item_show_form: function (enterprise) {
    var e = document.getElementById('exchange-add-money' + '-' + enterprise);
    e.className = 'action-button exchange-add-money-active'
      var e = document.getElementById('exchange-add-unreg-item' + '-' + enterprise);
    e.className = 'action-button exchange-add-unreg-item-active';
  },

  add_unregistered_item_hide_form: function (enterprise) {
    var e = document.getElementById('exchange-add-money' + '-' + enterprise);
    e.className = 'action-button exchange-add-money';
    var e = document.getElementById('exchange-add-unreg-item' + '-' + enterprise);
    e.className = 'action-button exchange-add-unreg-item';
  },
};