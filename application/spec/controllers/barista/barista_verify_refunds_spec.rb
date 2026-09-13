require_relative "../../spec_helper"

RSpec.describe "Barista verify refunds controller" do
  before do
    @barista = add_test_barista_to_db
    login_as_employee(@barista)
    @customer = add_test_customer_to_db
  end

  describe "GET /barista/verify-refunds" do
    it "returns 200" do
      get_as_employee(@barista, "/barista/verify-refunds")
      expect(last_response.status).to eq(200)
    end

    context "with refunds in the database" do
      before do
        @pending_refund  = add_test_refund_to_db(@customer.loyalty_number, "REFUND_PENDING", "Pending")
        @resolved_refund = add_test_refund_to_db(@customer.loyalty_number, "REFUND_RESOLVED", "Resolved")
        @denied_refund   = add_test_refund_to_db(@customer.loyalty_number, "REFUND_DENIED", "Denied")
      end

      it "shows pending refunds" do
        get_as_employee(@barista, "/barista/verify-refunds")
        expect(last_response.body).to include("REFUND_PENDING")
      end

      it "shows resolved refunds" do
        get_as_employee(@barista, "/barista/verify-refunds")
        expect(last_response.body).to include("REFUND_RESOLVED")
      end

      it "shows denied refunds" do
        get_as_employee(@barista, "/barista/verify-refunds")
        expect(last_response.body).to include("REFUND_DENIED")
      end
    end

    context "when filtering" do
      before do
        @customer2 = add_test_customer_to_db(2)
        @refund_a  = add_test_refund_to_db(@customer.loyalty_number, "REFUND_CUSTOMER1", "Pending")
        @refund_b  = add_test_refund_to_db(@customer2.loyalty_number, "REFUND_CUSTOMER2", "Pending")
      end

      it "filters by loyalty number to show only that customer's refunds" do
        get_as_employee(@barista, "/barista/verify-refunds", { loyalty_number: @customer.loyalty_number })
        expect(last_response.body).to include("REFUND_CUSTOMER1")
        expect(last_response.body).not_to include("REFUND_CUSTOMER2")
      end

      it "filters by refund_status to show only matching refunds" do
        @refund_b.update(status: "Resolved")
        get_as_employee(@barista, "/barista/verify-refunds", { refund_status: "Pending" })
        expect(last_response.body).to include("REFUND_CUSTOMER1")
        expect(last_response.body).not_to include("REFUND_CUSTOMER2")
      end

      it "filters by start date to exclude refunds created before it" do
        @refund_a.update(created_at: Time.now.utc - SECONDS_IN_DAY * 10)
        @refund_b.update(created_at: Time.now.utc)
        yesterday = (Time.now.utc - SECONDS_IN_DAY).strftime("%Y-%m-%d")
        get_as_employee(@barista, "/barista/verify-refunds", { start_date: yesterday })
        expect(last_response.body).to include("REFUND_CUSTOMER2")
        expect(last_response.body).not_to include("REFUND_CUSTOMER1")
      end

      it "filters by end date to exclude refunds created after it" do
        @refund_a.update(created_at: Time.now.utc)
        @refund_b.update(created_at: Time.now.utc + SECONDS_IN_DAY * 10)
        tomorrow = (Time.now.utc + SECONDS_IN_DAY).strftime("%Y-%m-%d")
        get_as_employee(@barista, "/barista/verify-refunds", { end_date: tomorrow })
        expect(last_response.body).to include("REFUND_CUSTOMER1")
        expect(last_response.body).not_to include("REFUND_CUSTOMER2")
      end
    end
  end

  describe "POST /barista/verify-refund" do
    before do
      @refund = add_test_refund_to_db(@customer.loyalty_number, "Test refund", "Pending")
    end

    it "approves the refund when choice is approve" do
      post_as_employee(@barista, "/barista/verify-refund", { refund_id: @refund.refund_id, choice: "approve" })
      expect(Refund.get_refund_by_id(@refund.refund_id).status).to eq("Resolved")
    end

    it "denies the refund when choice is deny" do
      post_as_employee(@barista, "/barista/verify-refund", { refund_id: @refund.refund_id, choice: "deny" })
      expect(Refund.get_refund_by_id(@refund.refund_id).status).to eq("Denied")
    end

    it "redirects to /barista/verify-refunds" do
      post_as_employee(@barista, "/barista/verify-refund", { refund_id: @refund.refund_id, choice: "approve" })
      expect(last_response).to be_redirect
      expect(last_response.location).to include("/barista/verify-refunds")
    end

    it "still redirects when the refund does not exist" do
      post_as_employee(@barista, "/barista/verify-refund", { refund_id: -1, choice: "approve" })
      expect(last_response).to be_redirect
      expect(last_response.location).to include("/barista/verify-refunds")
    end
  end
end
