get "/barista/daily-summary" do

  #Filter collection
  @loyalty_number = params.fetch(:loyalty_number, "")
  @fulfilment = params.fetch(:fulfilment, "")
  @payment_status = params.fetch(:payment_status, "")
  @payment_method = params.fetch(:payment_method, "")
  @delivery = params.fetch(:delivery, "")

  @orders = Order.get_complete_orders
  @orders = Order.past_sales_filtering(
    @orders,
    session[:username], 
    @fulfilment, 
    @loyalty_number,
    @payment_method,
    @delivery,
    @payment_status,
    "Handled In-Store",
    "",
    ""
    )
  @orders = Order.get_todays_orders(@orders)
  erb :barista_daily_summary

end