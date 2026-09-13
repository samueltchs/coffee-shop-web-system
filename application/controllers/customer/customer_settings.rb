get "/customer/customer-account-settings" do
  if session[:loyalty_number].nil?
    @error = "You must be logged in."
    return erb :login
  end

  customer = DB[:customers]
    .where(loyalty_number: session[:loyalty_number])
    .first

  @first_name = customer[:first_name]
  @last_name  = customer[:last_name]
  @phone_no   = customer[:phone_number]

  erb :customer_account_settings
end

post "/customer/customer-account-settings" do
  if session[:loyalty_number].nil?
    @error = "You must be logged in."
    return erb :login
  end

  first_name    = params[:first_name]
  last_name     = params[:last_name]
  phone_no      = params[:phone_no]
  password      = params[:password]
  conf_password = params[:conf_password]

  @first_name = first_name
  @last_name  = last_name
  @phone_no   = phone_no

  if first_name.nil? || first_name.strip.empty?
    @error = "First name cannot be empty."
    return erb :customer_account_settings
  end

  if last_name.nil? || last_name.strip.empty?
    @error = "Last name cannot be empty."
    return erb :customer_account_settings
  end

  if phone_no.nil? || phone_no.strip.empty?
    @error = "Phone number cannot be empty."
    return erb :customer_account_settings
  end

  update_values = {
    first_name:   first_name,
    last_name:    last_name,
    phone_number: phone_no
  }

  # record updates
  ProfileUpdate.find_and_record_updates(session[:loyalty_number], first_name, last_name, phone_no)

  if !password.nil? && !password.empty?
    if password.length < 8
      @error = "Password must be at least 8 characters long."
      return erb :customer_account_settings
    elsif password !~ /[A-Z]/
      @error = "Password must include at least one capital letter."
      return erb :customer_account_settings
    elsif password !~ /[0-9]/
      @error = "Password must include at least one number."
      return erb :customer_account_settings
    elsif password !~ /[^A-Za-z0-9]/
      @error = "Password must include at least one special character."
      return erb :customer_account_settings
    elsif password != conf_password
      @error = "Passwords do not match."
      return erb :customer_account_settings
    end

    update_values[:pass_hash] = BCrypt::Password.create(password)
    ProfileUpdate.record_new_password_update(session[:loyalty_number])
  end

  DB[:customers]
    .where(loyalty_number: session[:loyalty_number])
    .update(update_values)

  customer = DB[:customers]
    .where(loyalty_number: session[:loyalty_number])
    .first

  @first_name = customer[:first_name]
  @last_name  = customer[:last_name]
  @phone_no   = customer[:phone_number]

  @message = "Account settings updated successfully."
  erb :customer_account_settings
end