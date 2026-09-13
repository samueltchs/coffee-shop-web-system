get "/barista/generate-postage-labels" do
  erb :barista_generate_postage_labels
end

post "/barista/generate-postage-labels" do
  choice = params.fetch(:button, "").strip
  if choice == "order"
    redirect "/barista/generate-order-postage-labels"
  elsif choice == "refund"
    redirect "/barista/generate-refund-postage-labels"
  else
    redirect back
  end
end

get "/barista/generate-order-postage-labels" do
  @orders = []
  Order.get_deliverable.each do |order|
    @orders << order if order.all_items_beans?
  end
  erb :barista_generate_order_labels
end

post "/barista/assign-order-tracking-id" do
  order_id = params.fetch(:order_id, nil)
  redirect "/barista/generate-order-postage-labels" unless order_id
  order = Order.get_order(order_id)
  redirect "/barista/generate-order-postage-labels" unless order
  loop do
    candidate = generate_tracking_id
    next if Order.where(tracking_id: candidate).any?
    order.tracking_id = candidate
    order.save_changes
    break
  end
  redirect "/barista/generate-order-postage-labels?selected=#{order_id}"
end


get "/barista-send-refund-postage-label" do
  refund_id = params.fetch(:refund_id, nil)
  redirect "/barista/generate-refund-postage-labels" unless refund_id
  @refund = Refund.get_refund_by_id(refund_id)
  redirect "/barista/generate-refund-postage-labels" unless @refund
  @customer = @refund.get_customer
  redirect "/barista/generate-refund-postage-labels" unless @customer
  setup_automated_email(
    "Return Postage Label — Refund ##{@refund.refund_id}",
    "Your return postage label for refund ##{@refund.refund_id}",
    @customer.email,
    @customer.first_name
  )
  erb :"emails/barista_refund_postage_label"
end

get "/barista/generate-refund-postage-labels" do
  @loyalty_number = params.fetch(:loyalty_number, "")
  @start_date = params.fetch(:start_date, "")
  @end_date = params.fetch(:end_date, "")

  @refunds = Refund.get_pending(Refund.apply_filters(@loyalty_number, "", @start_date, @end_date))
                  .exclude(loyalty_number: nil)
                  .exclude(loyalty_number: "")
  erb :barista_generate_refund_labels
end