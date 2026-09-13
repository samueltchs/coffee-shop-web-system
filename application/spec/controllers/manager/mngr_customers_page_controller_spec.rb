require_relative "../../../helpers/conversions"

RSpec.describe "manager customers page controller" do
  include Conversions
  describe "GET /manager/customers" do
    context "when not logged in" do
      it "redirects to employee login page" do
        get "/manager/customers"

        expect(last_response).to be_redirect
        expect(last_response.location).to include("/employee-login-page?error")
      end
    end

    context "when logged in but not as manager" do
      it "redirects to the appropriate page" do
        barista = add_test_barista_to_db

        get_as_employee(barista, "/manager/customers")

        expect(last_response).to be_redirect
        expect(last_response.location).to end_with("/barista/main")
      end
    end

    context "when logged in as manager" do
      before do
        @manager = add_test_manager_to_db
      end

      it "loads the customers page" do
        get_as_employee(@manager, "/manager/customers")

        expect(last_response).to be_ok
        expect(last_response.body).to include("Customers")
      end

      it "shows total number of accounts" do
        add_test_customer_to_db
        add_test_customer_to_db(
          2, "John", "Smith", "address1", "address2",
          "Sheffield", "S1 1AA", "7710002001",
          "john@gmail.com"
        )

        get_as_employee(@manager, "/manager/customers")

        expect(last_response.body).to include("Total Accounts: 2")
      end

      it "shows current month number of signup" do
        add_test_customer_to_db
        add_test_customer_to_db(
          2, "Old", "Customer", "address1", "address2",
          "Sheffield", "S1 2LL", "7710002111",
          "test@gmail.com", "0",
          (Time.now.utc - SECONDS_IN_MONTH * 2).to_s
        )

        get_as_employee(@manager, "/manager/customers")

        expect(last_response.body).to include("Current Month Sign-up: 1")
      end

      it "has a button to show the monthly signup line chart for past last year" do
        get_as_employee(@manager, "/manager/customers")

        expect(last_response.body).to include('id="view_btn" href="#signup-graph"')
        expect(last_response.body).to include("View")
      end

      it "shows daterange filter form" do
        get_as_employee(@manager, "/manager/customers")

        expect(last_response.body).to include('form method="get" action="/manager/customers"')
        expect(last_response.body).to include('type="date" id="from" name="from"')
        expect(last_response.body).to include('type="date" id="to" name="to"')
        
        expect(last_response.body).to include('name="select_filter"')
        expect(last_response.body).to include("Register Date")
        expect(last_response.body).to include("Sales Date")
        
        expect(last_response.body).to include('type="submit" id="submit_btn" value="Filter"')

        expect(last_response.body).to include('id="reset_btn"')
        expect(last_response.body).to include('href="?from&to"')
      end

      it "shows a table of customers with correct headers" do
        get_as_employee(@manager, "/manager/customers")

        expect(last_response.body).to include('table class="scrollable-table"')
        expect(last_response.body).to include("Loyalty Number")
        expect(last_response.body).to include("Name")
        expect(last_response.body).to include("Amount Spent")
        expect(last_response.body).to include("No. of Orders")
        expect(last_response.body).to include("Register Time")
        expect(last_response.body).to include("Details")
      end

      it "shows all customer details in table" do
        customer = add_test_customer_to_db
        get_as_employee(@manager, "/manager/customers")

        expect(last_response.body).to include(customer.loyalty_number.to_s)
        expect(last_response.body).to include(customer.name)
        expect(last_response.body).to include("£%.2f" % customer.total_purchase)
        expect(last_response.body).to include(customer.num_purchase.to_s)
        reg_time = formatted_time(uk_time(customer.parse_regtime))
        expect(last_response.body).to include(reg_time)
      end

      it "shows links for each customers' details page" do
        customer = add_test_customer_to_db
        get_as_employee(@manager, "/manager/customers")

        expect(last_response.body).to include(
          "/manager/customers/details?loyal_num=#{customer.loyalty_number}"
        )
      end

      context "Date Range Filter" do
        it "filters customers by Account Register Date range" do
          add_test_customer_to_db(
            1, "Recent", "Tester", "address1", "address2",
            "Sheffield", "S1 1AA", "7710002000",
            "test_recent@gmail.com", "0",
            "2026-04-15 21:37:56 +0000"
          )

          add_test_customer_to_db(
            2, "Old", "Tester", "address1", "address2",
            "Sheffield", "S1 1AA", "7710002101",
            "test_old@gmail.com", "0",
            "2026-02-15 15:37:56 +0000"
          )

          get_as_employee(
            @manager, "/manager/customers",
            { "select_filter" => "reg_date", "from" => "2026-04-01", "to" => "2026-04-30" }
          )

          expect(last_response.body).to include("Recent Tester")
          expect(last_response.body).not_to include("Old Tester")
        end

        it "filters and show all customers' totoal amount and number of orders within Sales Date range" do
          recent_tester = add_test_customer_to_db(
            1, "Recent", "Tester", "address1", "address2",
            "Sheffield", "S1 1AA", "7710002000",
            "test_recent@gmail.com", "0",
            "2026-04-15 21:37:56 +0000"
          )
          #new order 1 for Recent Tester
          add_test_order_to_db(
            1, "2026-04-20 21:37:56 +0000", "10", "20", "1",
            "ABC00001", "Online", "1", "Completed", "Paid",
            nil, "20", nil
          )
          #new order 2 for Recent Tester
          add_test_order_to_db(
            1, "2026-04-21 21:37:56 +0000", "10", "32", "1",
            "ABC00001", "Online", "1", "Completed", "Paid",
            nil, "32", nil
          )

          old_tester = add_test_customer_to_db(
            2, "Old", "Tester", "address1", "address2",
            "Sheffield", "S1 1AA", "7710002101",
            "test_old@gmail.com", "0",
            "2026-02-15 15:37:56 +0000"
          )
          #old order 3 for Old Tester
          add_test_order_to_db(
            2, "2026-01-21 21:37:56 +0000", "10", "20", "1",
            "ABC00001", "Online", "1", "Completed", "Paid",
            nil, "20", nil
          )
          #new order 4 for Old Tester
          add_test_order_to_db(
            2, "2026-04-23 21:37:56 +0000", "10", "15", "1",
            "ABC00001", "Online", "1", "Completed", "Paid",
            nil, "15", nil
          )

          get_as_employee(
            @manager, "/manager/customers",
            { "select_filter" => "order_date", "from" => "2026-04-01", "to" => "2026-04-30" }
          )

          recent_tester_total_within_dates = 20 + 32
          old_tester_total = 20 + 15
          old_tester_total_within_dates = 15

          expect(last_response.body).to include("£%.2f" % recent_tester_total_within_dates)
          expect(last_response.body).to include("£%.2f" % old_tester_total_within_dates)
          expect(last_response.body).not_to include("£%.2f" % old_tester_total)
        end
      end

      it "sorts customers by loyalty number ascending" do
        add_test_customer_to_db(2, "B", "Customer")
        add_test_customer_to_db(1, "A", "Customer")

        get_as_employee(
          @manager, "/manager/customers",
          { "sort" => "loyalty_number", "order" => "asc" }
        )

        expect(last_response.body.index("1")).to be < last_response.body.index("2")
      end

      it "sorts customers by name ascending" do
        add_test_customer_to_db(1, "Z", "Customer")
        add_test_customer_to_db(2, "A", "Customer")

        get_as_employee(
          @manager, "/manager/customers",
          { "sort" => "name", "order" => "asc" }
        )

        expect(last_response.body.index("A Customer")).to be < 
          last_response.body.index("Z Customer")
      end

      it "sorts customers by name descending" do
        add_test_customer_to_db(1, "Z", "Customer")
        add_test_customer_to_db(2, "A", "Customer")

        get_as_employee(
          @manager, "/manager/customers",
          { "sort" => "name", "order" => "desc" }
        )

        expect(last_response.body.index("A Customer")).to be > 
          last_response.body.index("Z Customer")
      end

      it "defaults to reg_time sort when invalid sort param given" do
        recent_tester = add_test_customer_to_db(
          1, "Recent", "Tester", "address1", "address2",
          "Sheffield", "S1 1AA", "7710002000",
          "test_recent@gmail.com", "0",
          "2026-04-15 21:37:56 +0000"
        )

        old_tester = add_test_customer_to_db(
          2, "Old", "Tester", "address1", "address2",
          "Sheffield", "S1 1AA", "7710002101",
          "test_old@gmail.com", "0",
          "2026-02-15 15:37:56 +0000"
        )

        get_as_employee(
          @manager, "/manager/customers",
          { "sort" => "error",  "order" => "asc" }
        )

        expect(last_response).to be_ok
        expect(last_response.body.index("Recent Tester")).to be > 
          last_response.body.index("Old Tester")
      end

      it "defaults to desc order when invalid order param given" do
        add_test_customer_to_db(1, "Z", "Customer")
        add_test_customer_to_db(2, "A", "Customer")

        get_as_employee(
          @manager, "/manager/customers",
          { "sort" => "name", "order" => "wrong" }
        )

        expect(last_response).to be_ok
        expect(last_response.body.index("Z Customer")).to be < 
          last_response.body.index("A Customer")
      end
    end
  end

  describe "GET /manager/customers/details" do
    context "when not logged in" do
      it "redirects to employee login page" do
        get "/manager/customers/details"

        expect(last_response).to be_redirect
        expect(last_response.location).to include("/employee-login-page?error")
      end
    end

    context "when logged in but not as manager" do
      it "redirects to the appropriate page" do
        barista = add_test_barista_to_db
        get_as_employee(
          barista, "/manager/customers/details", { "loyal_num" => "1"})

        expect(last_response).to be_redirect
        expect(last_response.location).to end_with("/barista/main")
      end
    end

    context "when logged in as manager" do
      before do
        @manager = add_test_manager_to_db
        @customer = add_test_customer_to_db
      end

      it "loads customer details page" do
        get_as_employee(
          @manager, "/manager/customers/details", 
          { "loyal_num" => @customer.loyalty_number }
        )

        expect(last_response).to be_ok
        expect(last_response.body).to include("Customer Details")
      end

      it "shows customer's personal details" do
        get_as_employee(
          @manager, "/manager/customers/details", 
          { "loyal_num" => @customer.loyalty_number }
        )

        expect(last_response.body).to include(@customer.name)
        expect(last_response.body).to include("Loyalty Number:")
        expect(last_response.body).to include(@customer.loyalty_number.to_s)
        expect(last_response.body).to include("First Name:")
        expect(last_response.body).to include(@customer.first_name)
        expect(last_response.body).to include("Last Name:")
        expect(last_response.body).to include(@customer.last_name)
        expect(last_response.body).to include("Email:")
        expect(last_response.body).to include(@customer.email)
        expect(last_response.body).to include("Phone Number:")
        expect(last_response.body).to include(@customer.phone_number)
      end

      it "shows customer's address details" do
        get_as_employee(
          @manager, "/manager/customers/details", 
          { "loyal_num" => @customer.loyalty_number }
        )

        expect(last_response.body).to include("Address:")
        expect(last_response.body).to include(@customer.address_line_1)
        expect(last_response.body).to include(@customer.address_line_2)
        expect(last_response.body).to include("City:")
        expect(last_response.body).to include(@customer.city)
        expect(last_response.body).to include("Postcode:")
        expect(last_response.body).to include(@customer.postcode)
      end

      it "shows customer's account details" do
        get_as_employee(
          @manager, "/manager/customers/details", 
          { "loyal_num" => @customer.loyalty_number }
        )

        expect(last_response.body).to include("Register Time:")
        expect(last_response.body).to include(formatted_time(uk_time(@customer.parse_regtime)))
        expect(last_response.body).to include("Account Status:")
        expect(last_response.body).to include(@customer.status)
      end

      it "shows customer's account details" do
        #set the @customer's stamps to 7
        @customer.stamps = 7
        @customer.save_changes
        
        get_as_employee(
          @manager, "/manager/customers/details", 
          { "loyal_num" => @customer.loyalty_number }
        )

        expect(last_response.body).to include("Stamps:")
        expect(last_response.body).to include("<span>#{@customer.stamps.to_s}</span>")

        expect(last_response.body).to include("<h4>Stamps</h4>")
        #test how many colored stamps are in the stamps_section
        expect(last_response.body.scan("stamp-icons stamped").count).to eq(7)
        #test how many uncolored stamps are in the stamps_section
        expect(last_response.body.scan("stamp-icons unstamped").count).to eq(3)
      end

      it "shows back button to customers page" do
        get_as_employee(
          @manager, "/manager/customers/details", 
          { "loyal_num" => @customer.loyalty_number }
        )

        expect(last_response.body).to include("arrow_back")
        expect(last_response.body).to include("href='/manager/customers?")
      end

      it "shows customer summary section" do
        #add new orders to see summary
        order1, order2, order3 = add_test_orders_for_mngr_customers

        get_as_employee(
          @manager, "/manager/customers/details", 
          { "loyal_num" => @customer.loyalty_number }
        )

        #@customer's orders statistics
        num_orders = Order.where(loyalty_number: @customer.loyalty_number).count
        total = order1.price + order2.price + order3.price
        average = total / num_orders

        expect(last_response.body).to include("Summary")
        expect(last_response.body).to include("Total Spending: #{"£%.2f" % total}")
        expect(last_response.body).to include("Average Spending: #{"£%.2f" % average}")
        expect(last_response.body).to include("Number of Orders: #{num_orders}")
      end

      it "shows customer order table and correct headers" do
        get_as_employee(
          @manager, "/manager/customers/details", 
          { "loyal_num" => @customer.loyalty_number }
        )

        expect(last_response.body).to include('table class="scrollable-table"')
        expect(last_response.body).to include("Order Number")
        expect(last_response.body).to include("Date")
        expect(last_response.body).to include("Value")
        expect(last_response.body).to include("Status")
      end

      it "shows customer's all orders" do
        order1, order2, order3 = add_test_orders_for_mngr_customers

        get_as_employee(
          @manager, "/manager/customers/details", 
          { "loyal_num" => @customer.loyalty_number }
        )
        
        Order.where(loyalty_number: @customer.loyalty_number).each do |order|
          expect(last_response.body).to include(order.order_unique_id.to_s)
          time = formatted_time(uk_time(parse_time(order.date_placed)))
          expect(last_response.body).to include(time)
          expect(last_response.body).to include("£%.2f" % order.price)
          expect(last_response.body).to include(order.status)
        end
      end

      it "does not show orders from other customers" do
        other_customer = add_test_customer_to_db(2)

        other_order = add_test_order_to_db(
          other_customer.loyalty_number, "2026-04-15 10:00:00 +0000", 
          "5", "50", "1", "OTHER123", "Online", "1", "Completed", "Paid", nil, "50"
        )

        get_as_employee(
          @manager, "/manager/customers/details", 
          { "loyal_num" => @customer.loyalty_number }
        )

        expect(last_response.body).not_to include(
          "<td>#{other_order.order_unique_id.to_s}</td>"
        )
      end
    end
  end
end