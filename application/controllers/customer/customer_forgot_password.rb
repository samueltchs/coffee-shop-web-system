get "/forgot-password" do
  @title = "Forgot password"
  @error = nil

  erb :forgot_password
end

post "/forgot-password" do
  @title = "Forgot password"
  email = params.fetch("email", "").strip
  loyalty_no = params.fetch("loyalty_number", "").strip
  customer = Customer.get_customer_by_email_and_loyalty_no(email, loyalty_no)

  if customer.nil?
    @error = "No account found with those details."

    erb :forgot_password
  else
    session[:reset_loyalty_number] = customer.loyalty_number

    redirect "/customer-reset-password"
  end
end

get "/customer-reset-password" do
  redirect "/forgot-password" unless session[:reset_loyalty_number]

  @customer = Customer[session[:reset_loyalty_number]]
  @title = "Reset password"
  @errors = []
  
  erb :customer_reset_password
end

post "/customer-reset-password" do
  redirect "/forgot-password" unless session[:reset_loyalty_number]

  @customer = Customer[session[:reset_loyalty_number]]
  password = params.fetch("password", "").strip
  conf_password = params.fetch("conf_password", "").strip
  @errors = []

  if password.empty?
    @errors << "Password cannot be empty."
  elsif !valid_password?(password)
    @errors << "Password must be 8+ characters with at least 1 uppercase, 1 digit and 1 special character."
  end

  if !password.empty? && password != conf_password
    @errors << "The passwords do not match."
  end

  if @errors.empty? && @customer.correct_pass(password)
    @errors << "The new password must not be the same as the current one."
  end

  if @errors.empty?
    @customer.password = password
    Customer.where(loyalty_number: @customer.loyalty_number).update(pass_hash: @customer.pass_hash)
    @success = "Password has been reset successfully."
    session.delete(:reset_loyalty_number)
  end

  @title = "Reset password"

  erb :customer_reset_password
end
