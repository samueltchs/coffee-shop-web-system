get "/barista/search-customer" do
  @entered_text = params.fetch(:search_field, "")
  @matched_customers = Customer.search_type_recognition(@entered_text)
  erb :barista_search_customer
end
  #session[:cust_search_filter] = params[:search_field]   
post "/barista/add-stamps" do
  filter_maintenance = params[:filter_maintenance]
  stamp_action = params.fetch("stamp_button", "")
  loyalty_number = params[:customer_loyalty_number]
  amount = params.fetch("stamp_amount_field", 0)
  Customer.add_subtract_stamps(loyalty_number, stamp_action, amount)
  redirect "barista/search-customer?search_field=#{filter_maintenance}"
end
