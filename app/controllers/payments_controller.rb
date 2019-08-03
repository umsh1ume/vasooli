class PaymentsController < ApplicationController
  require 'msg91ruby'

  skip_before_action :verify_authenticity_token
  
  def index
    if params[:agent_id].present?
      @payments = Payment.where(agent_id: params[:agent_id]).sort_by(&:created_at)
    else
      @payments = Payment.all.sort_by(&:created_at)
    end

    render :json => {:payments => @payments}
  end
  
  def show
    @payment = Payment.find(params[:id])
    render :json => {:payments => @payment}
  end

  def update
    @payment = Payment.find(params[:id])
    @payment.update(payment_update_maal)
    render :json => {:payment => @payment}
  end

  def create
    maal = extract_useful_maal_from_webhook params

    payment = Payment.create(maal)

    unless payment.nil?
      send_sms(maal[:agent_id], "Payment successful. Rs #{maal[:amount]} received. Reference: #{maal[:ref]}")
    end

    render :json => {:payment => payment}
  end

  private

  def extract_useful_maal_from_webhook data
    payment = data['payload']['payment']['entity']

    rrn = payment['acquirer_data']['rrn'] rescue nil

    agent_id = payment['notes']['agent_id'] rescue nil

    maal = {
      id: payment['id'],
      amount: payment['amount'],
      ref: rrn,
      status: 'successful',
      agent_id: agent_id
    }

    maal
  end

  def payment_update_maal
    params.permit(:agent_id, :status)
  end

  def send_sms(to_number, message)
    to_number = '91'+to_number
    api = Msg91ruby::API.new("134662AUohueIqUauU585c049f","VASOOL")

    api.send(to_number, message, 2)
  end
end
