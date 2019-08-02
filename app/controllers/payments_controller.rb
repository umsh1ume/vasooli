class PaymentsController < ApplicationController
  
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
    payment = Payment.create(payment_params)

    redirect_to payments_path
  end

  private
  def payment_params
    params.require(:payment).permit(:amount, :agent_id, :ref)
  end
end
