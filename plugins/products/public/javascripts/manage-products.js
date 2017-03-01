(function($) {

  $("#manage-product-details-button").live('click', function() {
    $("#product-price-details").find('.loading-area').addClass('small-loading');
    url = $(this).attr('href');
    $.get(url, function(data){
      $("#manage-product-details-button").hide();
      $("#display-price-details").hide();
      $("#display-manage-price-details").html(data);
      $("#product-price-details").find('.loading-area').removeClass('small-loading');
    });
    return false;
  });

  $(".cancel-price-details").live('click', function() {
    if ( !$(this).hasClass('form-changed') ) {
      cancelPriceDetailsEdition();
    } else {
      if (confirm($(this).attr('data-confirm'))) {
        cancelPriceDetailsEdition();
      }
    }
    return false;
  });

  $('#manage-product-details-form').live('submit', function(data) {
     var form = this;
     $(form).find('.loading-area').addClass('small-loading');
     $(form).css('cursor', 'progress');
     var request = $.ajax(form.action, {
       type: 'POST',
       dataType: 'html',
       data: $(form).serialize()
     });
     request.done(function(data, textStatus, jqXHR) {
       $('#display-manage-price-details').html(data);
       $('#manage-product-details-button').show();
     });
     request.fail(function(jqXHR, textStatus, errorThrown) {
       log.error('manage_product_details', 'Request failed', errorThrown);
       alert('manage_product_details\nRequest failed: '+ errorThrown +
             '\n\nPlease, contact the site administrator.');
       $('#display-manage-price-details .loading-area').hide();
     });
     if ($('#progressbar-icon').hasClass('ui-icon-check')) {
       display_notice($('#progressbar-icon').attr('data-price-described-notice'));
     }
     return false;
  });

  $("#add-new-cost").live('click', function() {
    $('#display-product-price-details tbody').append($('#new-cost-fields tbody').html());
    return false;
  });

  $(".cancel-new-cost").live('click', function() {
    $(this).parents('tr').remove();
    calculateValuesForBar();
    return false;
  });

  $("#product-info-form").live('submit', function(data) {
    var form = this;
    updatePriceCompositionBar(form);
  });

  $("form.edit_input").live('submit', function(data) {
    var form = this;
    inputs_cost_update_url = $(form).find('#inputs-cost-update-url').val();
    $.get(inputs_cost_update_url, function(data){
      $(".inputs-cost span").html(data);
    });
    updatePriceCompositionBar(form);
    return false;
  });

  $("#manage-product-details-form .price-details-price").live('blur', function(data) { calculateValuesForBar(); });

  function cancelPriceDetailsEdition() {
    $("#manage-product-details-button").show();
    $("#display-price-details").show();
    $("#display-manage-price-details").html('');
  };

})(jQuery);

function updatePriceCompositionBar(form) {
  bar_url = jQuery(form).find('.bar-update-url').val();
  jQuery.ajax({
    url : bar_url,
    success : function(data) {
      jQuery("#price-composition-bar").html(data);
      var price = jQuery('#progressbar-text .product_price')
      var input_cost = jQuery('#display-product-price-details .inputs-cost span')
      if (price.length)
        jQuery('form #product_price').val(currencyToFloat(price.html(), currency_format.separator, currency_format.delimiter));
      if (input_cost.length)
        jQuery('form #product_inputs_cost').val(currencyToFloat(input_cost.html(), currency_format.separator, currency_format.delimiter, currency_format.unit));
      calculateValuesForBar();
    },
  });
}

function enablePriceDetailSubmit() {
  jQuery('#manage-product-details-form [type=submit]').prop("disabled", false).removeClass('disabled');
}

function calculateValuesForBar() {
  jQuery('.cancel-price-details').addClass('form-changed');
  var product_price = parseFloat(jQuery('form #product_price').val());
  var total_cost = parseFloat(jQuery('form #product_inputs_cost').val());

  jQuery('form .price-details-price').each(function() {
    var this_val = parseFloat(jQuery(this).val().replace(currency_format.separator, '.')) || 0;
    total_cost = total_cost + this_val;
  });
  enablePriceDetailSubmit();

  var described = (product_price - total_cost) == 0;
  var percentage = total_cost * 100 / product_price;
  priceCompositionBar(percentage, described, total_cost, product_price);
}

function new_qualifier_row(selector, select_qualifiers, delete_button) {
  index = jQuery(selector + ' tr').size() - 1;
  jQuery(selector).append("<tr><td>" + jQuery('#new-qualifier-select').html() +
                          "</td><td id='certifier-area-" + index + "'>" + jQuery('#new-qualifier-certifier').html()+
                          jQuery('#new-qualifier-remove').html() + "</td></tr>");
}


function addCommas(nStr) {
  nStr += '';
  var x = nStr.split('.');
  var x1 = x[0];
  var x2 = x.length > 1 ? '.' + x[1] : '';
  var rgx = /(\d+)(\d{3})/;
  while (rgx.test(x1)) {
    x1 = x1.replace(rgx, '$1' + ',' + '$2');
  }
  return x1 + x2;
}

function floatToCurrency(value, sep, del, cur) {
  var ret = '';
  if (cur) ret = cur + ' ';
  if (!sep) sep = '.';
  if (!del) del = ',';
  return ret + addCommas(parseFloat(value).toFixed(2).toString()).replace('.', '%sep%').replace(',', del).replace('%sep%', sep);
}

function currencyToFloat(value, sep, del, cur) {
  var val = value;
  if (cur) val = val.replace(cur + ' ', '');
  if (!sep) sep = '.';
  if (!del) del = ',';
  return parseFloat(val.replace(del, '').replace(sep, '.'));
}

function productionCostTypeChange(select, url, question, error_msg) {
  if (select.value == '') {
    var newType = prompt(question);
    if (newType) {
      jQuery.ajax({
        url: url + "/" + newType,
        dataType: 'json',
        success: function(data, status, ajax){
          if (data.ok) {
            var opt = jQuery('<option value="' + data.id + '">' + newType + '</option>');
            opt.insertBefore(jQuery("option:last", select));
            select.selectedIndex = select.options.length - 2;
            opt.clone().insertBefore('#new-cost-fields .production-cost-selection option:last');
          } else {
            alert(data.error_msg);
          }
        },
        error: function(ajax, status, error){
          alert(error_msg);
        }
      });
    }
  }
}

function priceCompositionBar(value, described, total_cost, price) {
  jQuery(function($) {
    var bar_area = $('#price-composition-bar');
    $(bar_area).find('#progressbar').progressbar({
      value: value
    });
    $(bar_area).find('.production_cost').html(floatToCurrency(total_cost, currency_format.separator, currency_format.delimiter));
    $(bar_area).find('.product_price').html(floatToCurrency(price, currency_format.separator, currency_format.delimiter));
    if (described) {
      $(bar_area).find('#progressbar-icon').addClass('ui-icon-check');
      $(bar_area).find('#progressbar-icon').attr('title', $('#progressbar-icon').attr('data-price-described-message'));
      $(bar_area).find('div.ui-progressbar-value').addClass('price-described');
    } else {
      $(bar_area).find('#progressbar-icon').removeClass('ui-icon-check');
      $(bar_area).find('#progressbar-icon').attr('title', $('#progressbar-icon').attr('data-price-not-described-message'));
      $(bar_area).find('div.ui-progressbar-value').removeClass('price-described');

    }
  });
}

function edit_input_stuff(id, currency_separator) {
   id = "input-" + id;

   jQuery(function() {
      jQuery("#" + "edit-" + id + "-form").ajaxForm({
         target: "#" + id,
         beforeSubmit: function(a,f,o) {
           o.loading = small_loading('edit-' + id + '-form');
           o.loaded = loading_done(id);
         }
      });

      jQuery("#cancel-edit-" + id).click(function() {
         jQuery("#" + id + ' ' + '.input-details').show();
         jQuery("#" + id + '-form').hide();
         jQuery('#' + id + ' .input-informations').removeClass('input-form-opened').addClass('input-form-closed');
         return false;
      });

      jQuery(".numbers-only").keypress(function(event) {
         return numbersonly(event, currency_separator)
      });

      add_input_unit(id, jQuery("#" + id + " select :selected").val())

      jQuery("#" + id + ' select').change(function() {
         add_input_unit(id, jQuery("#" + id + " select :selected").val())
      });

      jQuery("#" + id).enableSelection();
   });
}

function add_input_unit(id, selected_unit) {
   if (selected_unit != '') {
      jQuery("#" + id + ' .price-by-unit').show();
      jQuery("#" + id + ' .selected-unit').text(jQuery("#" + id + " select :selected").text());
   } else {
      jQuery("#" + id + ' .price-by-unit').hide();
   }
}

function input_javascript_ordering_stuff() {
   jQuery(function() {
      jQuery(".input-list").sortable({
         placeholder: 'ui-state-highlight',
         axis: 'y',
         opacity: 0.8,
         tolerance: 'pointer',
         forcePlaceholderSize: true,
         update: function(event, ui) {
            jQuery.post(jQuery(this).next('.order-inputs').attr('href'), jQuery(this).sortable('serialize'));
         }
      });
      jQuery(".input-list li").disableSelection();

      jQuery(".input-list li").hover(
         function() {
            jQuery(this).addClass('editing-input');
            jQuery(this).css('cursor', 'move');
         },
         function() {
            jQuery(this).removeClass('editing-input');
            jQuery(this).css('cursor', 'pointer');
         }
      );

      jQuery("#display-add-input-button > .hint").show();
   });
}

function display_input_stuff() {
   jQuery(function() {
      jQuery("#add-input-button").click(function() {
        jQuery("#display-add-input-button").find('.loading-area').addClass('small-loading');
         url = jQuery(this).attr('href');
         jQuery.get(url, function(data){
            jQuery("#" + "new-product-input").html(data);
            jQuery("#display-add-input-button").find('.loading-area').removeClass('small-loading');
            jQuery("#add-input-button").hide();
         });
         return false;
      });
   });
}

function add_input_stuff() {
   jQuery(function() {
      jQuery(".cancel-add-input").click(function() {
         jQuery("#new-product-input").html('');
         jQuery("#add-input-button").show();
         return false;
      });
      jQuery("#input-category-form").submit(function() {
         id = "product-inputs";
         jQuery(this).find('.loading-area').addClass('small-loading');
         jQuery("#input-category-form,#input-category-form *").css('cursor', 'progress');
         jQuery.post(this.action, jQuery(this).serialize(), function(data) {
            jQuery("#" + id).html(data);
         });
         return false;
      });
      jQuery('body').scrollTo('50%', 500);
   });
}

function input_javascript_stuff(id) {
   jQuery(function() {
      id = 'input-' + id;
      jQuery("#add-"+ id +"-details,#edit-"+id).click(function() {
        target = '#' + id + '-form';

        jQuery('#' + id + ' ' + '.input-details').hide();
        jQuery(target).show();

        // make request only if the form is not loaded yet
        if (jQuery(target + ' form').length == 0) {
           small_loading(id);
           jQuery(target).load(jQuery(this).attr('href'), function() {
             loading_done(id);
             jQuery('#' + id + ' .input-informations').removeClass('input-form-closed').addClass('input-form-opened');
           });
        }
        else {
           jQuery('#' + id + ' .input-informations').removeClass('input-form-closed').addClass('input-form-opened');
        }

        return false;
      });
      jQuery("#remove-" + id).unbind('click').click(function() {
         if (confirm(jQuery(this).attr('data-confirm'))) {
            url = jQuery(this).attr('href');
            small_loading("product-inputs");
            jQuery.post(url, function(data){
              jQuery("#" + "product-inputs").html(data);
              loading_done("product-inputs");
            });
         }
         return false;
      });
    });
}

