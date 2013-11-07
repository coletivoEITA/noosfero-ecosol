class ExchangePluginProfileController < ProfileController

  no_design_blocks

  helper ExchangePlugin::ExchangeDisplayHelper

  def start_exchange
       
    @exchange = ExchangePlugin::Exchange.new
    @exchange.state = "proposal"
    @exchange.save!

    profile_exchange = ExchangePlugin::ProfileExchange.new
    profile_exchange.profile_id = profile.id
    profile_exchange.exchange_id = @exchange.id
    profile_exchange.role = "target"
    profile_exchange.save

    profile_exchange = ExchangePlugin::ProfileExchange.new
    profile_exchange.profile_id = @active_organization.id
    profile_exchange.exchange_id = @exchange.id
    profile_exchange.role = "origin"
    profile_exchange.save

    @proposal = ExchangePlugin::Proposal.new
    @proposal.exchange_id = @exchange.id
    @proposal.state = "open"

    @target = profile
    @origin = @active_organization

    @proposal.exchange_id = @exchange.id
    @proposal.origin_id = @origin.id
    @proposal.target_id = @target.id
    @proposal.save!

    if (params[:object_id] && params[:object_type])
      ex_el = ExchangePlugin::Element.new
      ex_el.object_id = params[:object_id]
      ex_el.object_type = params[:object_type]
      ex_el.proposal_id = @proposal.id
      ex_el.profile_id = profile.id
      ex_el.save
    end

#     ActionMailer::Base.default_url_options[:host] = request.host_with_port
#     ExchangePlugin::Mailer.deliver_start_exchange_notification @target, @origin, @exchange.id

    redirect_to :controller => "exchange_plugin_myprofile", :action => "exchange_console", :exchange_id => @exchange.id, :profile => @active_organization.identifier
  end

end
