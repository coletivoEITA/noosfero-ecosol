catalog = {

  form: {
    element: function () {
      return jQuery('#catalog-search')
    },
    queryEl: function() {
      return this.element().get(0).elements.query
    },
    query: function() {
      return this.queryEl().value.trim()
    },
    category: function() {
      try{ return this.element().get(0).elements.category.value.trim() } catch(e){ }
    },
    qualifier: function() {
      try{ return this.element().get(0).elements.qualifier.value.trim() } catch(e){ }
    },
    order: function() {
      try{ return this.element().get(0).elements.order.value.trim() } catch(e){ }
    },
    pageEl: function() {
      try{ return this.element().get(0).elements.page } catch(e){ }
    },
    rankEl: function() {
      try{ return this.element().get(0).elements.rank } catch(e){ }
    },
  },
  product: {
    list: function() {
      return jQuery('#product-page ul#product-list')
    },
    toggle_expandbox: function (element, open) {
      element.clicked = open;
      jQuery(element).toggleClass('open', open);
    },
    back: function (rank) {
      catalog.form.rankEl().value = rank
      catalog.search.run()
    },
  },

  categories: {
    select: function() {
    	jQuery(catalog.form.element().get(0).elements.qualifier).val('')
      catalog.search.run()
    },
  },
  qualifiers: {
    select: function() {
    	jQuery(catalog.form.element().get(0).elements.category).val('')
      catalog.search.run()
    },
  },
  order: {
    select: function() {
      catalog.search.run()
    },
  },

  search: {
  	external: false,

    init: function() {
      this.animation.init();
      this.autocomplete.init();
      this.pagination.init();
    },

    result: function (html) {
      catalog.search.replace(html)
      catalog.search.finishLoading()
    },

    url: function() {
      var pageEl = catalog.form.pageEl()
      var page = pageEl.value

      pageEl.value = null
      var url = catalog.base_url_path + jQuery(catalog.form.element()).serialize()
      pageEl.value = page

      return url;
    },

    run: function(options) {
      options = jQuery.extend({}, {animate: true}, options)

      var url = this.url()
      if (this.external) {
        window.location.href = url;
        return;
      }
      jQuery(catalog.form.element()).ajaxSubmit({
        beforeSubmit: catalog.search.startLoading,
        success: function(html) {
          if (options.animate)
            catalog.search.scroll.toTop(function() {
              catalog.search.result(html)
            })
          else
            catalog.search.result(html)
        },
      })

      window.history.pushState(url, null, url)
      catalog.form.queryEl().focus()
      catalog.search.pagination.reset()
    },

    submit: function() {
      this.run();
      return false;
    },

    startLoading: function () {
      loading_overlay.show('#product-page')
    },
    finishLoading: function () {
      loading_overlay.hide('#product-page')
      pagination.loading = false
    },

    waitEnter: function() {
      catalog.product.list().addClass('waiting')
    },
    seeResults: function() {
      catalog.product.list().removeClass('waiting')
    },

    scroll: {
      delay: 400,

      toRank: function(rank) {
        if (rank >= 0)
          jQuery(function() {
            var product = jQuery('.product[data-rank='+rank+']')
            if (product.length)
              // gives a margin for eventual fixed top bars and offset() doesn't consider margin, padding and borders sizes
              jQuery('html,body').animate({ scrollTop: product.offset().top-100 }, this.delay)
          });
      },
      toTop: function(callback) {
        jQuery('html,body').animate({ scrollTop: jQuery("#product-catalog").offset().top }, this.delay, callback)
      },
    },

    pagination: {
      init: function() {
      },

      goTo: function (page) {
        var form = catalog.form.element().get(0)
        form.elements.page.value = page
        catalog.search.run({animate: false})
      },

      load: function (url) {
        var page = /page=([^&$]+)\&?/.exec(url)[1]
        catalog.search.pagination.goTo(page)
      },

      seeMore: function(text) {
        pagination.click(function(e, link) {
          catalog.search.pagination.load(link.href)
        })
      },

      infiniteScroll: function (text) {
        pagination.infiniteScroll(text, {load: this.load});
      },

      reset: function() {
        catalog.form.element().get(0).elements.page.value = ''
      },

    },

    replace: function(results_html) {
      results_html = jQuery(results_html)
      var content = jQuery('#product-page')

      // Update filter dropdowns and number of results
      content.find('.catalog-filter-categories').empty()
        .append(results_html.find('.catalog-filter-categories .catalog-options-select'))
      content.find('.catalog-filter-qualifiers').empty()
        .append(results_html.find('.catalog-filter-qualifiers .catalog-options-select'))
      content.find('#catalog-result-qtty-wrap')
        .replaceWith(results_html.find('#catalog-result-qtty-wrap'))

      // Check if the list was loaded or if it is the first search (came from manage_products#show)
      if (content.find('#catalog-results').length) {
        //products
        results_html.find('.product').each(function(index, product) {
          product = jQuery(product)
          var old_product = content.find('#'+product.attr('id'))
          if (old_product.length) {
            old_product.attr('data-order', product.attr('data-order'))
            old_product.attr('data-rank', product.attr('data-rank'))
            old_product.attr('data-term', product.attr('data-term'))
          } else
            catalog.search.animation.container().append(product).isotope('appended', product)
        })

        //pagination
        content.find('.pagination').remove();
        content.find('#catalog-results').append(results_html.find('.pagination'))
      } else
        content.empty().append(results_html.filter('#catalog-results'))

      this.animation.run();
    },

    autocomplete: {
      url: null,
      source: null,

      init: function() {
        var input = jQuery(catalog.form.queryEl())
        this.source = new Bloodhound({
          datumTokenizer: Bloodhound.tokenizers.obj.whitespace('value'),
          queryTokenizer: Bloodhound.tokenizers.whitespace,
          remote: this.url+'&query=%QUERY',
        })
        this.source.initialize()

        input.typeahead({
            minLength: 1,
            highlight: true,
          }, {
            displayKey: 'html',
            source: this.source.ttAdapter(),
          }
        ).on('typeahead:opened', function(e) {
          catalog.search.waitEnter()
        }).on('typeahead:closed', function(e) {
          catalog.search.seeResults()
        }).on('typeahead:selected', function(e, item) {
          input.val('');
        }).on('typeahead:cursorchanged', function(e, item) {

        }).on('keyup', function(e) {
          if (e.keyCode == 13) {
            catalog.form.element().find('select').val('')
            catalog.search.run()
            input.typeahead('close')
          }
        })
        input.data('tt-typeahead')._selectOld = input.data('tt-typeahead')._select
        input.data('tt-typeahead')._select = function(datum) {
          window.location.href = datum.raw.url
          this._selectOld(datum)
        }
        input.data('tt-typeahead')._onCursorMoved = function () {
          var datum = this.dropdown.getDatumForCursor()
          this.eventBus.trigger("cursorchanged", datum.raw, datum.datasetName);
        }
      },
    },

    animation: {
      container: function () {
        return catalog.product.list()
      },
      init: function() {
        this.container().isotope({
          itemSelector: '.product',
          layoutMode: 'fitRows',
          getSortData: {
            rank: '[data-rank] parseInt',
          },
        });
      },

      filter: function(e){
        var el = jQuery(e)
        return (catalog.form.order() == el.attr('data-order')) &&
          (!catalog.form.category() || el.attr('data-category-name') == catalog.form.category()) &&
          (!catalog.form.qualifier() || (el.attr('data-qualifiers-ids') || '').indexOf(catalog.form.qualifier()) > -1) &&
          el.attr('data-term') == catalog.form.query()
      },

      run: function(){
        this.container().isotope('updateSortData').isotope();
        this.container().isotope({
          isJQueryFiltering: false,
          filter: catalog.search.animation.filter,
          sortBy: 'rank',
        })
      },
    },
  },
};

jQuery(document).click(function (event) {
  if (jQuery(event.target).parents('.expand-box').length === 0) {
    jQuery('ul#product-list .expand-box').each(function(index, element){
      catalog.product.toggle_expandbox(element, false);
    });
  }
});
jQuery('ul#product-list .expand-box').live('click', function () {
  var me = this;
  jQuery('.expand-box').each(function(index, element){
    if ( element != me ) catalog.product.toggle_expandbox(element, false);
  });
  catalog.product.toggle_expandbox(me, !me.clicked);
  return false;
});
jQuery('ul#product-list .float-box').live('click', function () {
  return false;
});

// This is to fix the catalog options bar in a way that the user can scroll down the catalog
// and still see the filters, search input and basket applet (if the shopping cart plugin is active)
jQuery(document).ready(function() {
  var catalog_w = jQuery(window);
  var catalog_catOptions = jQuery("#catalog-options");
  var catalog_originalTop = catalog_catOptions.offset().top + catalog_catOptions.height();
  var catalog_originalWidth = catalog_catOptions.width() / catalog_w.width();
  var catalog_originalLeft = catalog_catOptions.offset().left / catalog_w.width();
  jQuery(window).bind("scroll", function() {
    var catalog_originalRight = 1 - (catalog_originalLeft + catalog_originalWidth);
    var top = jQuery(window).scrollTop();
    var above_top = (top >= catalog_originalTop);
    if (above_top) {
      catalog_catOptions
        .addClass("catalog-fixed")
        .css({'padding-left': 100*catalog_originalLeft + '%',
          'padding-right': 100*catalog_originalRight + '%',
          'width': '100%'
        });
    } else {
      catalog_catOptions
        .removeClass("catalog-fixed")
        .css({'padding-left': '0',
          'padding-right': '0',
          'width': '100%'
        });
    }
  });
});
