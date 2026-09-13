get "/barista/past-sales" do
  
  #Filter collection
  @loyalty_number = params.fetch(:loyalty_number, "")
  @barista = params.fetch(:barista, "")
  @fulfilment = params.fetch(:fulfilment, "")
  @payment_status = params.fetch(:payment_status, "")
  @payment_method = params.fetch(:payment_method, "")
  @delivery = params.fetch(:delivery, "")
  @tracking = params.fetch(:tracking, "")
  start_date = params.fetch(:start_date, "")
  end_date = params.fetch(:end_date, "")

  @orders = Order.get_complete_orders
  @orders = Order.past_sales_filtering(
    @orders,
    @barista, 
    @fulfilment, 
    @loyalty_number,
    @payment_method,
    @delivery,
    @payment_status,
    @tracking,
    start_date,
    end_date
    )

  erb :barista_past_sales
end