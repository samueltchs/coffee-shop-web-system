before "/shop/*" do
    if request.url.end_with?("basket") || request.url.end_with?("favourites")
        if !logged_in?
            not_logged_in_error() # redirect to login
        end
    end

    @public_path_prefix = "../"
end

before "/shop/basket/*" do
    if !logged_in?
        not_logged_in_error()
    end

    @public_path_prefix = "../../"
end

before "/shop/favourites/*" do
    if !logged_in?
        not_logged_in_error()
    end
end

# product gallery
get "/shop" do
    @products = Product.get_all_available_products()
    erb :bean_shop
end

# search and filter product gallery
get "/shop/search" do
    @search_term = (h params.fetch("search-term", "")).gsub("+", " ").strip
    @category = params.fetch("category", "both")
    @products = Product.search_products(@search_term, @category)
    erb :bean_search
end

# product page
get "/shop/product" do
    product_id = params.fetch("product_id").strip   # get id passed as query

    to_load = :product_not_found_page  # default value - will be changed to a specific page if product is found
        
    # validate the id - it should be an integer that matches an existing product_id in the db
    if product_id.to_i.to_s == product_id # if input is a string of an integer (TODO maybe check range?)
        @product = Product.get_product_by_id(product_id.to_i) # will be nil if not found
        
        if !@product.nil?    # if product exists in db  
            # if logged in, log this product view & check if favourited
            if session["logged_in"]
                RecentView.log_view(session["current_customer"].loyalty_number, @product.product_id)
                @favourited = Favourite.favourited?(session["current_customer"].loyalty_number, @product.product_id)
            end

            if @product.is_bean?
                # load bean-specific page (show roast level and origin)
                to_load = :bean_page
            else # is drink
                # load drink-specific page (with options to select milk and size)
                @milks = @product.get_milk_options_with_id()
                @sizes = @product.get_size_options_with_id()
                @selected_milk = session.fetch("milk", @milks[0].id).to_i
                @selected_size = session.fetch("size", @sizes[0].id).to_i
                @price = ProductVariant.get_price(@product.product_id, @selected_size, @selected_milk)
                to_load = :drink_page
            end
        end
    end

    erb to_load
end


# change the milk and size options for a drink
post "/shop/product/select-milk-size" do
    product = Product.get_product_by_id(params["product_id"].to_i)
    milks = product.get_milk_options_with_id()
    sizes = product.get_size_options_with_id()

    session["milk"] = params.fetch("milk", milks[0].id).to_i
    session["size"] = params.fetch("size", sizes[0].id).to_i
    redirect "/shop/product?product_id=" + params["product_id"]
end

# add product to basket
post "/shop/add-to-basket" do
    if is_logged_in()
        product_id = params["product_id"].to_i

        product = Product.get_product_by_id(product_id.to_i)
        milks = product.get_milk_options_with_id()
        sizes = product.get_size_options_with_id()

        milk_id = session.fetch("milk", milks[0].id).to_i
        size_id = session.fetch("size", sizes[0].id).to_i

        if product.is_bean?
            BasketItem.add_bean_to_basket(session["current_customer"].loyalty_number, product_id)
        else
            BasketItem.add_drink_to_basket(session["current_customer"].loyalty_number, product_id, milk_id, size_id)
        end
        # user must receive a confirmation message:
        session["added"] = true # add to session not to queries, so user doesn't access this page from browser history
        redirect "/shop/basket"
    else
        not_logged_in_error()
    end
end

# basket page
get "/shop/basket" do
    # get data
    customer = session["current_customer"]
    discount_code = session.fetch("discount", nil)
    loyalty_number = customer.loyalty_number
    @basket_entries = BasketItem.get_all_entries_by_customer(loyalty_number)
    @total_price = BasketItem.get_total_basket_price_with_discount(loyalty_number, discount_code)
    
    # decide whether to display item added message
    @added = session.fetch("added", false)
    session["added"] = false    # reset so next page load doesn't show confirmation message 

    # get potential error message
    @error = params.fetch("error", "")

    # delivery or pickup 
    # check that there is an option selected - default to pickup, and only allow pickup if the customer has ordered drinks
    @contains_drinks = BasketItem.basket_contains_drinks(loyalty_number)
    session["delivery"] = false if (session["delivery"].nil? || @contains_drinks)
    @delivery = session["delivery"]

    if @delivery
        # get current delivery details
        @address_line_1 = customer.address_line_1.nil? ? "Not Set" : customer.address_line_1
        @address_line_2 = customer.address_line_2.nil? ? "Not Set" : customer.address_line_2
        @city = customer.city.nil? ? "Not Set" : customer.city
        @postcode = customer.postcode.nil? ? "Not Set" : customer.postcode

        # change delivery details?
        @change_delivery_details = session.fetch("changing_delivery_details", false)
        session["changing_delivery_details"] = false    # reset so page refresh closes the form
    end


    erb :customer_basket
end

# post methods so can't be reached except from the basket page, which requires login 
# - don't necessarily need to check logged in

# remove this product from basket entirely
post "/shop/basket/remove" do
    basket_item = BasketItem.get_basket_item_by_id(params["basket_item_id"])
    basket_item.remove
    redirect "/shop/basket"
end

# increase quantity of product in basket by one
post "/shop/basket/increase" do
    basket_item = BasketItem.get_basket_item_by_id(params["basket_item_id"])
    product = Product.get_product_by_id(basket_item.product_id)
    if product.is_drink? || product.stock_level > (basket_item.quantity)    # stock control only works for beans
        basket_item.increase_quantity(1)
        redirect "/shop/basket"
    else
        redirect "/shop/basket?error=" + "No more stock of " + product.name + " available"
    end
end

# decrease quantity of product in basket by one
post "/shop/basket/reduce" do
    basket_item = BasketItem.get_basket_item_by_id(params["basket_item_id"])
    basket_item.reduce_quantity(1)
    redirect "/shop/basket"
end

# check & apply discount code
post "/shop/basket/discount-code" do
    code = params.fetch("code", nil)
    if !code.nil? && DiscountCode.code_exist?(code)
        # the enterred code is valid
        session["discount"] = code
    end
    redirect "/shop/basket"
end

# select delivery or pickup
post "/shop/basket/delivery-pickup-selection" do
    session["delivery"] = params["delivery-pickup-dropdown"] == "pickup" ? false : true
    redirect "/shop/basket"
end

# update delivery details
post "/shop/basket/change-delivery-details" do
    address_hash = {
        "address_line_1" => params["address_line_1"],
        "address_line_2" => params["address_line_2"],
        "city" => params["city"],
        "postcode" => params["postcode"]
    }
    session["current_customer"].set_address(address_hash)

    session["changing_delivery_details"] = false
    redirect "/shop/basket"
end

# get form to change delivery details
post "/shop/basket/request-change-delivery-details" do
    session["changing_delivery_details"] = true
    redirect "/shop/basket"
end

# purchase all items in basket, applying free coffees and discounts
post "/shop/basket/purchase" do
    customer = session["current_customer"]
    begin 
        order_id = Order.order_full_basket(customer.loyalty_number, session["delivery"], session.fetch("discount", nil)) # place order (returns order_unique_id)
        BasketItem.clear_basket(customer.loyalty_number)
        session["discount"] = nil   # remove discount code since has been used

        if order_id == -1   # error occurred when ordering
            redirect "/customer-error"
        else
            # store the last order so can display details
            session["last_order_id"] = order_id
            redirect "/shop/basket/make-payment"
        end
    rescue RuntimeError => error
        redirect "/shop/basket?error=" + error.message
    end
end

# mock payment page
get "/shop/basket/make-payment" do
    erb :customer_mock_payment_page
end

# confirm order - determine whether payment was successful
post "/shop/basket/make-payment" do
    result = params["result"].to_i
    order = Order.get_order(session["last_order_id"])
    order.set_reference_id(params["reference"])
    if result == 1
        order.mark_order_as_paid()
        order.give_stamps()
        redirect "/shop/basket/purchase-successful"
    else
        redirect "/shop/basket/purchase-failed"
    end
end

# order confirmation pages - success or fail
get "/shop/basket/purchase-successful" do
    last_order_id = session.fetch("last_order_id", nil)
    if last_order_id.nil?
        redirect "/customer-error"
    else
        @order_id = last_order_id
        @payment_reference = Order.get_order(last_order_id).reference_id
        # TODO get other info
        session["last_order_id"] = nil  # ensure this page can't be shown again (prevent user mistakenly accessing again)
        erb :customer_purchase_confirmation
    end
end

get "/shop/basket/purchase-failed" do
    last_order_id = session.fetch("last_order_id", nil)
    if last_order_id.nil?
        redirect "/customer-error"
    else
        @order_id = last_order_id
        @payment_reference = Order.get_order(last_order_id).reference_id
        # TODO get other info
        session["last_order_id"] = nil  # ensure this page can't be shown again (prevent user mistakenly accessing again)
        erb :customer_purchase_fail
    end
end

get "/shop/favourites" do
    @favourites = Favourite.get_all_favourite_items_by_customer(session["current_customer"].loyalty_number)
    erb :customer_favourites
end

post "/shop/favourites/add" do
    product_id = params.fetch("product_id").to_i
    Favourite.add_new_favourite(session["current_customer"].loyalty_number, product_id)
    redirect "/shop/product?product_id=" + product_id.to_s
end

post "/shop/favourites/remove" do
    product_id = params.fetch("product_id").to_i
    from = params.fetch("from", "favourites")
    Favourite.remove_favourite(session["current_customer"].loyalty_number, product_id)
    if from == "product"
        redirect "/shop/product?product_id=" + product_id.to_s
    else # likely from favourites page, but as backup (hence else)
        redirect "/shop/favourites"
    end
end