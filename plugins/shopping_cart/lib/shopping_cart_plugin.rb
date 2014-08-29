class ShoppingCartPlugin < Noosfero::Plugin

  class << self
    def plugin_name
    "Shopping Basket"
    end

    def plugin_description
      _("A shopping basket feature for enterprises")
    end

    def delivery_default_setting
      false
    end

    def delivery_price_default_setting
      0
    end

    def delivery_options_default_setting
      {}
    end
  end

  def stylesheet?
    true
  end

  def js_files
    'cart.js'
  end

  def body_beginning
    lambda do
    	extend ShoppingCartPlugin::CartHelper
      render 'public/cart' unless cart_minimized
    end
  end

  def control_panel_buttons
    settings = Noosfero::Plugin::Settings.new(context.profile, ShoppingCartPlugin)
    buttons = []
    if context.profile.enterprise?
      buttons << { :title => _('Shopping basket'), :icon => 'shopping-cart-icon', :url => {:controller => 'shopping_cart_plugin_myprofile', :action => 'edit'} }
    end
    if context.profile.enterprise? && settings.enabled
      buttons << { :title => _('Purchase reports'), :icon => 'shopping-cart-purchase-report', :url => {:controller => 'shopping_cart_plugin_myprofile', :action => 'reports'} }
    end

    buttons
  end

  def add_to_cart_button item, options = {}
    profile = item.profile
    settings = Noosfero::Plugin::Settings.new(profile, ShoppingCartPlugin)
    return unless settings.enabled and item.available
    lambda do
      extend ShoppingCartPlugin::CartHelper
      add_to_cart_button item, options
    end
  end

  alias :product_info_extras :add_to_cart_button
  alias :catalog_item_extras :add_to_cart_button
  alias :asset_product_extras :add_to_cart_button

  def catalog_autocomplete_item_extras product
    add_to_cart_button product, with_text: false
  end

  def catalog_search_extras_begin
  	lambda do
    	extend ShoppingCartPlugin::CartHelper
    	content_tag 'li', render('public/cart'), :class => 'catalog-cart'
    end
  end

end
