class PaymentsController < ApplicationController
  require 'msg91ruby'

  skip_before_action :verify_authenticity_token
  
  def index
    if params[:agent_id].present?
      @payments = Payment.where(agent_id: params[:agent_id])
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
      agent_id: agent_id
    }

    maal
  end

  def send_sms(to_number, message)
    api = Msg91ruby::API.new("134662AUohueIqUauU585c049f","VASOOL")

    api.send(to_number, message, 2)
  end
end
