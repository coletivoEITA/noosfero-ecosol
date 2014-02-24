# workaround for plugin class scope problem
require_dependency 'suppliers_plugin/product_helper'

module ConsumersCoopPlugin::LayoutHelper

  protected

  include TermsHelper

  HeaderButtons = [
    [:start, 'consumers_coop_plugin.lib.layout_helper.start', proc{ profile.url }, proc{ on_homepage? }],
    [:orders, 'consumers_coop_plugin.lib.layout_helper.orders', {:controller => :consumers_coop_plugin_order, :action => :index}],
    [:adm, 'consumers_coop_plugin.lib.layout_helper.administration', {:controller => :consumers_coop_plugin_myprofile, :action => :index},
     proc{ @admin }, proc{ profile.has_admin? user }],
  ]

  def display_header_buttons
    # FIXME: call method on controller
    @admin = @controller.is_a? MyProfileController

    HeaderButtons.map do |key, label, url, selected_proc, if_proc|
      next if if_proc and !instance_eval(&if_proc)

      label = t label
      if url.is_a? Proc
        url = instance_eval &url
      else
        # necessary for profile with own domain
        url[:profile] = profile.identifier
      end

      if key != :adm and @admin
        selected = false
      elsif selected_proc
        selected = instance_eval &selected_proc
      else
        selected = params[:controller].to_s == url[:controller].to_s
      end

      link_to label, url, :class => "menu-button #{"menu-selected" if selected}"
    end.join
  end

  def consumers_coop_header
    return unless consumers_coop_enabled?
    output = render :file => 'consumers_coop_plugin_layouts/default'
    if on_homepage?
      extend SuppliersPlugin::ProductHelper
      extend OrdersPlugin::DateHelper
      output += render :file => 'orders_cycle_plugin_gadgets/cycles'
    end
    output
  end

  def consumers_coop_enabled?
    profile and profile.consumers_coop_settings.enabled
  end

  # FIXME: workaround to fix Profile#is_on_homepage?
  def on_homepage?
    profile.is_on_homepage? request.path, @page or request.path == "/profile/#{profile.identifier}"
  end

end
