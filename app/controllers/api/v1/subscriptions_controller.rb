class Api::V1::SubscriptionsController < ApplicationController


  def create
    response = FakepayService.post_json('/purchase', params).body
    check_error(response)
  end

  def check_error(object)
    FakepayService.check_amount_with_plan(params)
    formatted = FakepayService.parse_json(object)
    if formatted[:success] == false
      puts "Your transaction failed due to error code: #{formatted[:error_code]}. Please check the error code description"
    elsif formatted[:success] == true
      puts "Your transaction was successfully posted!"
      Customer.store_token(formatted, params, customer_params)
    else
      puts formatted
    end
  end




  private

  def customer_params
    params.require(:customer).permit(:first_name, :last_name, :address, :city, :state, :zip)
  end


end