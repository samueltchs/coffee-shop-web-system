RSpec.describe "manager discounts page controller" do
  describe "GET /manager/discounts" do
    context "when not logged in" do
      it "redirects to employee login page" do
        get "/manager/discounts"

        expect(last_response).to be_redirect
        expect(last_response.location).to include("/employee-login-page?error")
      end
    end

    context "when logged in but not as manager" do
      it "redirects to the appropriate page" do
        barista = add_test_barista_to_db
        get_as_employee(barista, "/manager/discounts")

        expect(last_response).to be_redirect
        expect(last_response.location).to end_with("/barista/main")
      end
    end

    context "when logged in as manager" do
      before do 
        @manager = add_test_manager_to_db
        add_default_discount_options_to_db
      end

      it "loads current campaigns page" do
        get_as_employee(@manager, "/manager/discounts")

        expect(last_response).to be_ok
        expect(last_response.body).to include("Current Campaigns")
      end

      it "shows shows a table with correct table headers" do
        get_as_employee(@manager, "/manager/discounts")

        expect(last_response.body).to include('table class="scrollable-table"')
        expect(last_response.body).to include("Name")
        expect(last_response.body).to include("Code")
        expect(last_response.body).to include("Details")
      end

      it "shows active discount campaigns" do
        discount = add_test_discount_code_to_db
        get_as_employee(@manager, "/manager/discounts")

        expect(last_response.body).to include(discount.campaign_name)
        expect(last_response.body).to include(discount.discount_code)
      end

      it "has link to discount details page for each discount" do
        discount = add_test_discount_code_to_db
        get_as_employee(@manager, "/manager/discounts")

        expect(last_response.body).to include(
          "href=\"/manager/discounts/details?viewcode=#{discount.discount_code}\""
        )
      end

      it "has button to go to past campaigns page" do
        get_as_employee(@manager, "/manager/discounts")

        expect(last_response.body).to include('href="/manager/discounts/past"')
        expect(last_response.body).to include("Past Campaigns")
      end

      it "has button to create new discount page" do
        get_as_employee(@manager, "/manager/discounts")

        expect(last_response.body).to include('href="/manager/create-discount"')
        expect(last_response.body).to include("New Campaign")
      end
    end
  end

  describe "GET /manager/discounts/past" do
    context "when not logged in" do
      it "redirects to employee login page" do
        get "/manager/discounts/past"

        expect(last_response).to be_redirect
        expect(last_response.location).to include("/employee-login-page?error")
      end
    end

    context "when logged in but not as manager" do
      it "redirects to the appropriate page" do
        barista = add_test_barista_to_db
        get_as_employee(barista, "/manager/discounts/past")

        expect(last_response).to be_redirect
        expect(last_response.location).to end_with("/barista/main")
      end
    end

    context "when logged in as manager" do
      before do 
        @manager = add_test_manager_to_db
        add_default_discount_options_to_db
      end

      it "loads past campaigns page" do
        get_as_employee(@manager, "/manager/discounts/past")

        expect(last_response).to be_ok
        expect(last_response.body).to include("Past Campaigns")
      end

      it "shows a table with correct table headers" do
        get_as_employee(@manager, "/manager/discounts/past")

        expect(last_response.body).to include('table class="scrollable-table"')
        expect(last_response.body).to include("Name")
        expect(last_response.body).to include("Code")
        expect(last_response.body).to include("Details")
      end

      it "shows inactive discount campaigns" do
        discount = add_test_discount_code_to_db(is_active: "0")
        get_as_employee(@manager, "/manager/discounts/past")

        expect(last_response.body).to include(discount.campaign_name)
        expect(last_response.body).to include(discount.discount_code)
      end

      it "has link to discount details page for each discount" do
        discount = add_test_discount_code_to_db(is_active: "0")
        get_as_employee(@manager, "/manager/discounts/past")

        expect(last_response.body).to include(
          "href=\"/manager/discounts/details?viewcode=#{discount.discount_code}&from_past=yes\""
        )
      end

      it "has button to go to current campaigns page" do
        get_as_employee(@manager, "/manager/discounts/past")

        expect(last_response.body).to include('href="/manager/discounts"')
        expect(last_response.body).to include("Current Campaigns")
      end

      it "has button to create new discount page" do
        get_as_employee(@manager, "/manager/discounts/past")

        expect(last_response.body).to include(
          'href="/manager/create-discount?from_past=yes"'
        )
        expect(last_response.body).to include("New Campaign")
      end
    end
  end

  describe "GET /manager/discounts/details" do
    context "when not logged in" do
      it "redirects to employee login page" do
        get "/manager/discounts/details?viewcode=CODE"

        expect(last_response).to be_redirect
        expect(last_response.location).to include("/employee-login-page?error")
      end
    end

    context "when logged in but not as manager" do
      it "redirects to the appropriate page" do
        barista = add_test_barista_to_db
        get_as_employee(barista, "/manager/discounts/details", {"viewcode" => "CODE"})

        expect(last_response).to be_redirect
        expect(last_response.location).to end_with("/barista/main")
      end
    end

    context "when logged in as manager" do
      before do
        @manager = add_test_manager_to_db
        add_default_discount_options_to_db
      end

      it "redirects to discounts page when discount code does not exist" do
        get_as_employee(@manager, "/manager/discounts/details", {"viewcode" => "FAKECODE"})

        expect(last_response).to be_redirect
        expect(last_response.location).to end_with("/manager/discounts")
      end

      it "loads discount details page" do
        discount = add_test_discount_code_to_db
        get_as_employee(@manager, "/manager/discounts/details", {"viewcode" => discount.discount_code})

        expect(last_response).to be_ok
        expect(last_response.body).to include("Discount Details")
      end

      it "shows campaign name and discount code" do
        discount = add_test_discount_code_to_db
        get_as_employee(@manager, "/manager/discounts/details", {"viewcode" => discount.discount_code})

        expect(last_response.body).to include(
          "#{discount.campaign_name} - #{discount.discount_code}"
        )
      end

      it "shows code active status" do
        discount = add_test_discount_code_to_db(is_active: "1")
        get_as_employee(@manager, "/manager/discounts/details", {"viewcode" => discount.discount_code})

        expect(last_response.body).to include("Status: Active")
      end

      it "shows code inactive status" do
        discount = add_test_discount_code_to_db(is_active: "0")
        get_as_employee(@manager, "/manager/discounts/details", {"viewcode" => discount.discount_code})

        expect(last_response.body).to include("Status: Inactive")
      end

      it "shows discount eligibility details" do
        discount = add_test_discount_code_to_db
        get_as_employee(@manager, "/manager/discounts/details", {"viewcode" => discount.discount_code})

        expect(last_response.body).to include("Eligibility")

        expect(last_response.body).to include(
          "Purchase Type: #{discount.get_purchase_type_name}"
        )

        expect(last_response.body).to include(
          "Eligibility Rule: #{discount.get_eligible_rule_name}"
        )

        expect(last_response.body).to include("Minimum Amount:")
        if discount.eligible_rule == 1
          expect(last_response.body).to include("£%.2f" % discount.eligible_min)
        else
          expect(last_response.body).to include("%d" % discount.eligible_min)
        end

        expect(last_response.body).to include("Eligible Purchase Period")
        expect(last_response.body).to include("From: #{discount.valid_purchase_date_from}")
        expect(last_response.body).to include("To: #{discount.valid_purchase_date_to}")

        expect(last_response.body).to include("Code Expiry Date: #{discount.code_expiry_date}")
        expect(last_response.body).to include("Discount Rate: #{discount.percentage_off}%")
      end

      it "shows statistics section" do
        discount = add_test_discount_code_to_db
        get_as_employee(@manager, "/manager/discounts/details", {"viewcode" => discount.discount_code})

        expect(last_response.body).to include("Statistics")
        expect(last_response.body).to include(
          "Attributed Gross Sales: #{"£%.2f" % discount.total_used_code(:gross)}"
        )
        expect(last_response.body).to include(
          "Attributed Net Sales: #{"£%.2f" % discount.total_used_code(:net)}"
        )
        expect(last_response.body).to include(
          "Attributed Costs: #{"£%.2f" % discount.total_used_code(:cost)}"
        )
        expect(last_response.body).to include(
          "Attributed Profits: #{"£%.2f" % discount.profits_used_code}"
        )
        expect(last_response.body).to include(
          "Total Discounts Allowed: #{"£%.2f" % discount.discount_allowed_by_code}"
        )
      end

      it "has a back button to current discounts page when entered from current campaigns" do
        discount = add_test_discount_code_to_db
        get_as_employee(@manager, "/manager/discounts/details", {"viewcode" => discount.discount_code})

        expect(last_response.body).to include('href="/manager/discounts"')
        expect(last_response.body).to include("Back")
      end

      it "has a back button to past discounts page when entered from past campaigns" do
        discount = add_test_discount_code_to_db(is_active: "0")
        get_as_employee(
          @manager,
          "/manager/discounts/details",
          {"viewcode" => discount.discount_code, "from_past" => "yes"}
        )

        expect(last_response.body).to include('href="/manager/discounts/past"')
        expect(last_response.body).to include("Back")
      end

      it "has an edit button to update discount" do
        discount = add_test_discount_code_to_db
        get_as_employee(@manager, "/manager/discounts/details", {"viewcode" => discount.discount_code})

        expect(last_response.body).to include(
          "href=\"/manager/update-discount?viewcode=#{discount.discount_code}\""
        )
        expect(last_response.body).to include("Edit")
      end

      it "keeps from_past=yes in edit link when entered from past campaign" do
        discount = add_test_discount_code_to_db(is_active: "0")
        get_as_employee(
          @manager,
          "/manager/discounts/details",
          {"viewcode" => discount.discount_code, "from_past" => "yes"}
        )

        expect(last_response.body).to include(
          "href=\"/manager/update-discount?viewcode=#{discount.discount_code}&from_past=yes\""
        )
      end

      it "shows eligible customers table headers" do
        #eligible when purchased 5 or more cups of drinks
        #within 2026-03-01 to 2026-06-30
        #created an order with 6 cups of latte
        add_test_discount_eligible_customer_and_order
        discount = add_test_discount_code_to_db

        get_as_employee(@manager, "/manager/discounts/details", {"viewcode" => discount.discount_code})

        eligible_customer = discount.get_all_eligible_customers.first
        expect(eligible_customer.name).to eq("Mikel Merino")
        expect(eligible_customer.loyalty_number).to eq(1)
        
        expect(last_response.body).to include("Eligible Customers")
        expect(last_response.body).to include("Name")
        expect(last_response.body).to include("Mikel Merino")

        expect(last_response.body).to include("Loyalty Number")
        expect(last_response.body).to include("1")

        expect(last_response.body).to include("Eligible Amount")
        expect(last_response.body).to include("6")

        expect(last_response.body).to include("Code Status")
        expect(last_response.body).to include("unredeemed")
      end
    end
  end

end