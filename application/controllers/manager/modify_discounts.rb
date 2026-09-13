get "/manager/create-discount" do
  @title = "Create New Discount"
  @form_action = "/manager/create-discount"
  @action = "create"
  @cancel_to = "/manager/discounts"
  @cancel_to += "/past" if params[:from_past]

  erb :"manager/discounts/mngr_discount_form"
end

post "/manager/create-discount" do
  @title = "Create New Discount"
  @form_action = "/manager/create-discount"
  @action = "create"
  @cancel_to = "/manager/discounts"
  @cancel_to += "/past" if params[:from_past]

  normalized_params = DiscountCode.normalize_params(params)
  @errors = DiscountCode.detect_input_errors(normalized_params)
  unless @errors.empty?
    erb :"manager/discounts/mngr_discount_form"
  else
    discount_code = DiscountCode.create_new_code(normalized_params)
    DiscountRedemption.distribute_to_eligible_customers
    redirect @cancel_to
  end
end

get "/manager/update-discount" do
  @title = "Update Discount"
  @form_action = "/manager/update-discount"
  @action = "update"
  
  @code = params[:viewcode].to_s
  redirect "/manager/discounts" if !DiscountCode[@code]

  @cancel_to = "/manager/discounts/details?viewcode=#{@code}"
  @cancel_to += "&from_past=yes" if params[:from_past]
  @discount = DiscountCode[@code]
  erb :"manager/discounts/mngr_discount_form"
end

post "/manager/update-discount" do
  @code = params[:viewcode].to_s
  redirect "/manager/discounts" if !DiscountCode[@code]

  @cancel_to = "/manager/discounts/details?viewcode=#{@code}"
  @cancel_to += "&from_past=yes" if params[:from_past]
  @discount = DiscountCode[@code]

  normalized_params = DiscountCode.normalize_params(params)
  @errors = DiscountCode.detect_input_errors(normalized_params)
  unless @errors.empty?
    @title = "Update Discount"
    @form_action = "/manager/update-discount"
    @action = "update"
    erb :"manager/discounts/mngr_discount_form"
  else
    @discount.update_discount(normalized_params)
    DiscountRedemption.distribute_to_eligible_customers
    redirect @cancel_to
  end
end