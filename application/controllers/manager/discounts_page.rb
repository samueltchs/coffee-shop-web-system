require 'date'

get "/manager/discounts" do
  @title = "Current Campaigns"
  @page = :"manager/discounts/mngr_discounts"
  @page_css = "discounts"
  @discounts = DiscountCode.get_all_active
  @show_past = false
  erb :"manager/common/mngr_template"
end

get "/manager/discounts/past" do
  @title = "Past Campaigns"
  @page = :"manager/discounts/mngr_discounts"
  @page_css = "discounts"
  @discounts = DiscountCode.get_all_inactive
  @show_past = true
  erb :"manager/common/mngr_template"
end

get "/manager/discounts/details" do
  @title = "Discount Details"
  @discount = DiscountCode[params[:viewcode]]
  redirect "/manager/discounts" unless @discount
  
  @code = @discount.discount_code
  @method = @discount.get_right_method
  @from_date = @discount.get_eligible_from_date
  @to_date = @discount.get_eligible_to_date
  @customers = @discount.get_all_eligible_customers
  @from_past = params[:from_past]
  
  erb :"manager/discounts/mngr_discount_details"
end