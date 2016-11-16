financial = {
  cycle_report: {
    toggle: function(ev) {
      $('.cycle_report').find('.header,.body,.footer').slideToggle();
    },
    add_input: function() {
      var $modal = $('.add-transaction-modal')
      $modal.find("#transaction_direction").val("in")
    },
    add_output: function() {
      var $modal = $('.add-transaction-modal')
      $modal.find("#transaction_direction").val("out")
    }
  }
}
