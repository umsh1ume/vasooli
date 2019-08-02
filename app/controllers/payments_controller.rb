class PaymentsController < ApplicationController
  
  def index
    puts "index"
    @payments = Payment.all
    render :json => {:payments => @payments}
  end
  
  def show
    puts "show"
    @payment = Payment.find(agent_id: params[:agent_id])
    render :json => {:payments => @payment}
  end

  def new
    puts "new"
    @payment = Payment.new
  end

  def create
    puts "create"
    payment = Payment.create(payment_params)

    redirect_to payments_path
  end

  private
  def payment_params
    params.require(:payment).permit(:amount, :agent_id, :ref)
  end
end
