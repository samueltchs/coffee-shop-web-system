get "/customer/complaints" do
  erb :customer_complaints
end

post "/process-customer-complaint-form" do
  complaint = params[:complaint]

  if complaint.nil? || complaint.strip.empty?
    @error = "Complaint cannot be empty."
    @submitted_text_field_value = complaint
    return erb :customer_complaints
  end

  DB[:complaints].insert(
    loyalty_number: session[:loyalty_number],
    complaint_text: complaint,
    status: "pending",
    created_at: Time.now.utc.to_s
  )

  @message = "Your complaint has been submitted successfully."
  erb :customer_complaints
end