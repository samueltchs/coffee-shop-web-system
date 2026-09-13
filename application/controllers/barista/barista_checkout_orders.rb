get "/barista/checkout-orders" do

  @loyalty_number = params.fetch(:loyalty_number, "")
  @payment_status = params.fetch(:payment_status, "")
  @payment_method = params.fetch(:payment_method, "")
  start_date = params.fetch(:start_date, "")
  end_date = params.fetch(:end_date, "")

  @orders = Order.past_sales_filtering(
    nil,
    "",
    "Completed",
    @loyalty_number,
    @payment_method,
    "Not Delivered",
    @payment_status,
    "Handled In-Store",
    start_date,
    end_date
  )
  @orders = @orders.where(barista: nil)

  erb :barista_checkout_orders
end

post "/barista/checkout-orders" do
  order_id = params[:order_id]
  redirect "/barista/checkout-orders?selected=#{order_id}"
end

post "/barista/confirm-checkout" do
  order = Order.get_order(params[:order_id])
  if order
    if order.owed? && params[:payment_method].to_s.empty?
      redirect "/barista/checkout-orders?selected=#{params[:order_id]}&error=payment"
    end

    order.checkout(session[:username], params[:payment_method])
  end
  redirect "/barista/checkout-orders"
end