class ExchangePluginMyprofileController < MyProfileController
  no_design_blocks
  protect 'edit_profile', :profile

  helper ExchangePlugin::ExchangeDisplayHelper
  helper_method :sort_column, :sort_direction

  def index

   @exchanges = ExchangePlugin::Exchange.all.select{|ex| ex.enterprises.find(:first, :conditions => {:id => profile.id})}

   @enterprises = Enterprise.visible
    render :action => 'index'

  end

  def exchange_console
    @exchange = ExchangePlugin::Exchange.find params[:exchange_id]

    @proposals = @exchange.proposals.all(:order => "created_at desc")
    @proposal = @proposals.first

    @target = @proposal.enterprise_target
    @origin = @proposal.enterprise_origin
    @theother = @exchange.enterprises.find(:first, :conditions => ["enterprise_id != ?",profile.id])

    @theother_knowledges = CmsLearningPluginLearning.all.select{|k| k.profile.id == @theother.id} - @proposal.knowledges
    @profile_knowledges = CmsLearningPluginLearning.all.select{|k| k.profile.id == @profile.id} - @proposal.knowledges

    @profile_products = @profile.products - @proposal.products
    @theother_products = @theother.products - @proposal.products

    #css classes for the states
    if @exchange.state == "proposal"
      @state1class = "exc-plg-active"
      @state2class = "exc-plg-future"
      @state3class = "exc-plg-future"
      @state4class = "exc-plg-future"
    elsif @exchange.state == "negociation"
      @state1class = "exc-plg-past"
      @state2class = "exc-plg-active"
      @state3class = "exc-plg-future"
      @state4class = "exc-plg-future"
    elsif @exchange.state == "evaluation"
      @state1class = "exc-plg-past"
      @state2class = "exc-plg-past"
      @state3class = "exc-plg-active"
      @state4class = "exc-plg-future"
    elsif @exchange.state == "concluded"
      @state1class = "exc-plg-past"
      @state2class = "exc-plg-past"
      @state3class = "exc-plg-past"
      @state4class = "exc-plg-active"
    end
  end

  def add_element_currency
    @element = ExchangePlugin::ExchangeElement.new
    @element.element_id = params[:element_id]
    @element.enterprise_id = params[:enterprise_id]
    @element.element_type = params[:element_type]
    @element.proposal_id = params[:proposal_id]

    @element.save!

  end
  
  def add_element
#     @exchange = ExchangePlugin::Exchange.find params[:exchange_id]
    @element = ExchangePlugin::ExchangeElement.new
    @element.element_id = params[:element_id]
    @element.enterprise_id = params[:enterprise_id]
    @element.element_type = params[:element_type]
    @element.proposal_id = params[:proposal_id]

    @element.save!
  end

  def remove_element
    @element = ExchangePlugin::ExchangeElement.find params[:id]
    type = @element.element_type
    @element.destroy
#     if (type == "CurrencyPlugin::Currency")
#       render :action => "remove_element_currency"
#     end
  end

  def remove_element_currency
    @element = ExchangePlugin::ExchangeElement.find params[:id]
    @element.destroy
  end

  
  def new_message
    p = ExchangePlugin::Proposal.find params[:proposal_id]

    recipient = (p.enterprise_target_id == @active_organization.id)? p.enterprise_origin : p.enterprise_target

    @message = ExchangePlugin::Message.new_exchange_message(p, @active_organization, recipient, current_user.person, params[:body])

  end

  def close_proposal
    @proposal = ExchangePlugin::Proposal.find params[:proposal_id]
    @proposal.state = "closed"
    @proposal.date_sent = Time.now
    @proposal.save

    @proposal.exchange.state = "negociation"
    @proposal.exchange.save
#    @proposal = ExchangePlugin::Proposal.create
    #como copiar um objeto??
    redirect_to :action => 'exchange_console', :exchange_id => @proposal.exchange_id
  end

  def new_proposal
    exchange = ExchangePlugin::Exchange.find params[:exchange_id]
    proposal_last = exchange.closed_proposals.last

    @proposal = ExchangePlugin::Proposal.new
    @proposal.exchange_id = proposal_last.exchange_id
    @proposal.state = "open"

    @proposal.enterprise_origin = @active_organization
    @proposal.enterprise_target = @proposal.exchange.enterprises.select{|k| k.id != @active_organization.id}.first #not good

    @proposal.save

    proposal_last.exchange_elements.each do |ex|
      ex_el = ExchangePlugin::ExchangeElement.new
      ex_el.element_id = ex.element_id
      ex_el.element_type = ex.element_type
      ex_el.quantity = ex.quantity
      ex_el.proposal_id = @proposal.id
      ex_el.save
    end

    redirect_to :action => 'exchange_console', :exchange_id => @proposal.exchange_id
  end

  def destroy_proposal
    @proposal = ExchangePlugin::Proposal.find params[:proposal_id]
    exchange_id = @proposal.exchange_id
    @proposal.destroy

    redirect_to :action => 'exchange_console', :exchange_id => exchange_id
  end

  def destroy
    (ExchangePlugin::Exchange.find params[:exchange_id]).destroy
    redirect_to :action => 'index'
  end

  def accept
    @proposal = ExchangePlugin::Proposal.find params[:proposal_id]
    @proposal.exchange.state = "evaluation"
    @proposal.exchange.save
    @proposal.state = "accepted"
    @proposal.save

    redirect_to :action => 'exchange_console', :exchange_id => @proposal.exchange_id
  end


  def evaluate
    @exchange = ExchangePlugin::Exchange.find params[:exchange_id]
    evaluation = EvaluationPlugin::Evaluation.new
    evaluation.object_type = "ExchangePlugin::Exchange"
    evaluation.object_id = params[:exchange_id]
    evaluation.score = params[:score]
    evaluation.text = params[:text]
    evaluation.evaluator = profile
    evaluation.evaluated = @theother
    evaluation.save

    if (@exchange.evaluations.count == 2)
        @exchange.state = 'concluded'
        @exchange.concluded_at = Time.now
        @exchange.save
    end

    redirect_to :action => 'exchange_console', :exchange_id => @exchange.id

  end

  def update_quantity
    @element = ExchangePlugin::ExchangeElement.find params[:element_id]
    old_quantity = @element.quantity
    @element.quantity = params[:quantity]
    @element.save
    @exchange = ExchangePlugin::Exchange.find @element.proposal.exchange_id

#     #message
#     body = _('%{enterprise} changed the quantity of element %{element} from %{old_quantity} to %{quantity}') %
#       {:enterprise => profile.name, :element => (@element.element_type.constantize.find @element.element_id).name, :old_quantity => old_quantity, :quantity => @element.quantity}
#     m = ExchangePlugin::Message.new_exchange_message(@exchange, nil, nil, nil , body)

    render :nothing => true
  end



  #this should not be used
  def new
    @exchange = ExchangePlugin::Exchange.new
    if request.post?
      @exchange.update_attributes! params[:exchange]
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end


  def edit
    @exchange = ExchangePlugin::Exchange.find params[:id]

    @origin_elements = @exchange.exchange_elements.select{|p| p.enterprise_id == @exchange.enterprise_origin_id}
    @origin_products = @exchange.enterprise_origin.products.reject{|p| @exchange.exchange_elements.find_by_element_id p.id }
    @origin_knowledges = @exchange.enterprise_origin.articles.find(:all, :conditions => ["type = 'CmsLearningPluginLearning'"]).reject{|p| @exchange.exchange_elements.find_by_element_id p.id }

    @target_elements = @exchange.exchange_elements.select{|p| p.enterprise_id == @exchange.enterprise_target_id}
    @target_products = @exchange.enterprise_target.products.reject{|p| @exchange.exchange_elements.find_by_element_id p.id }
    @target_knowledges = @exchange.enterprise_target.articles.find(:all, :conditions => ["type = 'CmsLearningPluginLearning'"]).reject{|p| @exchange.exchange_elements.find_by_element_id p.id }
  end

  def view
    @exchange = ExchangePlugin::Exchange.find params[:id]
  end

  def console
    @exchange = ExchangePlugin::Exchange.find params[:id]
    @messages = ExchangePlugin::Message.all(:order => "created_at desc").select{|m| (m.exchange_id == @exchange.id) && (m.enterprise_sender_id != nil)}
    @system_messages = ExchangePlugin::Message.all(:order => "created_at desc").select{|m| (m.exchange_id == @exchange.id) && (m.enterprise_sender_id == nil)}

    #allowing edition
    @edit_allowed = true
    edit_not_allowed = ["proposed", "concluded", "conclusion_proposed_by_origin", "conclusion_proposed_by_target",
        "evaluated_by_target", "evaluated_by_origin", "evaluated"]

    if (edit_not_allowed.index(@exchange.state))
      @edit_allowed = false
    end

    #buttons for controlling state changes
    state_buttons = {
      "proposed" => [ [_('Accept Propose'), "happening"], [_('Don\'t Accept'), "cancel"] ],
      "conclusion_proposed_by_target" => [ [_('Exchange Concluded'), "conclude"], [_('Exchange not Concluded'), "happening"] ],
      "conclusion_proposed_by_origin" => [ [_('Exchange Concluded'), "conclude"], [_('Exchange not Concluded'), "happening"] ],
      "happening" => [ [_('Propose Conclusion'), "propose_conclusion"], [_('Cancel Exchange'), "cancel"] ],
      "concluded" => [ [_('Back to happening - this should not appear'), "happening"], [_('Cancel'), "cancel"] ],
      "cancelled" => [ [_('Back to happening - this should not appear'), "happening"], [_('Cancel'), "cancel"] ],
      "cancelled_by_target" => [ [_('Back to happening - this should not appear'), "happening"], [_('Cancel'), "cancel"] ],
      "cancelled_by_origin" => [ [_('Back to happening - this should not appear'), "happening"], [_('Cancel'), "cancel"] ]
    }
    @button = state_buttons[@exchange.state]

    #state machine for buttons and redirecting for evaluation
    if (@exchange.state == "proposed") && (!@exchange.target?(profile))
      @button = nil
      @no_button_message = _('Waiting for the other to accept the exchange proposal')

    elsif (@exchange.state == "proposed") && (@exchange.target?(profile))
      @no_button_message = _('Do you accept to start the exchange negociation?')

    elsif (@exchange.state == "happening")
      @no_button_message = _('Exchange is happening. You can send messages, edit the exchange elements, propose the conclusion of the exchange or cancel the negociation.')

    elsif (@exchange.state == "conclusion_proposed_by_origin") && (!@exchange.target?(profile))
      @button = nil
      @no_button_message = _('Waiting for a response by the other part of the exchange')

    elsif (@exchange.state == "conclusion_proposed_by_origin") && (@exchange.target?(profile))
      @no_button_message = _('The other part said that the exchange is concluded. If you agree, click Exchange Concluded.
                             If you want to continue the negotiation, click Exchange not Concluded.')

    elsif (@exchange.state == "conclusion_proposed_by_target") && (@exchange.target?(profile))
      @button = nil
      @no_button_message = _('Waiting for a response by the other part of the exchange')

    elsif (@exchange.state == "conclusion_proposed_by_target") && (!@exchange.target?(profile))
      @no_button_message = _('The other part said that the exchange is concluded. If you agree, click Exchange Concluded.
                             If you want to continue the negotiation, click Exchange not Concluded.')

    elsif (@exchange.state == "concluded")
      redirect_to :action => "evaluate", :id => @exchange.id

    elsif (@exchange.state == "evaluated_by_target") && (@exchange.target?(profile))
      ev = @exchange.evaluations.find_by_evaluator_id @exchange.enterprise_target_id
      @origin_evaluation_score = ev.score
      @origin_evaluation_desc = ev.text
      @no_button_message = _('Waiting for evaluation by the other part of the exchange')

    elsif (@exchange.state == "evaluated_by_target") && !(@exchange.target?(profile))
      redirect_to :action => "evaluate", :id => @exchange.id

    elsif (@exchange.state == "evaluated_by_origin") && !(@exchange.target?(profile))
      ev = @exchange.evaluations.find_by_evaluator_id @exchange.enterprise_origin_id
      @origin_evaluation_score = ev.score
      @origin_evaluation_desc = ev.text
      @no_button_message = _('Waiting for evaluation by the other part of the exchange')


    elsif (@exchange.state == "evaluated_by_origin") && (@exchange.target?(profile))
      redirect_to :action => "evaluate", :id => @exchange.id

    elsif (@exchange.state == "evaluated")
      @no_button_message = _('Exchange finished and evaluated')

      ev = @exchange.evaluations.find_by_evaluator_id @exchange.enterprise_origin_id
      @origin_evaluation_score = ev.score
      @origin_evaluation_desc = ev.text

      ev = @exchange.evaluations.find_by_evaluator_id @exchange.enterprise_target_id
      @target_evaluation_score = ev.score
      @target_evaluation_desc = ev.text

    end
  end

#   def evaluate
#     @exchange = ExchangePlugin::Exchange.find params[:id]
#     @origin_elements = @exchange.exchange_elements.select{|p| p.enterprise_id == @exchange.enterprise_origin_id}
#     @target_elements = @exchange.exchange_elements.select{|p| p.enterprise_id == @exchange.enterprise_target_id}
#     @enterprise_other = @exchange.target?(profile) ? @exchange.enterprise_origin : @exchange.enterprise_target
#     if request.post?
#       evaluation = EvaluationPlugin::Evaluation.new
#       evaluation.object_type = "ExchangePlugin::Exchange"
#       evaluation.object_id = params[:exchange_id]
#       evaluation.score = params[:score]
#       evaluation.text = params[:text]
#       evaluation.evaluator = profile
#       evaluation.evaluated = @enterprise_other
#       evaluation.save
#       if (@exchange.state == 'evaluated_by_target') || (@exchange.state == 'evaluated_by_origin')
#         @exchange.state = 'evaluated'
#       else
#         @exchange.state = @exchange.target?(profile) ? 'evaluated_by_target' : 'evaluated_by_origin'
#       end
#       @exchange.save
#       redirect_to :action => 'index'
#     end
#   end

#   def new_message
#     e = ExchangePlugin::Exchange.find params[:exchange_id]
#
#     recipient = (e.enterprise_target_id == profile.id)? e.enterprise_origin : e.enterprise_target
#
#     m = ExchangePlugin::Message.new_exchange_message(e, profile, recipient, current_user.person, params[:body])
#     redirect_to :action => 'console', :id => e.id
#   end

### Methods for changing exchange state ###

  def propose_conclusion
    e = ExchangePlugin::Exchange.find params[:id]
    if profile.id == e.enterprise_target_id
      e.state = "conclusion_proposed_by_target"
    else
      e.state = "conclusion_proposed_by_origin"
    end
    e.save

    #message
    body = _('Conclusion Proposed by %s') % profile.name
    m = ExchangePlugin::Message.new_exchange_message(e, nil, nil, nil , body)

    redirect_to :action => 'console', :id => params[:id]

  end

  def conclude
    e = ExchangePlugin::Exchange.find params[:id]
    e.state = "concluded"
    e.simplified_state = "concluded"
    e.save

    #message
    body = _('Exchange Concluded')
    m = ExchangePlugin::Message.new_exchange_message(e, nil, nil, nil , body)

    redirect_to :action => 'evaluate', :id => params[:id]
  end

  def cancel
    e = ExchangePlugin::Exchange.find params[:id]
    e.state = "cancelled"
    if profile.id = e.enterprise_target_id
      e.simplified_state = "cancelled_by_target"
    else
      e.simplified_state = "cancelled_by_origin"
    end
    e.save

    #message
    body = _('Exchange Cancelled by %{enterprise}') % {:enterprise => profile.name}
    m = ExchangePlugin::Message.new_exchange_message(e, nil, nil, nil , body)

    redirect_to :action => 'evaluate', :id => params[:id]
  end

  def happening
    e = ExchangePlugin::Exchange.find params[:id]
    e.state = "happening"
    e.save
    redirect_to :action => 'console', :id => params[:id]
    #this should generate a message
  end

  ## Methods for exchange elements editing###

  private

  def sort_column
    ExchangePlugin::Exchange.column_names.include?(params[:sort]) ? params[:sort] : "updated_at"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction])?params[:direction]:"desc"
  end

end
