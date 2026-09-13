require_relative "../../spec_helper"

RSpec.describe "Barista checkout orders controller" do
  before do
    @barista = add_test_barista_to_db
    login_as_employee(@barista)
    @customer = add_test_customer_to_db
  end

  # Creates an order that satisfies all checkout conditions
  # (Completed fulfilment, 
  # not yet delivered,
  # no tracking (in-store),
  # no barista assigned)
  def eligible_order(reference_id: "ORDER001", loyalty_number: nil, status: "Paid")
    loyalty_number ||= @customer.loyalty_number
    add_test_order_to_db(loyalty_number, Time.now.utc, 7.3, 7.7, nil, reference_id, nil, 0, "Completed", status)
  end

  describe "GET /barista/checkout-orders" do
    it "returns 200" do
      get_as_employee(@barista, "/barista/checkout-orders")
      expect(last_response.status).to eq(200)
    end

    context "with an eligible order" do
      before { @order = eligible_order }

      it "shows the order" do
        get_as_employee(@barista, "/barista/checkout-orders")
        expect(last_response.body).to include("ORDER001")
      end
    end

    context "with ineligible orders" do
      it "does not show orders that have already been delivered" do
        add_test_order_to_db(@customer.loyalty_number, Time.now.utc, 7.3, 7.7, nil, "ORDER_DELIVERED", nil, 1, "Completed", "Paid")
        get_as_employee(@barista, "/barista/checkout-orders")
        expect(last_response.body).not_to include("ORDER_DELIVERED")
      end

      it "does not show orders that already have a barista assigned" do
        add_test_order_to_db(@customer.loyalty_number, Time.now.utc, 7.3, 7.7, nil, "ORDER_ASSIGNED", "someone", 0, "Completed", "Paid")
        get_as_employee(@barista, "/barista/checkout-orders")
        expect(last_response.body).not_to include("ORDER_ASSIGNED")
      end

      it "does not show delivery orders with a tracking ID" do
        add_test_order_to_db(@customer.loyalty_number, Time.now.utc, 7.3, 7.7, 123, "ORDER_TRACKED", nil, 0, "Completed", "Paid")
        get_as_employee(@barista, "/barista/checkout-orders")
        expect(last_response.body).not_to include("ORDER_TRACKED")
      end

      it "does not show incomplete orders" do
        add_test_order_to_db(@customer.loyalty_number, Time.now.utc, 7.3, 7.7, nil, "ORDER_INCOMPLETE", nil, 0, "Incomplete", "Unpaid")
        get_as_employee(@barista, "/barista/checkout-orders")
        expect(last_response.body).not_to include("ORDER_INCOMPLETE")
      end

      it "does not show unpaid orders" do
        add_test_order_to_db(@customer.loyalty_number, Time.now.utc, 7.3, 7.7, nil, "ORDER_UNPAID", nil, 0, "Completed", "Unpaid")
        get_as_employee(@barista, "/barista/checkout-orders")
        expect(last_response.body).not_to include("ORDER_UNPAID")
      end
    end

    context "when filtering" do
      before do
        @customer2   = add_test_customer_to_db(2)
        @order_a     = eligible_order(reference_id: "ORDER_CUSTOMER1", loyalty_number: @customer.loyalty_number)
        @order_b     = eligible_order(reference_id: "ORDER_CUSTOMER2", loyalty_number: @customer2.loyalty_number)
        @order_other = eligible_order(reference_id: "ORDER_REFUNDED", status: "Refunded")
      end

      it "filters by loyalty number to show only that customer's orders" do
        get_as_employee(@barista, "/barista/checkout-orders", { loyalty_number: @customer.loyalty_number })
        expect(last_response.body).to include("ORDER_CUSTOMER1")
        expect(last_response.body).not_to include("ORDER_CUSTOMER2")
      end

      it "filters to show only paid orders when payment_status is Paid" do
        get_as_employee(@barista, "/barista/checkout-orders", { payment_status: "Paid" })
        expect(last_response.body).to include("ORDER_CUSTOMER1", "ORDER_CUSTOMER2")
        expect(last_response.body).not_to include("ORDER_REFUNDED")
      end

      it "filters to show only non-paid orders when payment_status is Owed" do
        get_as_employee(@barista, "/barista/checkout-orders", { payment_status: "Owed" })
        expect(last_response.body).to include("ORDER_REFUNDED")
        expect(last_response.body).not_to include("ORDER_CUSTOMER1", "ORDER_CUSTOMER2")
      end

      it "filters by payment method to show only matching orders" do
        card = PaymentMethod.first(payment_method: "Card") || PaymentMethod.create(payment_method: "Card")
        cash = PaymentMethod.first(payment_method: "Cash") || PaymentMethod.create(payment_method: "Cash")
        @order_a.update(payment_method: card.id)
        @order_b.update(payment_method: cash.id)
        get_as_employee(@barista, "/barista/checkout-orders", { payment_method: "Card" })
        expect(last_response.body).to include("ORDER_CUSTOMER1")
        expect(last_response.body).not_to include("ORDER_CUSTOMER2")
      end

      it "filters by start date to exclude orders placed before it" do
        @order_a.update(date_placed: Time.now.utc - SECONDS_IN_DAY * 10)
        @order_b.update(date_placed: Time.now.utc)
        yesterday = (Time.now.utc - SECONDS_IN_DAY).strftime("%Y-%m-%d")
        get_as_employee(@barista, "/barista/checkout-orders", { start_date: yesterday })
        expect(last_response.body).to include("ORDER_CUSTOMER2")
        expect(last_response.body).not_to include("ORDER_CUSTOMER1")
      end

      it "filters by end date to exclude orders placed after it" do
        @order_a.update(date_placed: Time.now.utc)
        @order_b.update(date_placed: Time.now.utc + SECONDS_IN_DAY * 10)
        tomorrow = (Time.now.utc + SECONDS_IN_DAY).strftime("%Y-%m-%d")
        get_as_employee(@barista, "/barista/checkout-orders", { end_date: tomorrow })
        expect(last_response.body).to include("ORDER_CUSTOMER1")
        expect(last_response.body).not_to include("ORDER_CUSTOMER2")
      end
    end
  end

  describe "POST /barista/checkout-orders" do
    it "redirects to /barista/checkout-orders with the selected order ID" do
      order = eligible_order
      post_as_employee(@barista, "/barista/checkout-orders", { order_id: order.order_unique_id })
      expect(last_response).to be_redirect
      expect(last_response.location).to include("/barista/checkout-orders")
      expect(last_response.location).to include("selected=#{order.order_unique_id}")
    end

    it "redirects to /barista/checkout-orders with an empty selected param when no order ID is given" do
      post_as_employee(@barista, "/barista/checkout-orders", {})
      expect(last_response).to be_redirect
      expect(last_response.location).to include("/barista/checkout-orders")
      expect(last_response.location).to include("selected=")
    end
  end

  describe "POST /barista/confirm-checkout" do
    before { @order = eligible_order }

    it "marks the order as delivered" do
      post_as_employee(@barista, "/barista/confirm-checkout", { order_id: @order.order_unique_id })
      expect(Order.get_order(@order.order_unique_id).delivered).to eq(1)
    end

    it "sets the order fulfilment to Collected" do
      post_as_employee(@barista, "/barista/confirm-checkout", { order_id: @order.order_unique_id })
      expect(Order.get_order(@order.order_unique_id).order_fulfilment).to eq("Collected")
    end

    it "assigns the logged-in barista's username to the order" do
      post_as_employee(@barista, "/barista/confirm-checkout", { order_id: @order.order_unique_id })
      expect(Order.get_order(@order.order_unique_id).barista).to eq(@barista.username)
    end

    it "redirects to /barista/checkout-orders" do
      post_as_employee(@barista, "/barista/confirm-checkout", { order_id: @order.order_unique_id })
      expect(last_response).to be_redirect
      expect(last_response.location).to include("/barista/checkout-orders")
    end

    it "still redirects when the order does not exist" do
      post_as_employee(@barista, "/barista/confirm-checkout", { order_id: -1 })
      expect(last_response).to be_redirect
      expect(last_response.location).to include("/barista/checkout-orders")
    end

    context "with an owed order" do
      before { @owed_order = eligible_order(reference_id: "ORDER_OWED", status: "Owed") }

      it "redirects with error=payment when no payment method is provided" do
        post_as_employee(@barista, "/barista/confirm-checkout", { order_id: @owed_order.order_unique_id })
        expect(last_response).to be_redirect
        expect(last_response.location).to include("selected=#{@owed_order.order_unique_id}")
        expect(last_response.location).to include("error=payment")
      end
    end
  end
end
