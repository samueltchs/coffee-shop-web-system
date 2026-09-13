require_relative '../../helpers/local_helpers'

before "/*" do
  if @public_path_prefix.nil?
    @public_path_prefix = ""
  end
end

def is_logged_in()
  session["logged_in"]
end

get "/" do
  if is_logged_in
    redirect "/customer/dashboard"
  else
    redirect "/customer-landing-page"
  end
end

get "/login" do
  if is_logged_in
    redirect "/customer/dashboard"
  elsif session[:username]
    case session[:role]
    when "Barista"
      redirect "/barista/main"
    when "Admin"
      redirect "/admin-main"
    when "Manager"
      redirect "/manager/dashboard"
    end
  else
    @title = "Badly Brewed Coffee"
    @error = params.fetch("error", "").strip
    erb :customer_login
  end
end

post "/login" do
  @email = params.fetch("email", "").strip
  @pass = params.fetch("password", "").strip

  # log in:
  cust = Customer.login(@email, @pass)
  if cust.nil?
    @error = "Invalid login credentials"
  elsif cust.status == "Suspended"
    @error = "Your account has been suspended due to inactivity. Please check your emails."
  else
    session["logged_in"] = true
    session["loyalty_number"] = cust.loyalty_number
    LoginTime.record_new_login(cust.loyalty_number, Time.now.utc)
    redirect "/customer/dashboard"
  end
  
  @title = "Badly Brewed Coffee"
  erb :customer_login
end

get "/sign-up" do
  if is_logged_in
    redirect "/customer/dashboard"
  else
    @title = "Badly Brewed Coffee"
    @form_submitted = false
    erb :customer_sign_up
  end
end

post "/sign-up" do
  @form_submitted = true
  @first_name = params.fetch("first", "").strip
  @last_name = params.fetch("last", "").strip
  @phone_no = params.fetch("phone", "").strip
  @email = params.fetch("email", "").strip
  @pass = params.fetch("password", "").strip
  @conf_pass = params.fetch("conf_password", "").strip

  @first_name_error = case
  when @first_name.empty?
    "Please enter your first name"
  when !valid_name_capitalization?(@first_name)
    "First name must start with a capital letter"
  when !valid_name_format?(@first_name)
    "First name must contain only letters, hyphens, apostrophes and spaces"
  end

  @last_name_error = case
  when @last_name.empty?
    "Please enter your last name"
  when !valid_name_capitalization?(@last_name)
    "Last name must start with a capital letter"
  when !valid_name_format?(@last_name)
    "Last name must contain only letters, hyphens, apostrophes and spaces"
  end

  @phone_no_error = "Please enter a valid phone number" unless str_uk_telephone?(@phone_no)
  @email_error = "Please enter a valid email address" unless str_email_address?(@email)
  @pass_mismatch_error = "The two passwords are not the same" if @pass != @conf_pass
  @pass_error = "Please enter a valid password" unless valid_password?(@pass)

  if @first_name_error.nil? && @last_name_error.nil? && @phone_no_error.nil? &&
        @email_error.nil? && @pass_mismatch_error.nil? && @pass_error.nil?
    begin 
      cust = Customer.create_account(@first_name, @last_name, @phone_no, @email, @pass)
      @loyalty_number = cust.loyalty_number
    rescue ArgumentError => e 
      @warning = "An account with that email already exists - Please Log In"
    end
  else
    @warning = "Please enter valid details"
  end
  
  erb :customer_sign_up
end

get "/logout" do
  session.clear
  redirect "/customer-landing-page"
end
