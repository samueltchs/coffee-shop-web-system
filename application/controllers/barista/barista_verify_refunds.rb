get "/barista/verify-refunds" do
  @loyalty_number = params.fetch(:loyalty_number, "")
  @start_date = params.fetch(:start_date, "")
  @end_date = params.fetch(:end_date, "")
  @refund_status = params.fetch(:refund_status, "")

  @refunds = Refund.apply_filters(@loyalty_number, @refund_status, @start_date, @end_date)

  @pending_refunds = Refund.get_pending(@refunds)
  @resolved_refunds = Refund.get_resolved(@refunds)
  @denied_refunds = Refund.get_denied(@refunds)
  erb :barista_verify_refunds
end

post "/barista/verify-refund" do
  refund_id = params.fetch("refund_id", "").strip
  choice = params.fetch("choice", "").strip
  refund = Refund.get_refund_by_id(refund_id)

  if choice == "approve" if refund
    refund.approve
  elsif choice == "deny"
    refund.deny
  end
  redirect "/barista/verify-refunds"
end