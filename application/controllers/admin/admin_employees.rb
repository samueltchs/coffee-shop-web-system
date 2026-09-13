get "/admin-employee" do
  @employee = employee
  @title = title_of_user_page(@employee, "Employee Admin View")
  @has_orders = Order.where(barista: @employee.username).count > 0

  erb :admin_employee
end

get "/admin-add-employee" do
  @title = "Register Employee"
  @employee = Employee.new
  @form_submitted = false

  erb :add_employee
end

post "/admin-add-employee" do
  @title = "Register Employee"
  @form_submitted = true
  @employee = Employee.new
  @employee.load(params)

  if @employee.valid?
    @employee.registered_time = Time.now.utc
    @employee.deleted_at = nil
    @employee.save_changes
    @warning = nil
  else
    @warning = "Failure in registering the employee. Please provide valid details."
  end

  erb :add_employee
end

post "/admin-employee-reset-password" do    
  @employee = employee
  @title = title_of_user_page(@employee, "Employee Admin View")
  password = params.fetch("password", "").strip
  conf_password = params.fetch("conf_password", "").strip

  if !password.empty? && @employee
    @employee.pass = password
    @employee.conf_pass = conf_password
  
    if @employee.validate_password
      @employee.password = @employee.pass
      Employee.where(username: @employee.username).update(pass_hash: @employee.pass_hash)
      @pass_success_msg = "Password has been updated successfully."
    else
      @warning = "Password not updated. Requirements not met."
    end
  end

  erb :admin_employee
end

post "/admin-employee-delete" do
  @employee = employee
  has_orders = Order.where(barista: @employee.username).count > 0

  if has_orders
    begin
      new_username = anonymize_employee(@employee)

      if new_username.nil?
        @deletion_error = "Failure in deleting the employee."
      else
        @employee = Employee[new_username]
        @deletion_success = "The former employee's account has been deleted successfully."
      end
    rescue
      @deletion_error = "Failure in deleting the employee."
    end

    @title = title_of_user_page(@employee, "Employee Admin View")
    @has_orders = true

    erb :admin_employee
  else
    @employee.delete
    delete_employee_success
  end
end

get "/admin-employee-orders" do
  @employee = employee
  @title = title_of_user_page(@employee, "Orders Fulfilled")
  @orders = Order.where(barista: @employee.username).reverse_order(:date_placed).all

  erb :admin_barista_orders
end

post "/admin-access-employee-account" do
  employee_to_view = employee

  session[:view_employee] = employee_to_view.username

  case employee_to_view.role
  when "Barista"
    redirect "/barista/main"
  when "Manager"
    redirect "/manager/dashboard"
  else
    redirect "/admin-main"
  end
end

get "/admin-stop-viewing" do
  employee_username = session[:view_employee]

  session.delete(:view_employee)

  if employee_username && Employee[employee_username]
    redirect "/admin-employee?username=#{employee_username}"
  else
    redirect "/admin-main"
  end
end
