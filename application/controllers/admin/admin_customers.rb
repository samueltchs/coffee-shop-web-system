get "/admin-customer" do
  @customer = get_customer
  @title = title_of_user_page(@customer, "Customer Admin View")

  setup_admin_customer_page(@customer)

  erb :admin_customer
end

post "/admin-customer-suspend" do
  @customer = get_customer

  redirect "/admin-customer?loyalty_number=#{@customer.loyalty_number}" if ["Suspended", "Deleted"].include?(@customer.status)
  
  if @customer.status == "Flagged"
    @customer.suspension_reason_id = 1
  else
    @customer.suspension_reason_id = 2
  end

  @title = title_of_user_page(@customer, "Customer Admin View")
  setup_admin_customer_page(@customer)

  @customer.status = "Suspended"
  @customer.suspended_at = Time.now.utc
  @customer.save_changes

  @suspension_success = "The user has been suspended."

  erb :admin_customer
end

post "/admin-customer-delete" do
  @customer = get_customer
  
  redirect "/admin-customer?loyalty_number=#{@customer.loyalty_number}" if @customer.status != "Suspended"

  redirect "/admin-customer?loyalty_number=#{@customer.loyalty_number}" if @customer.suspension_reason_id == 1 && !three_months_since_suspended(@customer)

  deletion_reason_id = @customer.suspension_reason_id
  
  begin
    new_loyalty_no = anonymize_customer(@customer, deletion_reason_id)

    if new_loyalty_no.nil?
      @deletion_error = "Failure in deleting the customer."
    else
      @customer = Customer[new_loyalty_no]
      @deletion_success = "The customer has been deleted."
    end
  rescue
    @deletion_error = "Failure in deleting the customer."
  end

  @title = title_of_user_page(@customer, "Customer Admin View")
  @active = nil
  @inactivity_time = nil
  @four_days_since_flagged = nil
  @five_months_inactive = nil
  @three_months_since_suspended = nil
  @top_items = []

  erb :admin_customer
end

post "/admin-customer-reactivate" do
  @customer = get_customer

  if @customer.status != "Suspended" || (three_months_since_suspended(@customer) && @customer.suspension_reason_id == 1)
    redirect "/admin-customer?loyalty_number=#{@customer.loyalty_number}"
  end

  @customer.update(
    status: 'Active',
    flagged_at: nil,
    suspended_at: nil,
    suspension_reason_id: nil
  )

  LoginTime.record_new_login(@customer.loyalty_number, Time.now.utc)

  @title = title_of_user_page(@customer, "Customer Admin View")
  setup_admin_customer_page(@customer)
  @reactivation_success = "The user's account has successfully been reactivated as per their request."

  erb :admin_customer
end

post "/admin-send-ad" do
  @customer = get_customer
  top_items = ItemInOrder.get_most_frequently_bought_items(@customer.loyalty_number).first(3)

  redirect "/admin-customer?loyalty_number=#{@customer.loyalty_number}" unless top_items.length >= 3

  Promotion.create_ad_with_items(@customer.loyalty_number, top_items)

  @title = title_of_user_page(@customer, "Ad Preview")
  @top_three_items = top_items_for_ad(@customer).first(3)
  @show_links = false
  @public_path_prefix = ""

  erb :admin_customer_ad
end

get "/admin-customer-activity-logs" do
  @customer = get_customer
  @title = title_of_user_page(@customer, "Customer Activity Logs")

  loyalty_no = @customer.loyalty_number

  @time_spent = time_spent_per_week(@customer)
  @login_times = LoginTime.get_customer_login_times(loyalty_no)
  @profile_updates = ProfileUpdate.get_customer_profile_updates(loyalty_no)
  @recent_views = RecentView.get_customer_recent_views(loyalty_no)
  @favourites = Favourite.get_customer_favourites(loyalty_no)

  erb :activity_logs 
end

get "/admin-customer-purchase-history" do
  @customer = get_customer
  @title = title_of_user_page(@customer, "Customer Purchase History")
  @orders = Order.where(loyalty_number: @customer.loyalty_number).reverse_order(:date_placed).all

  erb :admin_customer_purchase_history
end

get "/admin-customer-purchasing-habits" do
  @customer = get_customer
  @title = title_of_user_page(@customer, "Customer Purchasing Habits")
  @top_items = top_items_for_habits(@customer)
  orders = Order.where(loyalty_number: @customer.loyalty_number)

  if orders.count > 0
    @average_exp = orders.avg(:price)
  else
    @average_exp = 0
  end

  erb :customer_purchasing_habits
end
