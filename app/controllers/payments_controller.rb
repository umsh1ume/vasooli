class PaymentsController < ApplicationController
  require 'msg91ruby'
  require 'plivo'

  include Plivo

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
      send_sms(maal[:agent_id], "Kharcha paani received, ₹ #{maal[:amount].to_i/100}. Vasooli done. Reference: #{maal[:ref]}")
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
      status: 'success',
      agent_id: agent_id
    }

    maal
  end

  def payment_update_maal
    params.permit(:agent_id, :status)
  end

  def send_sms(to_number, message)
    number = '91'+to_number
    client = RestClient.new('MAZWY1NTFLNDU4MTBJYT', 'ZDkwNjU1ZWI5NmVmNDZiMzRhY2FkNTVkNTFlZTA1');

    api = Msg91ruby::API.new("288075AWvx2zmpUin5d454201","VASOOL")
    api.send(number, message, 2)

    team_numbers = [
      '919867582068',
      '917622950688',
      '919897729069',
      '919823967243',
      '919480601864'
    ]

    message_created = client.messages.create(
      '101010',
      team_numbers,
      message
    )
  end
end
