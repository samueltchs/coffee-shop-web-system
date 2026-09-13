require_relative "../../spec_helper"

RSpec.describe "Barista daily summary controller" do
  before do
    @barista = add_test_barista_to_db
    login_as_employee(@barista)
    @customer = add_test_customer_to_db
  end

  def todays_order(reference_id:, barista: nil)
    barista ||= @barista.username
    add_test_order_to_db(@customer.loyalty_number, Time.now.utc, 7.3, 7.7, nil, reference_id, barista, 1, "Completed", "Paid")
  end

  describe "GET /barista/daily-summary" do
    it "returns 200" do
      get_as_employee(@barista, "/barista/daily-summary")
      expect(last_response.status).to eq(200)
    end

    it "shows today's orders for the logged-in barista" do
      todays_order(reference_id: "ORDER_TODAY")
      get_as_employee(@barista, "/barista/daily-summary")
      expect(last_response.body).to include("ORDER_TODAY")
    end

    it "does not show orders from another barista" do
      todays_order(reference_id: "ORDER_OTHER_BARISTA", barista: "another_barista")
      get_as_employee(@barista, "/barista/daily-summary")
      expect(last_response.body).not_to include("ORDER_OTHER_BARISTA")
    end

    it "does not show orders from a previous day" do
      add_test_order_to_db(@customer.loyalty_number, Time.now.utc - SECONDS_IN_DAY, 7.3, 7.7, nil, "ORDER_YESTERDAY", @barista.username, 1, "Completed", "Paid")
      get_as_employee(@barista, "/barista/daily-summary")
      expect(last_response.body).not_to include("ORDER_YESTERDAY")
    end

    it "does not show incomplete orders" do
      add_test_order_to_db(@customer.loyalty_number, Time.now.utc, 7.3, 7.7, nil, "ORDER_INCOMPLETE", @barista.username, 1, "Incomplete", "Unpaid")
      get_as_employee(@barista, "/barista/daily-summary")
      expect(last_response.body).not_to include("ORDER_INCOMPLETE")
    end

    context "when filtering" do
      before do
        @order_paid     = todays_order(reference_id: "ORDER_PAID")
        @order_refunded = todays_order(reference_id: "ORDER_REFUNDED")
        @order_refunded.update(status: "Refunded")
      end

      it "filters by payment_status=Paid to show only paid orders" do
        get_as_employee(@barista, "/barista/daily-summary", { payment_status: "Paid" })
        expect(last_response.body).to include("ORDER_PAID")
        expect(last_response.body).not_to include("ORDER_REFUNDED")
      end

      it "filters by payment_status=Owed to show non-paid orders" do
        get_as_employee(@barista, "/barista/daily-summary", { payment_status: "Owed" })
        expect(last_response.body).to include("ORDER_REFUNDED")
        expect(last_response.body).not_to include("ORDER_PAID")
      end

      it "filters by fulfilment to show only matching orders" do
        @order_paid.update(order_fulfilment: "Collected")
        @order_refunded.update(order_fulfilment: "Completed")
        get_as_employee(@barista, "/barista/daily-summary", { fulfilment: "Collected" })
        expect(last_response.body).to include("ORDER_PAID")
        expect(last_response.body).not_to include("ORDER_REFUNDED")
      end

      it "filters by delivery=Not Delivered to show undelivered orders" do
        @order_paid.update(delivered: 0)
        @order_refunded.update(delivered: 1)
        get_as_employee(@barista, "/barista/daily-summary", { delivery: "Not Delivered" })
        expect(last_response.body).to include("ORDER_PAID")
        expect(last_response.body).not_to include("ORDER_REFUNDED")
      end

      it "filters by payment method to show only matching orders" do
        card = PaymentMethod.first(payment_method: "Card") || PaymentMethod.create(payment_method: "Card")
        cash = PaymentMethod.first(payment_method: "Cash") || PaymentMethod.create(payment_method: "Cash")
        @order_paid.update(payment_method: card.id)
        @order_refunded.update(payment_method: cash.id)
        get_as_employee(@barista, "/barista/daily-summary", { payment_method: "Card" })
        expect(last_response.body).to include("ORDER_PAID")
        expect(last_response.body).not_to include("ORDER_REFUNDED")
      end
    end
  end
end
