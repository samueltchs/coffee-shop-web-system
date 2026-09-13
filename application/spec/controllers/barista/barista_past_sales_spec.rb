require_relative "../../spec_helper"

RSpec.describe "Barista past sales controller" do
  before do
    @barista = add_test_barista_to_db
    login_as_employee(@barista)
    @customer = add_test_customer_to_db
  end

  def complete_order(reference_id:, loyalty_number: nil, barista: "Online",
                     fulfilment: "Completed", delivered: 1, tracking_id: 1, status: "Paid")
    loyalty_number ||= @customer.loyalty_number
    add_test_order_to_db(loyalty_number, Time.now.utc, 7.3, 7.7, tracking_id, reference_id, barista, delivered, fulfilment, status)
  end

  describe "GET /barista/past-sales" do
    it "returns 200" do
      get_as_employee(@barista, "/barista/past-sales")
      expect(last_response.status).to eq(200)
    end

    context "with orders in the database" do
      it "shows completed paid orders" do
        complete_order(reference_id: "ORDER_PAID")
        get_as_employee(@barista, "/barista/past-sales")
        expect(last_response.body).to include("ORDER_PAID")
      end

      it "does not show incomplete orders" do
        add_test_order_to_db(@customer.loyalty_number, Time.now.utc, 7.3, 7.7, 1, "ORDER_INCOMPLETE", "Online", 1, "Incomplete", "Unpaid")
        get_as_employee(@barista, "/barista/past-sales")
        expect(last_response.body).not_to include("ORDER_INCOMPLETE")
      end

      it "does not show unpaid orders" do
        add_test_order_to_db(@customer.loyalty_number, Time.now.utc, 7.3, 7.7, 1, "ORDER_UNPAID", "Online", 1, "Completed", "Unpaid")
        get_as_employee(@barista, "/barista/past-sales")
        expect(last_response.body).not_to include("ORDER_UNPAID")
      end
    end

    context "when filtering" do
      before do
        @customer2 = add_test_customer_to_db(2)
        @order_a = complete_order(reference_id: "ORDER_CUSTOMER1", loyalty_number: @customer.loyalty_number)
        @order_b = complete_order(reference_id: "ORDER_CUSTOMER2", loyalty_number: @customer2.loyalty_number)
      end

      it "filters by loyalty number to show only that customer's orders" do
        get_as_employee(@barista, "/barista/past-sales", { loyalty_number: @customer.loyalty_number })
        expect(last_response.body).to include("ORDER_CUSTOMER1")
        expect(last_response.body).not_to include("ORDER_CUSTOMER2")
      end

      it "filters by barista to show only that barista's orders" do
        @order_a.update(barista: "barista_one")
        @order_b.update(barista: "barista_two")
        get_as_employee(@barista, "/barista/past-sales", { barista: "barista_one" })
        expect(last_response.body).to include("ORDER_CUSTOMER1")
        expect(last_response.body).not_to include("ORDER_CUSTOMER2")
      end

      it "filters by fulfilment to show only matching orders" do
        @order_a.update(order_fulfilment: "Collected")
        @order_b.update(order_fulfilment: "Completed")
        get_as_employee(@barista, "/barista/past-sales", { fulfilment: "Collected" })
        expect(last_response.body).to include("ORDER_CUSTOMER1")
        expect(last_response.body).not_to include("ORDER_CUSTOMER2")
      end

      it "filters by payment_status=Paid to show only paid orders" do
        @order_a.update(status: "Paid")
        @order_b.update(status: "Refunded")
        get_as_employee(@barista, "/barista/past-sales", { payment_status: "Paid" })
        expect(last_response.body).to include("ORDER_CUSTOMER1")
        expect(last_response.body).not_to include("ORDER_CUSTOMER2")
      end

      it "filters by payment_status=Owed to show non-paid orders" do
        @order_a.update(status: "Refunded")
        @order_b.update(status: "Paid")
        get_as_employee(@barista, "/barista/past-sales", { payment_status: "Owed" })
        expect(last_response.body).to include("ORDER_CUSTOMER1")
        expect(last_response.body).not_to include("ORDER_CUSTOMER2")
      end

      it "filters by payment method to show only matching orders" do
        card = PaymentMethod.first(payment_method: "Card") || PaymentMethod.create(payment_method: "Card")
        cash = PaymentMethod.first(payment_method: "Cash") || PaymentMethod.create(payment_method: "Cash")
        @order_a.update(payment_method: card.id)
        @order_b.update(payment_method: cash.id)
        get_as_employee(@barista, "/barista/past-sales", { payment_method: "Card" })
        expect(last_response.body).to include("ORDER_CUSTOMER1")
        expect(last_response.body).not_to include("ORDER_CUSTOMER2")
      end

      it "filters by delivery=Not Delivered to show undelivered orders" do
        @order_a.update(delivered: 0)
        @order_b.update(delivered: 1)
        get_as_employee(@barista, "/barista/past-sales", { delivery: "Not Delivered" })
        expect(last_response.body).to include("ORDER_CUSTOMER1")
        expect(last_response.body).not_to include("ORDER_CUSTOMER2")
      end

      it "filters by delivery=Delivered to show delivered orders" do
        @order_a.update(delivered: 1)
        @order_b.update(delivered: 0)
        get_as_employee(@barista, "/barista/past-sales", { delivery: "Delivered" })
        expect(last_response.body).to include("ORDER_CUSTOMER1")
        expect(last_response.body).not_to include("ORDER_CUSTOMER2")
      end

      it "filters by tracking=Handled In-Store to show in-store orders" do
        @order_a.update(tracking_id: nil)
        @order_b.update(tracking_id: 123)
        get_as_employee(@barista, "/barista/past-sales", { tracking: "Handled In-Store" })
        expect(last_response.body).to include("ORDER_CUSTOMER1")
        expect(last_response.body).not_to include("ORDER_CUSTOMER2")
      end

      it "filters by start date to exclude orders placed before it" do
        @order_a.update(date_placed: Time.now.utc - SECONDS_IN_DAY * 10)
        @order_b.update(date_placed: Time.now.utc)
        yesterday = (Time.now.utc - SECONDS_IN_DAY).strftime("%Y-%m-%d")
        get_as_employee(@barista, "/barista/past-sales", { start_date: yesterday })
        expect(last_response.body).to include("ORDER_CUSTOMER2")
        expect(last_response.body).not_to include("ORDER_CUSTOMER1")
      end

      it "filters by end date to exclude orders placed after it" do
        @order_a.update(date_placed: Time.now.utc)
        @order_b.update(date_placed: Time.now.utc + SECONDS_IN_DAY * 10)
        tomorrow = (Time.now.utc + SECONDS_IN_DAY).strftime("%Y-%m-%d")
        get_as_employee(@barista, "/barista/past-sales", { end_date: tomorrow })
        expect(last_response.body).to include("ORDER_CUSTOMER1")
        expect(last_response.body).not_to include("ORDER_CUSTOMER2")
      end
    end
  end
end
