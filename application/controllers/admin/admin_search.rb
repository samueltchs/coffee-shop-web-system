get "/admin-search" do
  @admin_search = params.fetch("admin_search", "").strip
  @filter = params.fetch("filter", "all")
  @employees = []
  @customers = []
  @orders = []
  @title = "Admin Search"

  case @filter
  when 'customers'
    @customers_selected = true
  when 'employees'
    @employees_selected = true
  when 'orders'
    @orders_selected = true
  else
    @all_selected = true
  end

  entry = "%#{@admin_search}%"

  if @admin_search.empty?
    if @all_selected || @employees_selected
      non_deleted_employees = Employee.exclude(role: 'Deleted').all
      deleted_employees = Employee.where(role: 'Deleted').all
      @employees = order_employees(non_deleted_employees, deleted_employees)
    end

    if @all_selected || @customers_selected
      non_deleted_customers = Customer.exclude(status: 'Deleted').order(:loyalty_number).all
      deleted_customers = Customer.where(status: 'Deleted').order(:loyalty_number).all
      @customers = non_deleted_customers + deleted_customers
    end

    @orders = Order.exclude(order_fulfilment: 'Incomplete').reverse_order(:date_placed).all if @all_selected || @orders_selected
  else
    if @all_selected || @employees_selected
      employees = Employee.where(
        Sequel.|(
          Sequel.ilike(:username, entry),
          Sequel.ilike(:first_name, entry),
          Sequel.ilike(:last_name, entry),
          Sequel.ilike(:email, entry),
          Sequel.ilike(:role, entry)
        )
      )

      non_deleted_employees = employees.exclude(role: 'Deleted').all
      deleted_employees = employees.where(role: 'Deleted').all
      @employees = order_employees(non_deleted_employees, deleted_employees)
    end
  
    if @all_selected || @customers_selected
      customers = Customer.where(
        Sequel.|(
          Sequel.ilike(:loyalty_number, entry),
          Sequel.ilike(:first_name, entry),
          Sequel.ilike(:last_name, entry),
          Sequel.ilike(:phone_number, entry),
          Sequel.ilike(:email, entry),
          Sequel.ilike(:status, entry)
        )
      )

      non_deleted_customers = customers.exclude(status: 'Deleted').order(:loyalty_number).all
      deleted_customers = customers.where(status: 'Deleted').order(:loyalty_number).all
      @customers = non_deleted_customers + deleted_customers
    end

    if @all_selected || @orders_selected
      @orders = Order.where(
        Sequel.|(
          Sequel.ilike(:order_unique_id, entry),
          Sequel.ilike(:loyalty_number, entry),
          Sequel.ilike(:date_placed, entry),
          Sequel.ilike(:tracking_id, entry),
          Sequel.ilike(:reference_id, entry),
          Sequel.ilike(:barista, entry),
          Sequel.ilike(:order_fulfilment, entry),
          Sequel.ilike(:status, entry),
          Sequel.ilike(:discount_code_used, entry)
        )
      ).exclude(order_fulfilment: 'Incomplete').reverse_order(:date_placed).all
    end
  end

  erb :admin_search
end 
