fb_app = {
  current_url: '',

  products: {
    fix_popins: function() {
      jQuery('.zoomify-image').removeClass('.zoomify-image').attr({
        onclick: 'noosfero.modal.inline(this.href); return false',
      })
    },
  },

  locales: {

  },

  config: {
    url_prefix: '',
    save_auth_url: '',
    show_login_url: '',

    init: function() {

    },

  },

  timeline: {
    app_id: '',
    //app_scope: 'publish_actions',
    app_scope: '',

    loading: function() {
      jQuery('#fb-app-connect-status').empty().addClass('loading').height(150)
    },

    connect: function() {
      this.loading();
      fb_app.fb.scope = this.app_scope
      //fb_app.fb.init(this.app_id, 'fb_app.fb.connect()')
      fb_app.fb.connect()
    },

    disconnect: function() {
      this.loading();
      fb_app.fb.disconnect()
    },

    connect_to_another: function() {
      this.loading();
      fb_app.fb.connect_to_another()
    },
  },

  page_tab: {
    app_id: '',
    next_url: '',

    init: function() {
      fb_app.modal.patchFancybox()
    },

    config: {

      init: function() {
        this.change_type($('select#page_tab_config_type'))

      },

      close: function(evt) {
       if (evt != null && evt != void 0) { evt.preventDefault(); evt.stopPropagation();}
        noosfero.modal.close()
        jQuery('#content').html('').addClass('loading')
        window.location.href = fb_app.current_url
      },

      add: function (form) {
        // this check if the user is using FB as a page and offer a switch
        FB.login(function(response) {
          var next_url = fb_app.page_tab.next_url + '?' + form.serialize()
          window.location.href = fb_app.fb.add_tab_url(fb_app.page_tab.app_id, next_url)
        })
        return false
      },

      save: function(form) {
        if (!form.find('page_tab_name').val()) {
          jQuery("#fb-app-error").text('cadê o nome?')
          return false
        } else {
          selected_type = form.find('#page_tab_config_type').val()
          if (!form.find('#config-type-'+selected_type+' input').val()) {
            jQuery("#fb-app-error").text('cadê sua seleção?')
            return false
          }
        }
        jQuery(form).ajaxSubmit()
        return false
      },

      change_type: function(select) {
        select = jQuery(select)
        var page_tab = select.parents('.page-tab')
        var config_selector = '.config-type-'+select.val()
        var config = page_tab.find(config_selector)
        var to_show = config
        var to_hide = page_tab.find('.config-type:not('+config_selector+')')

        to_show.show().
          find('input').prop('disabled', false)
        to_show.find('.tokenfield').removeClass('disabled')
        to_hide.hide().
          find('input').prop('disabled', true)
      },

      profile: {

        onchange: function(input) {
          if (input.val())
            input.removeAttr('placeholder')
          else
            input.attr('placeholder', input.attr('data-placeholder'))
        },
      },
    },

  },

  auth: {
    status: 'not_authorized',

    load: function (html) {
      jQuery('#fb-app-settings').html(html)
    },
    loadLogin: function (html) {
      if (this.status == 'not_authorized')
        jQuery('#fb-app-connect').html(html).removeClass('loading')
      else
        jQuery('#fb-app-login').html(html)
    },

    receive: function(response) {
      fb_app.fb.authResponse = response
      fb_app.auth.save(response)
    },

    transformParams: function(response) {
      var authResponse = response.authResponse
      if (!authResponse)
        return {auth: {status: response.status}}
      else
        return {
          auth: {
            status: response.status,
            access_token: authResponse.accessToken,
            expires_in: authResponse.expiresIn,
            signed_request: authResponse.signedRequest,
            provider_user_id: authResponse.userID,
          }
        }
    },

    showLogin: function(response) {
      jQuery.get(fb_app.config.show_login_url, this.transformParams(response), this.loadLogin)
    },

    save: function(response) {
      jQuery.post(fb_app.config.save_auth_url, this.transformParams(response), this.load)
    },
  },


  fb: {
    id: '',
    scope: '',

    init: function(app_id, asyncInit) {

      window.fbAsyncInit = function() {
        FB.init({
          appId: app_id,
          status: true,
          cookie: true,
          xfbml: true
        })

        fb_app.fb.size_change()
        jQuery(document).on('DOMNodeInserted', fb_app.fb.size_change)

        if (asyncInit)
          jQuery.globalEval(asyncInit)
      }
    },

    size_change: function() {
      FB.Canvas.setSize({height: jQuery('body').height()+100})
    },

    redirect_to_tab: function(pageID) {
      FB.api('/'+pageID, function(response) {
        window.location.href = response.link + '?sk=app_' + fb_app.fb.id
      })
    },

    add_tab_url: function (app_id, next_url) {
      return 'https://www.facebook.com/dialog/pagetab?' + jQuery.param({app_id: app_id, next: next_url})
    },

    connect: function() {
      FB.login(function(response) {
        fb_app.auth.receive(response)
      }, {scope: fb_app.fb.scope})
    },

    disconnect: function(callback) {
      FB.logout(function(response) {
        fb_app.auth.receive(response)
        if (callback) callback(response)
      })
    },
    connect_to_another: function() {
      this.disconnect(this.connect)
    },

    // not to be used
    delete: function() {
      FB.api("/me/permissions", "DELETE", function(response) {
        fb_app.auth.receive({status: 'not_authorized'})
      })
    },

    checkLoginStatus: function() {
      FB.getLoginStatus(function(response) {
        fb_app.auth.showLogin(response)
      })
    },

  },

  modal: {
    patchFancybox: function() {
      window.apply_zoom_to_images = function(zoom_text) {
        jQuery(function($) {
          $(window).load( function() {
            $('#article .article-body img').each( function(index) {
              var original = original_image_dimensions($(this).attr('src'));
              if ($(this).width() < original['width'] || $(this).height() < original['height']) {
                $(this).wrap('<div class="zoomable-image" />');
                $(this).parent('.zoomable-image')
                .attr({style: $(this).attr('style')})
                .addClass(this.className)
                .css({
                  width: $(this).width(),
                  height: $(this).height(),
                });
                $(this).attr('style', '');
                $(this).after('<a href="' + $(this).attr('src') + '" class="zoomify-image"><span class="zoomify-text">'+zoom_text+'</span></a>');
              }
            });
            $('.zoomify-image').fancybox({
              autoCenter: false,
              beforeShow: function() {
                var position = this.element.position();
                $.fancybox._getPosition = function() {
                  return position;
                }
              }
            })
          });
        });
      }
    },
  },
}


