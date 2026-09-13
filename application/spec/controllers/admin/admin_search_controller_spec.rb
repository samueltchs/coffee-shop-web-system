RSpec.describe "admin search controller" do
  include Conversions
  include LocalHelpers

  describe "GET /admin-search" do
    context "when logged in as admin" do
      before do
        admin = add_test_admin_to_db
        get_as_employee(admin, "/admin-search")
      end

      it "has a status code of 200 (OK)" do
        expect(last_response).to be_ok
      end

      it "displays the correct title" do
        expect(last_response.body).to include("<title>Admin Search</title>")
      end

      it "contains the filter dropdown" do
        expect(last_response.body).to include('select name="filter"')
      end

      it "contains the filter options" do
        expect(last_response.body).to include('option value="all"')
        expect(last_response.body).to include('option value="customers"')
        expect(last_response.body).to include('option value="employees"')
        expect(last_response.body).to include('option value="orders"')
      end

      it "contains the apply filter button" do
        expect(last_response.body).to include('value="Apply Filter"')
      end

      it "selects the all filter by default" do
        expect(last_response.body).to include('option value="all" selected')
      end
    end

    context "when nothing has been searched and no filter is applied" do
      before do
        @admin = add_test_admin_to_db
        @customer = add_test_customer_to_db
        @employee = add_test_barista_to_db
        @order = add_test_order_to_db
        get_as_employee(@admin, "/admin-search")
      end

      it "displays all three headlines" do
        expect(last_response.body).to include('<h1 class="search_tables">Employees</h1>')
        expect(last_response.body).to include('<h1 class="search_tables">Customers</h1>')
        expect(last_response.body).to include('<h1 class="search_tables">Orders</h1>')
      end

      it "contains each employee's username" do
        expect(last_response.body).to include("<th>Username</th>")
        expect(last_response.body).to include(@employee.username)
      end

      it "contains each employee's first name" do
        expect(last_response.body).to include("<th>First Name</th>")
        expect(last_response.body).to include(@employee.first_name)
      end

      it "contains each employee's last name" do
        expect(last_response.body).to include("<th>Last Name</th>")
        expect(last_response.body).to include(@employee.last_name)
      end

      it "contains each employee's email" do
        expect(last_response.body).to include("<th>Email</th>")
        expect(last_response.body).to include(@employee.email)
      end

      it "contains each employee's role" do
        expect(last_response.body).to include("<th>Role</th>")
        expect(last_response.body).to include(@employee.role)
      end

      it "contains each customer's loyalty number" do
        expect(last_response.body).to include("<th>Loyalty Card Number</th>")
        expect(last_response.body).to include(@customer.loyalty_number.to_s)
      end

      it "contains each customer's first name" do
        expect(last_response.body).to include(@customer.first_name)
      end

      it "contains each customer's last name" do
        expect(last_response.body).to include(@customer.last_name)
      end

      it "contains each customer's phone number" do
        expect(last_response.body).to include("<th>Phone No.</th>")
        expect(last_response.body).to include(@customer.phone_number)
      end

      it "contains each customer's email" do
        expect(last_response.body).to include(@customer.email)
      end

      it "contains each customer's status" do
        expect(last_response.body).to include("<th>Status</th>")
        expect(last_response.body).to include(@customer.status)
      end

      it "contains each order's id" do
        expect(last_response.body).to include("<th>Order ID</th>")
        expect(last_response.body).to include(@order.order_unique_id.to_s)
      end

      it "contains each order's associated customer loyalty number" do
        expect(last_response.body).to include("<th>Customer Loyalty No.</th>")
        expect(last_response.body).to include(@order.loyalty_number.to_s)
      end

      it "contains each order's date placed formatted" do
        expect(last_response.body).to include("<th>Date Placed</th>")
        expect(last_response.body).to include(format_date(@order.date_placed))
      end

      it "contains each order's tracking id" do
        expect(last_response.body).to include("<th>Tracking ID</th>")
        expect(last_response.body).to include(@order.tracking_id.to_s)
      end

      it "contains each order's reference id" do
        expect(last_response.body).to include("<th>Reference ID</th>")
        expect(last_response.body).to include(@order.reference_id)
      end

      it "contains who fulfilled each order" do
        expect(last_response.body).to include("<th>Barista</th>")
        expect(last_response.body).to include(@order.barista)
      end

      it "contains each order's order fulfilment" do
        expect(last_response.body).to include("<th>Order Fulfilment</th>")
        expect(last_response.body).to include(@order.order_fulfilment)
      end

      it "contains each order's status" do
        expect(last_response.body).to include(@order.status)
      end

      it "contains each order's delivery status" do
        expect(last_response.body).to include("<th>Delivery Status</th>")
        expect(last_response.body).to include(@order.get_delivered)
      end

      it "contains each order's payment method" do
        expect(last_response.body).to include("<th>Payment Method</th>")
      end

      it "contains each order's discount code used" do
        expect(last_response.body).to include("<th>Discount Code</th>")
        expect(last_response.body).to include(@order.get_discount_code_used)
      end

      it "does not display incomplete orders" do
        add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC123456", "Online", 1, "Incomplete", "Unpaid")
        get_as_employee(@admin, "/admin-search")
        expect(last_response.body).not_to include("ABC123456")
      end

      it "contains a link to each employee's page" do
        expect(last_response.body).to include("admin-employee?username=#{@employee.username}")
      end

      it "contains a link to each customer's page" do
        expect(last_response.body).to include("/admin-customer?loyalty_number=#{@customer.loyalty_number}")
      end

      it "contains a link to each order's page" do
        expect(last_response.body).to include("/admin-order?order_id=#{@order.order_unique_id}")
      end
    end

    context "given nothing has been searched but a filter is applied" do
      before do
        @admin = add_test_admin_to_db
        @customer = add_test_customer_to_db
        @employee = add_test_barista_to_db
        @order = add_test_order_to_db
      end

      context "when the customers filter is applied" do
        before do
          get_as_employee(@admin, "/admin-search?admin_search=&filter=customers")
        end

        it "selects the customers filter" do
          expect(last_response.body).to include('option value="customers" selected')
        end

        it "displays only the customers headline" do
          expect(last_response.body).to include('<h1 class="search_tables">Customers</h1>')
          expect(last_response.body).not_to include('<h1 class="search_tables">Employees</h1>')
          expect(last_response.body).not_to include('<h1 class="search_tables">Orders</h1>')
        end
      end
      
      context "when the employees filter is applied" do
        before do
          get_as_employee(@admin, "/admin-search?admin_search=&filter=employees")
        end

        it "selects the employees filter" do
          expect(last_response.body).to include('option value="employees" selected')
        end

        it "displays only the employees headline" do
          expect(last_response.body).to include('<h1 class="search_tables">Employees</h1>')
          expect(last_response.body).not_to include('<h1 class="search_tables">Customers</h1>')
          expect(last_response.body).not_to include('<h1 class="search_tables">Orders</h1>')
        end
      end

      context "when the orders filter is applied" do
        before do
          get_as_employee(@admin, "/admin-search?admin_search=&filter=orders")
        end

        it "selects the orders filter" do
          expect(last_response.body).to include('option value="orders" selected')
        end

        it "displays only the orders headline" do
          expect(last_response.body).to include('<h1 class="search_tables">Orders</h1>')
          expect(last_response.body).not_to include('<h1 class="search_tables">Employees</h1>')
          expect(last_response.body).not_to include('<h1 class="search_tables">Customers</h1>')
        end
      end
    end

    context "when a search is made" do
      it "preserves the search made in the search form" do
        admin = add_test_admin_to_db
        get_as_employee(admin, "/admin-search?admin_search=George")
        expect(last_response.body).to include('value="George"')
      end
    end

    context "when a search is made with no filter and matches entries" do
      it "displays only the headlines of the tables with matching entries" do
        admin = add_test_admin_to_db
        add_test_barista_to_db("george", "George")
        add_test_customer_to_db(1, "George")
        add_test_order_to_db
        get_as_employee(admin, "/admin-search?admin_search=George")

        expect(last_response.body).to include('<h1 class="search_tables">Customers</h1>')
        expect(last_response.body).to include('<h1 class="search_tables">Employees</h1>')
        expect(last_response.body).not_to include('<h1 class="search_tables">Orders</h1>')
      end
    end

    context "when a search is made but matches no entries" do
      before do
        admin = add_test_admin_to_db
        add_test_barista_to_db("barista")
        get_as_employee(admin, "/admin-search?admin_search=manager")
      end

      it "displays the no matching entries found message" do
        expect(last_response.body).to include("No matching entries found.")
      end

      it "does not contain any table or headline" do
        expect(last_response.body).not_to include('<table class="admin_table">')
        expect(last_response.body).not_to include('<h1 class="search_tables">Customers</h1>')
        expect(last_response.body).not_to include('<h1 class="search_tables">Employees</h1>')
        expect(last_response.body).not_to include('<h1 class="search_tables">Orders</h1>')
      end
    end

    context "given a search is made with a filter applied" do
      before do
        @admin = add_test_admin_to_db
        add_test_barista_to_db("George", "George")
        add_test_customer_to_db(1, "George")
        add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC12345", "George")
      end

      context "when the filter is the employees filter" do
        it "displays only the employee table headline" do
          get_as_employee(@admin, "/admin-search?admin_search=George&filter=employees")

          expect(last_response.body).to include('<h1 class="search_tables">Employees</h1>')
          expect(last_response.body).not_to include('<h1 class="search_tables">Customers</h1>')
          expect(last_response.body).not_to include('<h1 class="search_tables">Orders</h1>')
        end
      end

      context "when the filter is the customers filter" do
        it "displays only the customers table headline" do
          get_as_employee(@admin, "/admin-search?admin_search=George&filter=customers")

          expect(last_response.body).to include('<h1 class="search_tables">Customers</h1>')
          expect(last_response.body).not_to include('<h1 class="search_tables">Employees</h1>')
          expect(last_response.body).not_to include('<h1 class="search_tables">Orders</h1>')
        end
      end

      context "when the filter is the orders filter" do
        it "displays only the orders table headline" do
          get_as_employee(@admin, "/admin-search?admin_search=George&filter=orders")

          expect(last_response.body).to include('<h1 class="search_tables">Orders</h1>')
          expect(last_response.body).not_to include('<h1 class="search_tables">Employees</h1>')
          expect(last_response.body).not_to include('<h1 class="search_tables">Customers</h1>')
        end
      end
    end
  end
end
