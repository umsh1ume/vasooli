class PaymentsController < ApplicationController
  
  def index
    if params[:agent_id].present?
      @payments = Payment.find_by(agent_id: params[:agent_id])
    else
      @payments = Payment.all
    end

    render :json => {:payments => @payments}
  end
  
  def show
    @payment = Payment.find(params[:id])
    render :json => {:payments => @payment}
  end

  def new
    @payment = Payment.new
  end

  def create
    maal = extract_useful_maal_from_webhook params

    payment = Payment.create(maal)

    render :json => {:payment => payment}
  end

  private

  def extract_useful_maal_from_webhook data
    payment = data['payload']['payment']['entity']

    maal = {
      id: payment['id'],
      amount: payment['amount'],
      ref: payment['acquirer_data']['rrn'] rescue nil,
      agent_id: payment['notes']['agent_id'] rescue nil,
    }

    maal
  end
end
