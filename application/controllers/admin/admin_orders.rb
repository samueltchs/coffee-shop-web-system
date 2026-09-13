get "/admin-order" do
  @order = order
  @title = title_of_order_page(@order)
  @products = products_of_an_order(@order)

  erb :admin_order
end

post "/admin-payment-reference-id" do
  @order = order

  redirect "/admin-order?order_id=#{@order.order_unique_id}" if @order.status != "Unpaid"

  @title = title_of_order_page(@order)
  old_reference_id = @order.reference_id
  @order.old_values = { reference_id: old_reference_id }
  @order.reference_id = params.fetch("reference_id", "").strip

  if @order.validate_reference_id
    Order.where(order_unique_id: @order.order_unique_id).update(reference_id: @order.reference_id)
    @reference_id_success = "The payment has been successfully verified. Please proceed with marking the order as paid."
  else
    @order.reference_id = old_reference_id
  end

  @products = products_of_an_order(@order)

  erb :admin_order
end

post "/admin-change-order-status" do
  @order = order
  @title = title_of_order_page(@order)
  old_status = @order.status
  @order.old_values = { status: old_status }
  @order.status = params.fetch("status", "").strip
  reason_note = params.fetch("reason_note", "").strip

  @audit_note = OrderStatusAudit.create_audit_note(
    @order.order_unique_id,
    old_status,
    @order.status,
    reason_note,
    session[:username]
  )

  if @order.validate_status && @audit_note.valid?
    Order.where(order_unique_id: @order.order_unique_id).update(status: @order.status)
    @audit_note.save_changes
    @order_status_success = "The order's status has been updated successfully."
  else
    @order.status = old_status
  end

  @products = products_of_an_order(@order)

  erb :admin_order
end
