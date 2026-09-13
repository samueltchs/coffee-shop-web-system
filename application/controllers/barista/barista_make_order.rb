get "/barista/make-order" do
  #Creates order if it hasn't already been created
  if session[:order_id].nil?
      @order = Order.create_order(session[:username])
      session[:order_id] = @order.order_unique_id
  else
      @order = Order.get_order(session[:order_id])
  end
  @order_id = session[:order_id]

  #Applies the customers loyalty number
  customer_id = session[:loyalty_number]
  if customer_id
      @order.set_customer(customer_id) 
      @customer = Customer.search_customer_by_loyalty_number(customer_id).first
  else
      @customer = Customer.search_customer_by_loyalty_number(@order.get_customer).first
  end

  @all_products = Product.get_all_products
  @added_items = @order.get_all_items_in_order
  erb :barista_make_order
end

post "/barista/search-customer-by-loyalty-number" do
  loyalty_number = params.fetch(:entered_loyalty_number , "-1")
  if loyalty_number != -1 and ( !loyalty_number.to_i.zero? or loyalty_number.include?("@") )
      customer = Customer.search_type_recognition(loyalty_number).first 
  end
  session[:loyalty_number] = customer.loyalty_number if customer 
  FreeCoffeeRedemption.clear(session[:order_id])
  redirect back
end

post "/barista/add-drink" do
  order_id = session[:order_id]
  added_item = params[:item_to_be_added]
  amount = params[:amount_of_items]
  milk_type = params.fetch(:milk_type, "")
  milk_type = MilkOption.get_id(milk_type) unless milk_type.strip.empty?
  size = params.fetch(:size, "")
  size = Size.get_id(size) unless size.strip.empty?
  if amount.nil? || amount.eql?("")
    amount = 1
  end
  ItemInOrder.add_drink_to_order(order_id, added_item, amount.to_i, milk_type, size) if amount.to_i >= 1
  redirect back
end 

post "/barista/add-beans" do
  order_id = session[:order_id]
  added_item = params[:item_to_be_added]
  amount = params[:amount_of_items]
  product = Product.first(product_id: added_item)

  if amount.nil? || amount.eql?("")
      amount = 1
  end
  ItemInOrder.add_beans_to_order(order_id, added_item, amount.to_i) if amount.to_i >= 1
  redirect "/barista/make-order"
end

post "/barista/remove-item" do
  item_id = params[:remove_item]
  amount = params[:amount_of_items]
  if amount == ""
    amount = 1
  end
  FreeCoffeeRedemption.clear(session[:order_id]) if ItemInOrder.remove(item_id, amount.to_i)
  redirect "barista/make-order"
end

post "/barista/claim-stamps" do
  customer = Customer.search_type_recognition(session[:loyalty_number]).first
  redirect back unless customer
  customer_id = customer.loyalty_number 
  redemption_order = Order.get_order(session[:order_id])
  drink = redemption_order.get_most_expensive_drink

  redirect back if drink.nil? || Customer.get_amount_of_stamps(customer_id) < 9

  FreeCoffeeRedemption.redeem(drink, customer_id)
  Customer.add_subtract_stamps(customer_id, '-', 9)
  redirect "barista/make-order"
end


post "/barista/cancel-order" do
  Order.cleanup(session[:username])
  session.delete(:order_id)
  session.delete(:loyalty_number)
  redirect "/barista/main"
end

#Since no 3rd party API is used, the order will be noted as complete
post "/barista/submit-order" do
  order = Order.get_order(session[:order_id])
  redirect "/barista/make-order?error=empty" unless order.get_all_items_in_order
  payment_method = params[:payment_method]
  Customer.add_subtract_stamps(session[:loyalty_number], '+', 1)
  order.submit(payment_method, generate_unique_reference_id)
  redirect "/barista/main?alert=order_success&order_id=#{session[:order_id]}"
end