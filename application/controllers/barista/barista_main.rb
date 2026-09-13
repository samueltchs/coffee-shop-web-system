get "/barista/main" do
    session.delete(:cust_search_filter)
    if params[:alert] == "order_success"
        params[:alert] = nil unless(   
        Order.get_order(session[:order_id]) 
        &&
        (Customer.search_customer_by_loyalty_number(session[:loyalty_number]) 
        ||
        !session[:loyalty_number])
        )
        session.delete(:order_id)
        session.delete(:loyalty_number)
    end
    erb :barista_main
end

post "/barista/main" do
    button = params[:button]
    case button
    when "make_order"
        redirect "/barista/make-order"
    when "checkout_orders"
        redirect "/barista/checkout-orders"
    when "search_customer"
        redirect "/barista/search-customer"
    when "past_sales"
        redirect "/barista/past-sales"
    when "daily_summary"
        redirect "/barista/daily-summary"
    when "verify_refunds"
        redirect "/barista/verify-refunds"
    when "make_refund"
        redirect "/barista/make-refunds"
    when "generate_postage_labels"
        redirect "/barista/generate-postage-labels"
    end 
end
