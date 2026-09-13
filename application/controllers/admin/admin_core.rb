get "/admin-main" do
  @title = "Admin main page"
  admin = Employee.first(username: session[:username], role: 'Admin')

  redirect "/" if admin.nil?

  @first_name = admin.first_name

  non_deleted_employees = Employee.exclude(role: 'Deleted')
  non_deleted_customers = Customer.exclude(status: 'Deleted')

  @num_non_deleted_employees = non_deleted_employees.count
  @num_non_deleted_cust = non_deleted_customers.count
  @num_suspended_cust = non_deleted_customers.where(status: 'Suspended').count
  @num_orders = Order.count

  erb :admin_main
end

get "/admin-settings" do
  @title = "Admin profile"
  @admin = admin

  erb :admin_settings
end

get "/admin-inbox" do
  @title = "Admin inbox"
  @messages = admin_inbox_messages

  erb :admin_inbox
end

get "/admin-dashboard" do
  @title = "Admin Dashboard"
  @total_revenue = Order.where(status: 'Paid').sum(:price)
  @total_profit = Order.where(status: 'Paid').sum(Sequel[:price] - Sequel[:cost])
  @num_orders = Order.count
  @num_paid_orders = Order.where(status: 'Paid').count
  @num_owed_orders = Order.where(status: 'Owed').count
  @num_unpaid_orders = Order.where(status: 'Unpaid').count
  @num_active_cust = Customer.where(status: 'Active').count
  @num_flagged_cust = Customer.where(status: 'Flagged').count
  @num_suspended_cust = Customer.where(status: 'Suspended').count
  @num_deleted_cust = Customer.where(status: 'Deleted').count
  @num_baristas = Employee.where(role: 'Barista').count
  @num_managers = Employee.where(role: 'Manager').count
  @num_deleted_employees = Employee.where(role: 'Deleted').count
  @top_three_baristas = top_baristas_by_orders
  @monthly_signups = get_monthly_signups
  @monthly_orders = get_monthly_orders

  erb :admin_dashboard
end

post "/admin-update-username" do
  @admin = admin
  @title = "Admin profile"
  old_username = @admin.username
  new_username = params.fetch("username", "").strip
  @admin.old_values = { username: old_username }
  @admin.username = new_username

  if @admin.validate_username
    Employee.where(username: old_username).update(username: @admin.username)
    @admin = Employee.first(username: new_username)
    session[:username] = new_username
    @username_success = "Username updated successfully."
  else
    @admin.username = old_username
  end

  erb :admin_settings
end

post "/admin-update-email" do
  @admin = admin
  @title = "Admin profile"
  old_email = @admin.email
  @admin.old_values = { email: old_email }
  @admin.email = params.fetch("email", "").strip

  if @admin.validate_email
    Employee.where(username: @admin.username).update(email: @admin.email)
    @email_success_msg = "Email updated successfully."
  else
    @admin.email = old_email
  end

  erb :admin_settings
end

post "/admin-update-first-name" do
  @admin = admin
  @title = "Admin profile"
  old_first_name = @admin.first_name
  @admin.old_values = { first_name: old_first_name }
  @admin.first_name = params.fetch("first", "").strip

  if @admin.validate_first_name
    Employee.where(username: @admin.username).update(first_name: @admin.first_name)
    @first_name_success = "First name updated successfully."
  else
    @admin.first_name = old_first_name
  end
  
  erb :admin_settings
end

post "/admin-update-last-name" do
  @admin = admin
  @title = "Admin profile"
  old_last_name = @admin.last_name
  @admin.old_values = { last_name: old_last_name }
  @admin.last_name = params.fetch("last", "").strip
   
  if @admin.validate_last_name
    Employee.where(username: @admin.username).update(last_name: @admin.last_name)
    @last_name_success = "Last name updated successfully."
  else
    @admin.last_name = old_last_name
  end

  erb :admin_settings
end

post "/admin-change-password" do
  @admin = admin
  @title = "Admin profile"
  password = params.fetch("password", "").strip
  conf_password = params.fetch("conf_password", "").strip

  if !password.empty?
    @admin.pass = password
    @admin.conf_pass = conf_password
  
    if @admin.validate_password
      @admin.password = @admin.pass
      Employee.where(username: @admin.username).update(pass_hash: @admin.pass_hash)
      @pass_success_msg = "Password has been updated successfully."
    else
      @warning = "Password not updated. Requirements not met."
    end
  end

  erb :admin_settings
end
