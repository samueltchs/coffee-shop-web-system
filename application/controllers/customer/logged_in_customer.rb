def not_logged_in_error
    error_query = URI.encode_www_form({"error": "Access Denied: Please Log In"})
    redirect "/login?" + error_query
end

def logged_in?()
    return !(session.empty?) && session["logged_in"]
end

before "/*" do
    if logged_in?()
        session["current_customer"] = Customer.get_customer(session["loyalty_number"])
    end
end

before "/customer/*" do
    if !logged_in?()
        not_logged_in_error()
    else
        @public_path_prefix = "../"
    end
end

get "/customer/dashboard" do
    cust = session["current_customer"]
    @loyalty_number = cust.loyalty_number
    @first_name = cust.first_name
    @stamps = cust.stamps
    @latest_promotion = Promotion.reverse_order(:sent_at).first(loyalty_number: cust.loyalty_number)
    @favourites = Favourite.get_all_favourite_items_by_customer(cust.loyalty_number)
    @discounts = DiscountRedemption.get_all_unredeemed_code_objects_by_customer(cust.loyalty_number)
    erb :customer_dashboard
end

get "/customer/purchase-history" do
    customer = session["current_customer"]
    @orders = Order.get_all_orders_details_by_customer(customer.loyalty_number).reverse # reverse so most recent first
    erb :customer_purchase_history
end

get "/customer/order" do
    @order_id = params.fetch("order_id", -1)
    @order = Order.get_order(@order_id)
    if @order.nil? 
        redirect "/customer-error"
    else
        @items = @order.get_all_items_in_order
    end
    erb :customer_order
end

get "/customer/account-settings" do
    erb :customer_account_settings
end

get "/customer/complaints" do
    erb :customer_complaints
end

get "/customer/ad" do
  cust = session["current_customer"]
  promotion = Promotion.reverse_order(:sent_at).first(loyalty_number: cust.loyalty_number)

  redirect "/customer/dashboard" unless promotion

  promotion_items = PromotionItem.where(promotion_id: promotion.promotion_id).all
  @top_three_items = []

  promotion_items.each do |item|
    product = Product[item.item_id]

    if product
      name = product.name
      description = product.description
      image_path = product.image_path
      price = ProductVariant.get_price(item.item_id, item.size_id, item.milk_id)
    else
      name = "Unknown"
      description = "No description and no image as you know how delicious it is.."
      image_path = "images/no-image.png"
      price = "N/A"
    end

    @top_three_items << [name, description, image_path, price, item.item_id]
  end

  @customer = cust
  @title = "Your Personalised Ad"
  @show_links = true
  erb :admin_customer_ad
end

