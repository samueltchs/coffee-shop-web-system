get "/customer/refund" do
  @loyalty_number = session["loyalty_number"]
  erb :customer_refund
end

post "/customer/refund" do
  @loyalty_number = session["loyalty_number"]
  @refund_reason = params.fetch(:refund, "").strip

  if params[:submit_button] == "submit"

    if !session.fetch("logged_in", false)
      @error = "You must be logged in to request a refund."
      return erb :customer_refund
    end

    if @refund_reason.empty?
      @error = "Refund reason cannot be empty."
      return erb :customer_refund
    end

    order_id = params[:order_id]
    if order_id.nil? || order_id.strip.empty?
      @error = "Please select an order."
      return erb :customer_refund
    end

    if Refund.first(order_id: order_id, status: "Pending")
      @error = "A refund request for this order is already pending."
      return erb :customer_refund
    end

    Refund.create_refund(@loyalty_number, @refund_reason, "Pending", order_id, nil)

    @message = "Your refund request has been submitted successfully."
    @refund_reason = ""

  end

  erb :customer_refund
end