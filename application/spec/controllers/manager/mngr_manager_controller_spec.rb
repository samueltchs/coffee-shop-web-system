RSpec.describe "manager controller" do
  describe "GET /manager/refunds" do
    context "when not logged in" do
      it "redirects to employee login page" do
        get "/manager/refunds"

        expect(last_response).to be_redirect
        expect(last_response.location).to include("/employee-login-page?error")
      end
    end

    context "when logged in but not as manager" do
      it "redirects to the appropriate page" do
        barista = add_test_barista_to_db
        get_as_employee(barista, "/manager/refunds")

        expect(last_response).to be_redirect
        expect(last_response.location).to end_with("/barista/main")
      end
    end

    context "when logged in as manager" do
      it "loads the page" do
        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/refunds")

        expect(last_response).to be_ok
      end

      it "shows the total refunds count" do
        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/refunds")

        expect(last_response.body).to include("Total refunds:")
      end

      it "shows the refund count from the db" do
        add_test_customer_to_db
        add_test_refund_to_db(1, "wrong drink", "Pending")
        add_test_refund_to_db(1, "cold drink", "Resolved")

        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/refunds")

        expect(last_response.body).to include("Total refunds: 2")
      end
    end
  end

  describe "GET /manager/complaints" do
    context "when not logged in" do
      it "redirects to employee login page" do
        get "/manager/complaints"

        expect(last_response).to be_redirect
        expect(last_response.location).to include("/employee-login-page?error")
      end
    end

    context "when logged in but not as manager" do
      it "redirects to the appropriate page" do
        barista = add_test_barista_to_db
        get_as_employee(barista, "/manager/complaints")

        expect(last_response).to be_redirect
        expect(last_response.location).to end_with("/barista/main")
      end
    end

    context "when logged in as manager" do
      it "loads the page" do
        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/complaints")

        expect(last_response).to be_ok
      end

      it "shows the total complaints count" do
        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/complaints")

        expect(last_response.body).to include("Total complaints:")
      end

      it "shows the complaint count from the db" do
        add_test_customer_to_db
        add_test_complaint_to_db(1, "rude staff", "Pending")
        add_test_complaint_to_db(1, "cold drink", "Resolved")
        add_test_complaint_to_db(1, "slow service", "Pending")

        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/complaints")

        expect(last_response.body).to include("Total complaints: 3")
      end
    end
  end

  describe "GET /manager/free-coffees" do
    context "when not logged in" do
      it "redirects to employee login page" do
        get "/manager/free-coffees"

        expect(last_response).to be_redirect
      end
    end

    context "when logged in as manager" do
      it "loads the page" do
        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/free-coffees")

        expect(last_response).to be_ok
      end
    end
  end

  describe "GET /manager/sales/top-customers" do
    context "when not logged in" do
      it "redirects to employee login page" do
        get "/manager/sales/top-customers"

        expect(last_response).to be_redirect
      end
    end

    context "when logged in as manager" do
      it "loads the page" do
        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/sales/top-customers")

        expect(last_response).to be_ok
      end
    end
  end

  describe "GET /manager/sales/analytics" do
    context "when logged in as manager" do
      it "loads the page" do
        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/sales/analytics")

        expect(last_response).to be_ok
      end
    end

    context "when not logged in" do
      it "redirects to login" do
        get "/manager/sales/analytics"

        expect(last_response).to be_redirect
      end
    end
  end

  describe "GET /manager/sales/drinks" do
    context "when logged in as manager" do
      it "loads the page" do
        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/sales/drinks")

        expect(last_response).to be_ok
      end
    end
  end

  describe "GET /manager/sales/beans" do
    context "when logged in as manager" do
      it "loads the page" do
        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/sales/beans")

        expect(last_response).to be_ok
      end
    end
  end
end