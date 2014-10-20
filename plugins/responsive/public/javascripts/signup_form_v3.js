jQuery(document).ready(function(){
    jQuery('[data-toggle=tooltip]').tooltip();
});


function verifyLoginLoad() {
  jQuery('#user_login').removeClass('available unavailable valid validated invalid checking').addClass('checking');
  jQuery('#url-check').html(jQuery('#checking-message').html());
}

function verifyLoginAjaxV3(value) {
  //verifyLoginLoad();

  jQuery.ajax({
      url: "/account/check_valid_name",
      dataType: 'json',
      data: {'identifier': encodeURIComponent(value)},
      success: function(response) {
          var user_login_alert = jQuery('#user_login_alert');
          var user_login_group = jQuery('#user_login_group');
          var user_login_help_mesg = jQuery('#user_login_help_message');
          user_login_alert.removeClass('fa fa-spin fa-spinner');

          if (response.status_class == 'validated') {
              user_login_alert.addClass('fa fa-check');
              user_login_group.addClass('has-success').removeClass('has-error');
              user_login_help_mesg.html(response.status);
          } else if (response.status_class == 'invalid') {
              user_login_alert.addClass('fa fa-warning');
              user_login_group.addClass('has-error').removeClass('has-success');
              user_login_help_mesg.html(response.status);
          }
      }
  });

  jQuery('#user_login_alert').removeClass('fa fa-check').removeClass('fa fa-warning').addClass('fa fa-spin fa-spinner');
  jQuery('#user_login_help_message').html(window.checking_login_name_message);

/*
  jQuery.get(
    ,
    ,
    function(request){
      jQuery('#user_login').removeClass('checking');
      jQuery("#url-check").html(request);
    },
    'json'
  );
  */
}

jQuery(document).ready(function(){

  window.checking_login_name_message = jQuery('#user_login_help_message').html();

  jQuery("#user_login_v3").blur(function(evt){
    evt.stopPropagation();
    evt.preventDefault();
    verifyLoginAjaxV3(this.value);
  });
});
