noosfero.comments = {

  load: function() {
    if (noosfero.comments.loaded) return
    noosfero.comments.loaded = true

    var url = $("#page_url").val()
    MessageBus.subscribe(url+'/new_comment', function (data) {
      if ($("#comment_order").val() == 'newest')
        $('.article-comments-list').prepend(data);
      else
        $('.article-comments-list').append(data);
    })

    $('.display-comment-form').unbind()
    $('.display-comment-form').click(function () {
      var $button = $(this)
      noosfero.comments.toggleBox($button.parents('.post_comment_box'))
      $($button).hide()
      $button.closest('.page-comment-form').find('input[type="text"]:visible,textarea').first().focus()
      return false
    });

    $('#cancel-comment').die()
    $('#cancel-comment').live("click", function () {
      var $button = $(this)
      noosfero.comments.toggleBox($button.parents('.post_comment_box'))
      noosfero.comments.showDisplayCommentbutton()
      var page_comment_form = $button.parents('.page-comment-form')
      page_comment_form.find('.errorExplanation').remove()
      return false
    });
  },

  toggleBox: function (div) {
    if (div.hasClass('opened')) {
      div.removeClass('opened')
      div.addClass('closed')
    } else {
      div.removeClass('closed')
      div.addClass('opened')
    }
  },

  save: function (button) {
    var $button = $(button);
    var form = $button.parents("form");
    var post_comment_box = $button.parents('.post_comment_box');
    var comment_div = $button.parents('.comments');
    var page_comment_form = $button.parents('.page-comment-form');

    open_loading(DEFAULT_LOADING_MESSAGE);
    $button.addClass('comment-button-loading');
    $.post(form.attr("action"), form.serialize(), function(data) {

      if(data.render_target == null) {
        //Comment for approval
        form.find("input[type='text']").add('textarea').each(function() {
          this.value = '';
        });
        page_comment_form.find('.errorExplanation').remove();
      } else if(data.render_target == 'form') {
        //Comment with errors
        $.scrollTo(page_comment_form);
        page_comment_form.html(data.html);
        $('.display-comment-form').hide();
      } else if($('#' + data.render_target).size() > 0) {
        //Comment of reply
        $('#'+ data.render_target).replaceWith(data.html);
        $('#' + data.render_target).effect("highlight", {}, 3000);
        noosfero.modal.close();
        noosfero.comments.incrementCommentCount(comment_div);
      } else {
        //New comment of article comes via message_bus

        form.find("input[type='text']").add('textarea').each(function() {
          this.value = '';
        });

        page_comment_form.find('.errorExplanation').remove();
        noosfero.modal.close();
        noosfero.comments.incrementCommentCount(comment_div);
      }

      if($('#recaptcha_response_field').val()){
        Recaptcha.reload();
      }

      if(data.msg != null) {
         display_notice(data.msg);
      }
      close_loading();
      noosfero.comments.toggleBox($button.closest('.post_comment_box'));
      noosfero.comments.showDisplayCommentbutton();
      $button.removeClass('comment-button-loading');
      $button.enable();
    }, 'json');
  },

  incrementCommentCount: function (comment_div) {
    comment_div.find('.comment-count').add('#article-header .comment-count').each(function() {
      var count = parseInt($(this).html());
      update_comment_count($(this), count + 1);
    });
  },

  showDisplayCommentbutton: function () {
    if($('.post_comment_box.opened').length==0)
      $('.display-comment-form').show();
  },
}

noosfero.comments.order = {

  load: function () {
    if (noosfero.comments.order.loaded) return
      noosfero.comments.order.loaded = true

    $("#comment_order").change(function () {
      var url = $("#page_url").val()
      noosfero.comments.order.send(this.value, url)
    })
  },

  send: function (order, url) {
    var container = $('#comments_list')
    container.addClass('fetching')
    $.ajax({url: url, data: {comment_order: order},
      success: function (response) {
        container.replaceWith(response)
      },
      complete: function () { container.removeClass('fetching') }
    })
  },
}

noosfero.comments.pagination = {
  load: function () {
    pagination.infiniteScroll(DEFAULT_LOADING_MESSAGE, {
      load: function (url) {
        $.get(url, function (data) {
          data = $(data)
          var newPagination = data.find('.pagination')
          var newComments = data.find('.article-comments-list .article-comment')
          pagination.showMore(newPagination, function () {
            $('.article-comments-list .article-comment:last').after(newComments);
          })

          pagination.loading = false
        })
      },
    });
  }
}

noosfero.comments.load()
