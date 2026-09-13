require_relative "../../spec_helper"

RSpec.describe "Barista main controller" do
  before do
    @barista = add_test_barista_to_db
    login_as_employee(@barista)
  end

  describe "GET /barista/main" do
    # barista/* routes have the same check, only covered once here
    context "when not logged in" do
      it "redirects to the employee login page" do
        get "/barista/main", {}, {}
        expect(last_response).to be_redirect
        expect(last_response.location).to include("/employee-login-page")
      end
    end

    context "when logged in" do
      it "returns 200" do
        get_as_employee(@barista, "/barista/main")
        expect(last_response.status).to eq(200)
      end

      context "with alert=order_success" do
        before do
          @customer = add_test_customer_to_db
          @order = add_test_order_to_db(@customer.loyalty_number)
        end

        it "shows the success alert when the order exists and there is no loyalty number in the session" do
          get "/barista/main", { alert: "order_success" },
              { "rack.session" => { username: @barista.username, role: @barista.role,
                                   order_id: @order.order_unique_id } }
          expect(last_response.body).to include("successfully completed")
        end

        it "shows the success alert when the order exists and a loyalty number is present in the session" do
          get "/barista/main", { alert: "order_success" },
              { "rack.session" => { username: @barista.username, role: @barista.role,
                                   order_id: @order.order_unique_id,
                                   loyalty_number: @customer.loyalty_number } }
          expect(last_response.body).to include("successfully completed")
        end

        it "clears the alert when the order does not exist in the database" do
          get "/barista/main", { alert: "order_success" },
              { "rack.session" => { username: @barista.username, role: @barista.role,
                                   order_id: -1 } }
          expect(last_response.body).not_to include("successfully completed")
        end
      end
    end
  end

  describe "POST /barista/main" do
    {
      "make_order"              => "/barista/make-order",
      "checkout_orders"         => "/barista/checkout-orders",
      "search_customer"         => "/barista/search-customer",
      "past_sales"              => "/barista/past-sales",
      "daily_summary"           => "/barista/daily-summary",
      "verify_refunds"          => "/barista/verify-refunds",
      "make_refund"             => "/barista/make-refunds",
      "generate_postage_labels" => "/barista/generate-postage-labels",
    }.each do |button, path|
      it "redirects to #{path} when button is #{button}" do
        post_as_employee(@barista, "/barista/main", { button: button })
        expect(last_response).to be_redirect
        expect(last_response.location).to include(path)
      end
    end

    it "does not redirect when the button value is unrecognised" do
      post_as_employee(@barista, "/barista/main", { button: "unknown" })
      expect(last_response).not_to be_redirect
    end
  end
end
