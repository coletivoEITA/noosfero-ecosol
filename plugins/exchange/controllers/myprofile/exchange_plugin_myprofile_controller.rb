
class ExchangePluginMyprofileController < MyProfileController
  no_design_blocks
  protect 'edit_profile', :profile

  helper ExchangePluginDisplayHelper
  helper_method :sort_column, :sort_direction 

  def index
    @exchanges = ExchangePlugin::Exchange.all(:order => sort_column + " " + sort_direction, 
                        :conditions => ["enterprise_target_id = ? OR enterprise_origin_id = ? ", profile.id, profile.id], :include => :evaluations)
    @enterprises = Enterprise.visible
    render :action => 'index'
    
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

  def destroy
    (ExchangePlugin::Exchange.find params[:id]).destroy
    redirect_to :action => 'index'
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

  def evaluate
    @exchange = ExchangePlugin::Exchange.find params[:id]
    @origin_elements = @exchange.exchange_elements.select{|p| p.enterprise_id == @exchange.enterprise_origin_id}
    @target_elements = @exchange.exchange_elements.select{|p| p.enterprise_id == @exchange.enterprise_target_id}
    @enterprise_other = @exchange.target?(profile) ? @exchange.enterprise_origin : @exchange.enterprise_target
    if request.post?
      evaluation = EvaluationPlugin::Evaluation.new
      evaluation.object_type = "ExchangePlugin::Exchange"
      evaluation.object_id = params[:exchange_id]
      evaluation.score = params[:score]
      evaluation.text = params[:text]
      evaluation.evaluator = profile
      evaluation.evaluated = @enterprise_other  
      evaluation.save
      if (@exchange.state == 'evaluated_by_target') || (@exchange.state == 'evaluated_by_origin')
        @exchange.state = 'evaluated'
      else
        @exchange.state = @exchange.target?(profile) ? 'evaluated_by_target' : 'evaluated_by_origin'
      end
      @exchange.save
      redirect_to :action => 'index'
    end
  end

  def new_message
    e = ExchangePlugin::Exchange.find params[:exchange_id]

    recipient = (e.enterprise_target_id == profile.id)? e.enterprise_origin : e.enterprise_target

    m = ExchangePlugin::Message.new_exchange_message(e, profile, recipient, current_user.person, params[:body])
    redirect_to :action => 'console', :id => e.id
  end

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

  def add_element
    @exchange = ExchangePlugin::Exchange.find params[:exchange_id]
    @enterprise = params[:enterprise]
    @element = ExchangePlugin::ExchangeElement.new
    @element.element_id = params[:element_id]
    @element.enterprise_id = params[:enterprise_id]
    @element.element_type = params[:element_type]
    @element.quantity = nil 
    @element.exchange_id = @exchange.id
    @element.save!
  
    #message
    body = _('%{enterprise} added a new element to the exchange: %{element}') % {:enterprise => profile.name, :element => (@element.element_type.constantize.find @element.element_id).name} 
    m = ExchangePlugin::Message.new_exchange_message(@exchange, nil, nil, nil , body)
  end

  def remove_element
    @enterprise = params[:enterprise]
    @element = ExchangePlugin::ExchangeElement.find params[:element_id]
    @exchange = ExchangePlugin::Exchange.find params[:exchange_id]    
   
    #message
    body = _('%{enterprise} removed an element from the exchange: %{element}') % {:enterprise => profile.name, :element => (@element.element_type.constantize.find @element.element_id).name} 
    m = ExchangePlugin::Message.new_exchange_message(@exchange, nil, nil, nil , body)

    @element.destroy
  end

  def update_quantity
    @element = ExchangePlugin::ExchangeElement.find params[:element_id]
    old_quantity = @element.quantity
    @element.quantity = params[:quantity]
    @element.save
    @exchange = ExchangePlugin::Exchange.find @element.exchange_id   

    #message
    body = _('%{enterprise} changed the quantity of element %{element} from %{old_quantity} to %{quantity}') % 
      {:enterprise => profile.name, :element => (@element.element_type.constantize.find @element.element_id).name, :old_quantity => old_quantity, :quantity => @element.quantity} 
    m = ExchangePlugin::Message.new_exchange_message(@exchange, nil, nil, nil , body)
   
    render :nothing => true
  end


  private 

  def sort_column 
    ExchangePlugin::Exchange.column_names.include?(params[:sort]) ? params[:sort] : "updated_at"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction])?params[:direction]:"desc"
  end
  
end
