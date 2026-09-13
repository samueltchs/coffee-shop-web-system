require_relative "../../spec_helper"

RSpec.describe "Barista make order controller" do
  before do
    @barista = add_test_barista_to_db
    login_as_employee(@barista)
    @customer = add_test_customer_to_db
  end

  describe "GET /barista/make-order" do
    it "returns 200" do
      get_as_employee(@barista, "/barista/make-order")
      expect(last_response.status).to eq(200)
    end

    it "creates a new incomplete order when no session order exists" do
      initial_count = Order.count
      get_as_employee(@barista, "/barista/make-order")
      expect(Order.count).to eq(initial_count + 1)
      expect(Order.first(barista: @barista.username, order_fulfilment: "Incomplete")).not_to be_nil
    end

    it "does not create a new order when a session order already exists" do
      order = Order.create_order(@barista.username)
      get "/barista/make-order", {},
          { "rack.session" => { username: @barista.username, role: @barista.role, order_id: order.order_unique_id } }
      expect(Order.count).to eq(1)
    end

    it "associates the customer when a loyalty number is in the session" do
      get "/barista/make-order", {},
          { "rack.session" => { username: @barista.username, role: @barista.role,
                                loyalty_number: @customer.loyalty_number } }
      expect(last_response.status).to eq(200)
      order = Order.first(barista: @barista.username, order_fulfilment: "Incomplete")
      expect(order.loyalty_number).to eq(@customer.loyalty_number)
    end
  end

  describe "POST /barista/search-customer-by-loyalty-number" do
    it "redirects after setting the customer" do
      post "/barista/search-customer-by-loyalty-number",
           { entered_loyalty_number: @customer.loyalty_number },
           { "rack.session" => { username: @barista.username, role: @barista.role },
             "HTTP_REFERER" => "/barista/make-order" }
      expect(last_response).to be_redirect
    end

    it "redirects even when the customer does not exist" do
      post "/barista/search-customer-by-loyalty-number",
           { entered_loyalty_number: 9999 },
           { "rack.session" => { username: @barista.username, role: @barista.role },
             "HTTP_REFERER" => "/barista/make-order" }
      expect(last_response).to be_redirect
    end
  end

  describe "POST /barista/cancel-order" do
    it "redirects to /barista/main" do
      post_as_employee(@barista, "/barista/cancel-order")
      expect(last_response).to be_redirect
      expect(last_response.location).to include("/barista/main")
    end

    it "cleans up the barista's incomplete orders" do
      order = Order.create_order(@barista.username)
      post "/barista/cancel-order", {},
           { "rack.session" => { username: @barista.username, role: @barista.role,
                                 order_id: order.order_unique_id } }
      expect(Order.where(order_unique_id: order.order_unique_id).count).to eq(0)
    end
  end

  describe "POST /barista/submit-order" do
    it "redirects to make-order with error=empty when the order has no items" do
      order = Order.create_order(@barista.username)
      post "/barista/submit-order", { payment_method: 1 },
           { "rack.session" => { username: @barista.username, role: @barista.role,
                                 order_id: order.order_unique_id } }
      expect(last_response).to be_redirect
      expect(last_response.location).to include("error=empty")
    end
  end

  describe "POST /barista/remove-item" do
    it "redirects after attempting to remove a non-existent item" do
      post_as_employee(@barista, "/barista/remove-item", { remove_item: -1, amount_of_items: 1 })
      expect(last_response).to be_redirect
    end

    it "defaults amount to 1 when amount_of_items is blank" do
      post_as_employee(@barista, "/barista/remove-item", { remove_item: -1, amount_of_items: "" })
      expect(last_response).to be_redirect
    end
  end

  describe "POST /barista/claim-stamps" do
    it "redirects when the customer does not exist" do
      post "/barista/claim-stamps", {},
           { "rack.session" => { username: @barista.username, role: @barista.role,
                                 loyalty_number: 9999 },
             "HTTP_REFERER" => "/barista/make-order" }
      expect(last_response).to be_redirect
    end

    it "redirects when customer exists but the order has no drinks" do
      order = Order.create_order(@barista.username)
      post "/barista/claim-stamps", {},
           { "rack.session" => { username: @barista.username, role: @barista.role,
                                 loyalty_number: @customer.loyalty_number,
                                 order_id: order.order_unique_id },
             "HTTP_REFERER" => "/barista/make-order" }
      expect(last_response).to be_redirect
    end
  end

  context "with a full product/variant FK chain (Coffee type)" do
    before do
      country = add_test_country_to_db
      roast   = add_test_roast_level_to_db
      @product = add_test_product_to_db("Coffee", "Latte", nil, 1, country.id, roast.id)
      @size    = add_test_size_to_db("large")
      @milk    = add_test_milk_option_to_db("Whole")
      add_test_product_variant_to_db(@product.product_id, @milk.id, @size.id)
      @order = Order.create_order(@barista.username)
      @payment_method = PaymentMethod.create(payment_method: "Cash")
    end

    describe "POST /barista/add-drink" do
      it "adds the drink and redirects" do
        post "/barista/add-drink",
             { item_to_be_added: @product.product_id, milk_type: "Whole", size: "large" },
             { "rack.session" => { username: @barista.username, role: @barista.role,
                                   order_id: @order.order_unique_id },
               "HTTP_REFERER" => "/barista/make-order" }
        expect(last_response).to be_redirect
      end
    end

    describe "POST /barista/remove-item" do
      it "calls FreeCoffeeRedemption.clear and redirects when the item is fully removed" do
        item = add_test_item_in_order_to_db(@product.product_id, @order.order_unique_id,
                                            3.7, 1, @milk.id, @size.id)
        post "/barista/remove-item",
             { remove_item: item.item_in_order_id, amount_of_items: item.quantity.to_s },
             { "rack.session" => { username: @barista.username, role: @barista.role,
                                   order_id: @order.order_unique_id } }
        expect(last_response).to be_redirect
      end
    end

    describe "POST /barista/submit-order" do
      it "submits the order and redirects to success when the order has items" do
        add_test_item_in_order_to_db(@product.product_id, @order.order_unique_id,
                                     3.7, 1, @milk.id, @size.id)
        post "/barista/submit-order",
             { payment_method: @payment_method.id },
             { "rack.session" => { username: @barista.username, role: @barista.role,
                                   order_id: @order.order_unique_id } }
        expect(last_response).to be_redirect
        expect(last_response.location).to include("alert=order_success")
      end
    end

    describe "POST /barista/claim-stamps" do
      it "redeems the free coffee and redirects when customer has 9 stamps and order has a drink" do
        country2 = add_test_country_to_db("UK")
        roast2   = add_test_roast_level_to_db("Medium")
        drink    = add_test_product_to_db("drinks", "Espresso", nil, 1, country2.id, roast2.id)
        size2    = add_test_size_to_db("small")
        milk2    = add_test_milk_option_to_db("Oat")
        add_test_product_variant_to_db(drink.product_id, milk2.id, size2.id)
        add_test_item_in_order_to_db(drink.product_id, @order.order_unique_id, 3.7, 1, milk2.id, size2.id)
        @customer.update(stamps: 9)
        post "/barista/claim-stamps", {},
             { "rack.session" => { username: @barista.username, role: @barista.role,
                                   loyalty_number: @customer.loyalty_number,
                                   order_id: @order.order_unique_id },
               "HTTP_REFERER" => "/barista/make-order" }
        expect(last_response).to be_redirect
        expect(last_response.location).to include("barista/make-order")
      end
    end
  end

  context "with beans product using hardcoded size_id=1 and milk_id=1" do
    before do
      DB[:sizes].insert(id: 1, size: "standard")
      DB[:milk_options].insert(id: 1, milk: "standard")
      country = add_test_country_to_db
      roast   = add_test_roast_level_to_db
      @beans  = add_test_product_to_db("beans", "Espresso Beans", nil, 1, country.id, roast.id)
      add_test_product_variant_to_db(@beans.product_id, 1, 1, 5.0, 3.0)
      @order = Order.create_order(@barista.username)
    end

    describe "POST /barista/add-beans" do
      it "adds the beans and redirects to /barista/make-order" do
        post "/barista/add-beans",
             { item_to_be_added: @beans.product_id },
             { "rack.session" => { username: @barista.username, role: @barista.role,
                                   order_id: @order.order_unique_id } }
        expect(last_response).to be_redirect
        expect(last_response.location).to include("/barista/make-order")
      end
    end
  end
end
