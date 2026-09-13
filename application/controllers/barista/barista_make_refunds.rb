get "/barista/make-refunds" do
  erb :barista_make_refunds

end
post "/barista/make-refunds" do

  loyalty_number = params.fetch(:entered_loyalty_number , "").strip
  @refund_reason = params.fetch(:refund_reason, "").strip
  type = params.fetch(:type, "").strip

  #Reset form when customer is changed
  if loyalty_number != params.fetch(:loyalty_number, "").strip
    params[:type] = ""
    params.delete(:order_id)
    params.delete(:item_id)
  end

  #Gets customer data
  if loyalty_number and ( !loyalty_number.to_i.zero? or loyalty_number.include?("@") )
    @customer = Customer.search_type_recognition(loyalty_number).first
  end

  if @customer
    loyalty_number = @customer.loyalty_number
  elsif !loyalty_number.empty?
    redirect "/barista/make-refunds?alert=invalid_customer"
  end


  if  params[:submit_button] == "submit"

    redirect "/barista/make-refunds?alert=reason" if @refund_reason.empty?

    if type == "Order"

      order = Order.get_order(params[:order_id])
      redirect "/barista/make-refunds?alert=invalid_order" unless order
      order.refund
      id = Refund.create_refund(loyalty_number, @refund_reason, "Resolved", params[:order_id], nil)
    
    elsif type == "Item"

      item = ItemInOrder.get_item(params[:item_id])
      redirect "/barista/make-refunds?alert=invalid_item" unless item
      FreeCoffeeRedemption.clear(item.order_unique_id) if item.quantity == 1 && item.redemption_check(item.order_unique_id)
      order_id = item.order_unique_id
      item.refund
      id = Refund.create_refund(loyalty_number, @refund_reason, "Resolved", nil, params[:item_id])

      order = Order.get_order(order_id)
      #Check if all items in an order are refunded
      order.update(status: "Refunded") if order && !order.refunded? && ItemInOrder.all_refunded?(order_id)
    
    else

      redirect "/barista/make-refunds?alert=type"

    end

    redirect "/barista/main?alert=refund_success&refund_id=#{id}"
  
  end

  erb :barista_make_refunds

end

