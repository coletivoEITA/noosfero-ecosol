class ExchangePluginProfileController < ProfileController

  no_design_blocks

  helper ExchangePlugin::ExchangeDisplayHelper

  def start_exchange
    @exchange = ExchangePlugin::Exchange.new
    @exchange.state = "proposal"
    @exchange.save!

    cross_exchange_enterprise = ExchangePlugin::ExchangeEnterprise.new
    cross_exchange_enterprise.enterprise_id = profile.id
    cross_exchange_enterprise.exchange_id = @exchange.id
    cross_exchange_enterprise.role = "target"
    cross_exchange_enterprise.save

    cross_exchange_enterprise = ExchangePlugin::ExchangeEnterprise.new
    cross_exchange_enterprise.enterprise_id = @active_organization.id
    cross_exchange_enterprise.exchange_id = @exchange.id
    cross_exchange_enterprise.role = "origin"
    cross_exchange_enterprise.save

    @proposal = ExchangePlugin::Proposal.new
    @proposal.exchange_id = @exchange.id
    @proposal.state = "open"

    @target = profile
    @origin = @active_organization

    @proposal.exchange_id = @exchange.id
    @proposal.enterprise_origin_id = @origin.id
    @proposal.enterprise_target_id = @target.id
    @proposal.save!

    if (params[:element_id] && params[:element_type])
      ex_el = ExchangePlugin::ExchangeElement.new
      ex_el.element_id = params[:element_id]
      ex_el.element_type = params[:element_type]
      ex_el.proposal_id = @proposal.id
      ex_el.enterprise_id = profile.id
      ex_el.save
    end

#     ActionMailer::Base.default_url_options[:host] = request.host_with_port
#     ExchangePlugin::Mailer.deliver_start_exchange_notification @target, @origin, @exchange.id

    redirect_to :controller => "exchange_plugin_myprofile", :action => "exchange_console", :exchange_id => @exchange.id, :profile => @active_organization.identifier
  end

end
