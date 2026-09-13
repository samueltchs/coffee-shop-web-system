require_relative "../../spec_helper"

RSpec.describe "Barista search customer controller" do
  before do
    @barista = add_test_barista_to_db
    login_as_employee(@barista)
  end

  describe "GET /barista/search-customer" do
    before do
      # Distinct last names for no search overlap
      @jim   = add_test_customer_to_db(1,   "Jim",   "Smith")
      @mac   = add_test_customer_to_db(2,   "Mac",   "Jones")
      @bubsy = add_test_customer_to_db(11,  "Bubsy", "Parker")
      @samus = add_test_customer_to_db(111, "Samus", "Aran")
    end

    it "returns 200" do
      get_as_employee(@barista, "/barista/search-customer")
      expect(last_response.status).to eq(200)
    end

    context "with an empty search term" do
      it "returns all customers" do
        get_as_employee(@barista, "/barista/search-customer", { search_field: "" })
        expect(last_response.body).to include("Jim", "Mac", "Bubsy", "Samus")
      end
    end

    context "when searching by name" do
      it "returns customers whose first name contains the term (case-insensitive)" do
        get_as_employee(@barista, "/barista/search-customer", { search_field: "bu" })
        expect(last_response.body).to include("Bubsy")
        expect(last_response.body).not_to include("Jim", "Mac", "Samus")
      end

      it "returns customers whose last name contains the term (case-insensitive)" do
        get_as_employee(@barista, "/barista/search-customer", { search_field: "jo" })
        expect(last_response.body).to include("Mac")
        expect(last_response.body).not_to include("Jim", "Bubsy", "Samus")
      end

      it "returns all customers when the term appears in every name" do
        get_as_employee(@barista, "/barista/search-customer", { search_field: "s" })
        expect(last_response.body).to include("Jim", "Mac", "Bubsy", "Samus")
      end

      it "returns no results when the term matches no customer name" do
        get_as_employee(@barista, "/barista/search-customer", { search_field: "Zoltan" })
        expect(last_response.body).not_to include("Jim", "Mac", "Bubsy", "Samus")
      end
    end

    context "when searching by loyalty number" do
      it "returns only the customer with that exact loyalty number" do
        get_as_employee(@barista, "/barista/search-customer", { search_field: "2" })
        expect(last_response.body).to include("Mac")
        expect(last_response.body).not_to include("Jim", "Bubsy", "Samus")
      end

      it "does not partially match loyalty numbers" do
        #Check that numbers have to be specific (11 will not give the result: 1 or 111)
        get_as_employee(@barista, "/barista/search-customer", { search_field: "11" })
        expect(last_response.body).to include("Bubsy")
        expect(last_response.body).not_to include("Jim", "Mac", "Samus")
      end

      it "returns no results when no customer has that loyalty number" do
        get_as_employee(@barista, "/barista/search-customer", { search_field: "999" })
        expect(last_response.body).not_to include("Jim", "Mac", "Bubsy", "Samus")
      end
    end

    context "when searching by email" do
      it "returns all customers whose email matches exactly" do
        get_as_employee(@barista, "/barista/search-customer", { search_field: "email@gmail.com" })
        expect(last_response.body).to include("Jim", "Mac", "Bubsy", "Samus")
      end

      it "returns no results when no customer has that email" do
        get_as_employee(@barista, "/barista/search-customer", { search_field: "unknown@example.com" })
        expect(last_response.body).not_to include("Jim", "Mac", "Bubsy", "Samus")
      end
    end
  end

  describe "POST /barista/add-stamps" do
    before do
      @customer = add_test_customer_to_db
      @customer.update(stamps: 5)
    end

    it "adds the given number of stamps to the customer's total" do
      post_as_employee(@barista, "/barista/add-stamps", {
        customer_loyalty_number: @customer.loyalty_number,
        stamp_button: "+",
        stamp_amount_field: 2,
        filter_maintenance: ""
      })
      expect(Customer.first(loyalty_number: @customer.loyalty_number).stamps).to eq(7)
    end

    it "subtracts the given number of stamps from the customer's total" do
      post_as_employee(@barista, "/barista/add-stamps", {
        customer_loyalty_number: @customer.loyalty_number,
        stamp_button: "-",
        stamp_amount_field: 3,
        filter_maintenance: ""
      })
      expect(Customer.first(loyalty_number: @customer.loyalty_number).stamps).to eq(2)
    end

    it "caps stamps at 9 when adding would exceed the maximum" do
      post_as_employee(@barista, "/barista/add-stamps", {
        customer_loyalty_number: @customer.loyalty_number,
        stamp_button: "+",
        stamp_amount_field: 10,
        filter_maintenance: ""
      })
      expect(Customer.first(loyalty_number: @customer.loyalty_number).stamps).to eq(9)
    end

    it "floors stamps at 0 when subtracting would go below zero" do
      post_as_employee(@barista, "/barista/add-stamps", {
        customer_loyalty_number: @customer.loyalty_number,
        stamp_button: "-",
        stamp_amount_field: 10,
        filter_maintenance: ""
      })
      expect(Customer.first(loyalty_number: @customer.loyalty_number).stamps).to eq(0)
    end

    it "does not change stamps when the amount is 0" do
      post_as_employee(@barista, "/barista/add-stamps", {
        customer_loyalty_number: @customer.loyalty_number,
        stamp_button: "+",
        stamp_amount_field: 0,
        filter_maintenance: ""
      })
      expect(Customer.first(loyalty_number: @customer.loyalty_number).stamps).to eq(5)
    end

    it "does not change stamps when the amount field is blank" do
      post_as_employee(@barista, "/barista/add-stamps", {
        customer_loyalty_number: @customer.loyalty_number,
        stamp_button: "+",
        stamp_amount_field: "",
        filter_maintenance: ""
      })
      expect(Customer.first(loyalty_number: @customer.loyalty_number).stamps).to eq(5)
    end

    it "does not change stamps when the operand is unrecognised" do
      post_as_employee(@barista, "/barista/add-stamps", {
        customer_loyalty_number: @customer.loyalty_number,
        stamp_button: "x",
        stamp_amount_field: 3,
        filter_maintenance: ""
      })
      expect(Customer.first(loyalty_number: @customer.loyalty_number).stamps).to eq(5)
    end

    it "does nothing when the customer does not exist" do
      expect {
        post_as_employee(@barista, "/barista/add-stamps", {
          customer_loyalty_number: 9999,
          stamp_button: "+",
          stamp_amount_field: 1,
          filter_maintenance: ""
        })
      }.not_to raise_error
    end

    it "redirects back to the search page preserving the search filter" do
      post_as_employee(@barista, "/barista/add-stamps", {
        customer_loyalty_number: @customer.loyalty_number,
        stamp_button: "+",
        stamp_amount_field: 1,
        filter_maintenance: "Jim"
      })
      expect(last_response).to be_redirect
      expect(last_response.location).to include("barista/search-customer")
      expect(last_response.location).to include("search_field=Jim")
    end
  end
end
