
balloon = {
  target: jQuery(),
  content: jQuery(),
  element: jQuery(),

  default_options: {delay: 0, cache: true, position: 'bellow'},
  options: {},

  _cache: {},

  /* Public API */

  hide: function () {
    balloon._hide();
    balloon.target.removeClass('balloon-target')
    balloon.target = balloon.content = jQuery();
  },

  show: function(target, content, options) {
    balloon.target = jQuery(target);
    balloon.content = content;
    balloon.target.addClass('balloon-target')

    balloon._setOptions(options);
    if (balloon.options.delay)
      setTimeout(balloon._show, balloon.options.delay);
    else
      balloon._show();
  },

  showFromGet: function(target, url, options) {
    if (balloon.options.cache && (data = balloon.cache.find(url)))
      balloon.show(target, data, options);
    else
      jQuery.get(url, function(data) {
        balloon.cache.add(url, data);
        balloon.show(target, data, options);
      });
  },

  showTitle: function (target, options) {
    var title = jQuery(target).attr('title');
    if (!options.delay) options.delay = 500;
    balloon.show(target, title, options);
  },

  cache: {
    add: function(url, data) {
      balloon.cache[url] = data;
    },

    find: function(url) {
      return balloon.cache[url];
    },
  },

  /* Internal */

  _build: function (content) {
    balloon.element = jQuery('<div class="balloon" onclick="event.preventDefault(); return false">');
    balloon.element.inner = jQuery('<div class="balloon-inner">');
    balloon.element.content = jQuery('<div class="content">');
    balloon.element.content.html(content);
    balloon.element.inner.append(balloon.element.content);
    balloon.element.append(balloon.element.inner);
    balloon.element.arrow = jQuery('<div class="arrow-wrap">');
    balloon.element.arrow.append('<div class="arrow-border arrow">').append('<div class="arrow-inner arrow">');

    balloon.target.append(balloon.element);
    balloon._position();
  },

  _position: function () {
    balloon.element.addClass(balloon.options.position);

    if (balloon.options.position == 'bellow') {
      balloon.element.prepend(balloon.element.arrow);
      balloon.element.css({
        top: balloon.target.position().top + balloon.target.height(),
      });
    } else {
      balloon.element.append(balloon.element.arrow);
      balloon.element.css({
        top: balloon.target.position().top + parseFloat(balloon.target.css('padding-top')) - balloon.element.height(),
      });
    }
    balloon.element.css({
      left: balloon.target.position().left,
      marginLeft: parseFloat(balloon.target.css('margin-left')),
      marginRight: parseFloat(balloon.target.css('margin-right')),
      marginTop: parseFloat(balloon.target.css('margin-top')),
      marginBottom: parseFloat(balloon.target.css('margin-bottom')),
    });
  },

  _show: function () {
    balloon._hide();
    balloon._build(balloon.content);
    balloon.element.show();
  },
  _hide: function () {
    balloon.element.remove();
    balloon.element = jQuery();
  },

  _setOptions: function (options) {
    balloon.options = jQuery.extend({}, balloon.default_options, options || {});
  },
};

jQuery(document).click(function (event) {
  if (event.target != balloon.target.get(0) && !jQuery(event.target).parents('.balloon-target').length)
    balloon.hide();
});

