require_relative "../../spec_helper"

RSpec.describe "Barista generate postage labels controller" do
  before do
    @barista = add_test_barista_to_db
    login_as_employee(@barista)
    @customer = add_test_customer_to_db
  end

  describe "GET /barista/generate-postage-labels" do
    it "returns 200" do
      get_as_employee(@barista, "/barista/generate-postage-labels")
      expect(last_response.status).to eq(200)
    end
  end

  describe "POST /barista/generate-postage-labels" do
    it "redirects to generate-order-postage-labels when button is order" do
      post_as_employee(@barista, "/barista/generate-postage-labels", { button: "order" })
      expect(last_response).to be_redirect
      expect(last_response.location).to include("/barista/generate-order-postage-labels")
    end

    it "redirects to generate-refund-postage-labels when button is refund" do
      post_as_employee(@barista, "/barista/generate-postage-labels", { button: "refund" })
      expect(last_response).to be_redirect
      expect(last_response.location).to include("/barista/generate-refund-postage-labels")
    end

    it "redirects when button is unrecognised" do
      post_as_employee(@barista, "/barista/generate-postage-labels", { button: "unknown" })
      expect(last_response).to be_redirect
    end
  end

  describe "GET /barista/generate-order-postage-labels" do
    it "returns 200" do
      get_as_employee(@barista, "/barista/generate-order-postage-labels")
      expect(last_response.status).to eq(200)
    end

    context "when a deliverable order has only beans items" do
      before do
        country = add_test_country_to_db
        roast   = add_test_roast_level_to_db
        @beans  = add_test_product_to_db("beans", "Ground Beans", nil, 1, country.id, roast.id)
        @size   = add_test_size_to_db("standard")
        @milk   = add_test_milk_option_to_db("none")
        add_test_product_variant_to_db(@beans.product_id, @size.id, @milk.id)
        # Deliverable: no tracking_id, fulfilment=Completed, delivered=0, status=Paid
        @deliverable = add_test_order_to_db(@customer.loyalty_number, Time.now.utc, 7.3, 7.7,
                                            0, "BEANS_ORDER", "Online", 0, "Completed", "Paid")
        add_test_item_in_order_to_db(@beans.product_id, @deliverable.order_unique_id,
                                     3.7, 1, @size.id, @milk.id)
      end

      it "includes the order in the label list when all items are beans" do
        get_as_employee(@barista, "/barista/generate-order-postage-labels")
        expect(last_response.body).to include("BEANS_ORDER")
      end
    end
  end

  describe "POST /barista/assign-order-tracking-id" do
    before do
      country = add_test_country_to_db
      roast   = add_test_roast_level_to_db
      beans   = add_test_product_to_db("beans", "Ground Beans", nil, 1, country.id, roast.id)
      size    = add_test_size_to_db("standard")
      milk    = add_test_milk_option_to_db("none")
      add_test_product_variant_to_db(beans.product_id, size.id, milk.id)
      @order = add_test_order_to_db(@customer.loyalty_number, Time.now.utc, 7.3, 7.7,
                                    0, "TRACK_ORDER", "Online", 0, "Completed", "Paid")
      add_test_item_in_order_to_db(beans.product_id, @order.order_unique_id,
                                   3.7, 1, size.id, milk.id)
    end

    it "assigns a tracking ID to the order" do
      post_as_employee(@barista, "/barista/assign-order-tracking-id", { order_id: @order.order_unique_id })
      refreshed = Order.get_order(@order.order_unique_id)
      expect(refreshed.tracking_id).not_to be_nil
      expect(refreshed.tracking_id).to be > 0
    end

    it "redirects to the order label page with the order selected" do
      post_as_employee(@barista, "/barista/assign-order-tracking-id", { order_id: @order.order_unique_id })
      expect(last_response).to be_redirect
      expect(last_response.location).to include("/barista/generate-order-postage-labels")
      expect(last_response.location).to include("selected=#{@order.order_unique_id}")
    end

    it "redirects to the label list when no order_id is given" do
      post_as_employee(@barista, "/barista/assign-order-tracking-id", {})
      expect(last_response).to be_redirect
      expect(last_response.location).to include("/barista/generate-order-postage-labels")
    end

    it "redirects to the label list when the order does not exist" do
      post_as_employee(@barista, "/barista/assign-order-tracking-id", { order_id: -1 })
      expect(last_response).to be_redirect
      expect(last_response.location).to include("/barista/generate-order-postage-labels")
    end
  end


  describe "GET /barista/generate-refund-postage-labels" do
    it "returns 200" do
      get_as_employee(@barista, "/barista/generate-refund-postage-labels")
      expect(last_response.status).to eq(200)
    end

    it "shows pending refunds and not resolved refunds" do
      add_test_refund_to_db(@customer.loyalty_number, "REFUND_PENDING", "Pending")
      add_test_refund_to_db(@customer.loyalty_number, "REFUND_RESOLVED", "Resolved")
      get_as_employee(@barista, "/barista/generate-refund-postage-labels")
      expect(last_response.body).to include("REFUND_PENDING")
      expect(last_response.body).not_to include("REFUND_RESOLVED")
    end

    it "filters by loyalty number to show only that customer's refunds" do
      @customer2 = add_test_customer_to_db(2)
      add_test_refund_to_db(@customer.loyalty_number, "REFUND_CUSTOMER1", "Pending")
      add_test_refund_to_db(@customer2.loyalty_number, "REFUND_CUSTOMER2", "Pending")
      get_as_employee(@barista, "/barista/generate-refund-postage-labels", { loyalty_number: @customer.loyalty_number })
      expect(last_response.body).to include("REFUND_CUSTOMER1")
      expect(last_response.body).not_to include("REFUND_CUSTOMER2")
    end

    it "excludes pending refunds with a nil loyalty number" do
      add_test_refund_to_db(nil, "REFUND_NO_LOYALTY_NIL", "Pending")
      get_as_employee(@barista, "/barista/generate-refund-postage-labels")
      expect(last_response.body).not_to include("REFUND_NO_LOYALTY_NIL")
    end

    it "excludes pending refunds with an empty loyalty number" do
      add_test_refund_to_db("", "REFUND_NO_LOYALTY_EMPTY", "Pending")
      get_as_employee(@barista, "/barista/generate-refund-postage-labels")
      expect(last_response.body).not_to include("REFUND_NO_LOYALTY_EMPTY")
    end
  end

  describe "GET /barista-send-refund-postage-label" do
    it "redirects to generate-refund-postage-labels when no refund_id is given" do
      get_as_employee(@barista, "/barista-send-refund-postage-label")
      expect(last_response).to be_redirect
      expect(last_response.location).to include("/barista/generate-refund-postage-labels")
    end

    it "redirects to generate-refund-postage-labels when the refund does not exist" do
      get_as_employee(@barista, "/barista-send-refund-postage-label", { refund_id: -1 })
      expect(last_response).to be_redirect
      expect(last_response.location).to include("/barista/generate-refund-postage-labels")
    end

    it "redirects to generate-refund-postage-labels when the refund has no matching customer" do
      refund = add_test_refund_to_db(9999, "Orphan refund", "Pending")
      get_as_employee(@barista, "/barista-send-refund-postage-label", { refund_id: refund.refund_id })
      expect(last_response).to be_redirect
      expect(last_response.location).to include("/barista/generate-refund-postage-labels")
    end

    it "renders the postage label email when refund and customer are valid" do
      refund = add_test_refund_to_db(@customer.loyalty_number, "Valid refund", "Pending")
      get_as_employee(@barista, "/barista-send-refund-postage-label", { refund_id: refund.refund_id })
      expect(last_response.status).to eq(200)
    end
  end
end
