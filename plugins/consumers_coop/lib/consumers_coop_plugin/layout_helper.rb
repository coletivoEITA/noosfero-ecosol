module ConsumersCoopPlugin::LayoutHelper

  protected

  include TermsHelper

  HeaderButtons = {
    start: [-> { profile.url }, -> { on_homepage? }],
    orders: [{controller: :consumers_coop_plugin_order, action: :index}],
    products: [{controller: :catalog, action: :index}, nil, -> { profile.enterprise? }],
    volunteering: [{controller: :consumers_coop_plugin_volunteers, action: :index}, nil, -> { profile.volunteers_settings.cycle_volunteers_enabled }],
    administration: [{controller: :consumers_coop_plugin_myprofile, action: :index},
     -> { @admin }, -> { profile.has_admin? user }],
  }

  def display_header_buttons
    # FIXME: call method on controller
    @admin = @controller.is_a? MyProfileController

    HeaderButtons.map do |key, (url, selected_proc, if_proc)|
      next if if_proc and not instance_exec(&if_proc)

      label = t "consumers_coop_plugin.lib.layout_helper.#{key}"
      if url.is_a? Proc
        url = instance_exec &url
      else
        # necessary for profile with own domain
        url[:profile] = profile.identifier
      end

      if key != :administration and @admin
        selected = false
      elsif selected_proc
        selected = instance_exec &selected_proc
      else
        selected = params[:controller].to_s == url[:controller].to_s
      end

      link_to label, url, class: "menu-button #{"menu-selected" if selected}"
    end.join
  end

  def consumers_coop_header
    return unless consumers_coop_enabled?
    output = render file: 'consumers_coop_plugin_layouts/default'
    if on_homepage?
      extend SuppliersPlugin::ProductHelper
      extend OrdersPlugin::DateHelper
      output += render file: 'orders_cycle_plugin_gadgets/cycles'
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
