RSpec.describe "admin core controller" do
  include Conversions
  include LocalHelpers

  describe "GET /admin-main" do
    context "when logged in as admin" do
      before do
        admin = add_test_admin_to_db
        get_as_employee(admin, "/admin-main")
      end
    
      it "has a status code of 200 (OK)" do
        expect(last_response).to be_ok
      end

      it "contains link to register employee page" do
        expect(last_response.body).to include("/admin-add-employee")
      end

      it "contains link to customers search page" do
        expect(last_response.body).to include("/admin-search?filter=customers")
      end

      it "contains link to employees search page" do
        expect(last_response.body).to include("/admin-search?filter=employees")
      end

      it "contains link to orders search page" do
        expect(last_response.body).to include("/admin-search?filter=orders")
      end

      it "contains link to home page" do
        expect(last_response.body).to include("/admin-main")
      end

      it "contains link to account settings page" do
        expect(last_response.body).to include("/admin-settings")
      end

      it "contains link to admin inbox page" do
        expect(last_response.body).to include("/admin-inbox")
      end

      it "contains link to admin dashboard page" do
        expect(last_response.body).to include("/admin-dashboard")
      end

      it "contains the logout link" do
        expect(last_response.body).to include("/employee-logout")
      end

      it "contains the search form" do
        expect(last_response.body).to include('action="/admin-search"')
      end

      it "contains search input field" do
        expect(last_response.body).to include('name="admin_search"')
      end

      it "displays zero customer count when no customers exist" do
        expect(last_response.body).to include("Total customers:")
        expect(last_response.body).to include(">0<")
      end

      it "displays correct employee count when only admin exists" do
        expect(last_response.body).to include("Total employees:")
        expect(last_response.body).to include(">1<")
      end

      it "displays zero order count when no orders exist" do
        expect(last_response.body).to include("Total orders:")
        expect(last_response.body).to include(">0<")
      end

      it "displays the correct title" do
        expect(last_response.body).to include("Admin main page")
      end

      it "displays zero inbox messages when no flagged / suspended customers exist" do
        expect(last_response.body).to include("Inbox (0)")
      end
    end

    context "when customers/employees/orders exist" do
      before do
        admin = add_test_admin_to_db
        add_test_customer_to_db(1)
        add_flagged_customer_to_db(2)
        add_suspended_customer_to_db(3)
        add_deleted_customer_to_db(4)
        add_test_customer_to_db(5)
        add_test_barista_to_db
        add_test_manager_to_db
        add_test_order_to_db(
          1, Time.now.utc, 7.2, 7.7, 1, "ABC12345", "Online", 1, "Completed", "Paid", ""
        )
        add_test_order_to_db(
          1, Time.now.utc, 8.0, 8.2, 2, "ABC12346", "Alex", 0, "Collected", "Paid", "12345678"
        )
        get_as_employee(admin, "/admin-main")
      end

      it "displays correct counts" do
        expect(last_response.body).to include("Total customers:")
        expect(last_response.body).to include(">4<")
        expect(last_response.body).to include("(1 Suspended)")
        expect(last_response.body).to include("Total employees:")
        expect(last_response.body).to include(">3<")
        expect(last_response.body).to include("Total orders:")
        expect(last_response.body).to include(">2<")
      end
    end

    context "when a flagged customer exists" do
      before do
        admin = add_test_admin_to_db
        add_flagged_customer_to_db
        get_as_employee(admin, "/admin-main")
      end

      it "displays correct inbox count" do
        expect(last_response.body).to include("Inbox (1)")
      end
    end

    context "when a suspended customer past 3 months exists" do
      before do
        admin = add_test_admin_to_db
        add_suspended_customer_to_db(
          2, Time.now.utc - SECONDS_IN_DAY * 95, Time.now.utc - SECONDS_IN_DAY * 90
        )
        get_as_employee(admin, "/admin-main")
      end

      it "displays correct inbox count" do
        expect(last_response.body).to include("Inbox (1)")
      end
    end

    context "when deleted customers and employees exist" do
      before do
        admin = add_test_admin_to_db
        add_test_customer_to_db
        add_deleted_customer_to_db
        add_deleted_employee_to_db
        get_as_employee(admin, "/admin-main")
      end

      it "does not include deleted customers in the customer count" do
        expect(last_response.body).to include("Total customers:")
        expect(last_response.body).to include(">1<")
        expect(last_response.body).not_to include(">2<")
      end

      it "does not include deleted employees in the employee count" do
        expect(last_response.body).to include("Total employees:")
        expect(last_response.body).to include(">1<")
        expect(last_response.body).not_to include(">2<")
      end
    end

    context "when admin has a specific first name" do
      before do
        admin = add_test_admin_to_db("admin", "Michael", "Carrick", "admin@gmail.com")
        get_as_employee(admin, "/admin-main")
      end

      it "displays the first name" do
        expect(last_response.body).to include("Welcome, Michael!")
      end
    end

    context "when admin is not found in the database" do
      it "redirects to default page" do
        admin = create_employee("admin", "Alex", "Jones", "email@gmail.com", "Admin")
        get_as_employee(admin, "/admin-main")
        expect(last_response).to be_redirect
        expect(last_response.location).to end_with("/")
      end
    end

    context "when logged in as a barista" do
      it "redirects to the barista main page" do
        barista = add_test_barista_to_db
        get_as_employee(barista, "/admin-main")
        expect(last_response).to be_redirect
        expect(last_response.location).to end_with("/barista/main")
      end
    end

    context "when logged in as a manager" do
      it "redirects to the manager dashboard" do
        manager = add_test_manager_to_db
        get_as_employee(manager, "/admin-main")
        expect(last_response).to be_redirect
        expect(last_response.location).to end_with("/manager/dashboard")
      end
    end

    context "when not logged in" do
      it "redirects to employee login page" do
        get "/admin-main"
        expect(last_response).to be_redirect
        expect(last_response.location).to include("/employee-login-page?error")
      end
    end

    context "after logging out" do
      it "redirects to employee login page" do
        admin = add_test_admin_to_db
        get_as_employee(admin, "/employee-logout")
        expect(last_response).to be_redirect
        expect(last_response.location).to include("/employee-login-page")
      end

      it "does not allow access to admin pages" do
        admin = add_test_admin_to_db
        get_as_employee(admin, "/employee-logout")
        get "/admin-main"
        expect(last_response).to be_redirect
        expect(last_response.location).to include("/employee-login-page?error")
      end
    end

    context "when admin visits the main page" do
      before do
        @admin = add_test_admin_to_db
      end

      it "runs the inactivity checks on first visit" do
        customer = add_test_customer_to_db(
          1, "Mikel", "Merino", "address1", "address2", "Sheffield", "S1 1AA",
          "7710002000", "email@gmail.com", 0, Time.now.utc - SECONDS_IN_MONTH * 6
        )
        get_as_employee(@admin, "/admin-main")
        edited_customer = Customer.first(loyalty_number: customer.loyalty_number)
        expect(edited_customer.status).to eq("Flagged")
        expect(edited_customer.flagged_at).not_to be_nil
      end

      it "it does not run the inactivity checks if last check was less than an hour ago" do
        get_as_employee(@admin, "/admin-main")
        customer = add_test_customer_to_db(
          1, "Mikel", "Merino", "address1", "address2", "Sheffield", "S1 1AA",
          "7710002000", "email@gmail.com", 0, Time.now.utc - SECONDS_IN_MONTH * 6
        )
        get_as_employee(@admin, "/admin-main")
        edited_customer = Customer.first(loyalty_number: customer.loyalty_number)
        expect(edited_customer.status).to eq("Active")
        expect(edited_customer.flagged_at).to be_nil
      end

      it "runs the checks if the last check was at least an hour ago" do
        customer = add_test_customer_to_db(
          1, "Mikel", "Merino", "address1", "address2", "Sheffield", "S1 1AA",
          "7710002000", "email@gmail.com", 0, Time.now.utc - SECONDS_IN_MONTH * 6
        )
        get "/admin-main", {}, { "rack.session" => 
          { username: @admin.username, role: 'Admin', "last_inactivity_check" => (Time.now.utc - 60 * 60).to_s } 
        }
        edited_customer = Customer.first(loyalty_number: customer.loyalty_number)
        expect(edited_customer.status).to eq("Flagged")
        expect(edited_customer.flagged_at).not_to be_nil
      end
    end
  end

  describe "GET /admin-settings" do
    context "when logged in as an existing admin" do
      before do
        admin = add_test_admin_to_db
        get_as_employee(admin, "/admin-settings")
      end

      it "has a status code of 200 (OK)" do
        expect(last_response).to be_ok
      end

      it "displays the correct title" do
        expect(last_response.body).to include("<title>Admin profile</title>")
      end

      it "displays the correct headline" do
        expect(last_response.body).to include("<h1>Admin profile</h1>")
      end

      it "contains the update username button" do
        expect(last_response.body).to include('value="Update username"')
      end

      it "contains the update username form" do
        expect(last_response.body).to include('action="/admin-update-username"')
      end

      it "contains username input field" do
        expect(last_response.body).to include('name="username"')
      end

      it "contains the update email button" do
        expect(last_response.body).to include('value="Update email"')
      end

      it "contains the update email form" do
        expect(last_response.body).to include('action="/admin-update-email"')
      end

      it "contains email input field" do
        expect(last_response.body).to include('name="email"')
      end

      it "contains the update first name button" do
        expect(last_response.body).to include('value="Update first name"')
      end

      it "contains the update first name form" do
        expect(last_response.body).to include('action="/admin-update-first-name"')
      end

      it "contains first name input field" do
        expect(last_response.body).to include('name="first"')
      end

      it "contains the update last name button" do
        expect(last_response.body).to include('value="Update last name"')
      end

      it "contains the update last name form" do
        expect(last_response.body).to include('action="/admin-update-last-name"')
      end

      it "contains last name input field" do
        expect(last_response.body).to include('name="last"')
      end

      it "contains the change password form" do
        expect(last_response.body).to include('action="/admin-change-password"')
      end

      it "displays the label for the password input field" do
        expect(last_response.body).to include("Update password:")
      end

      it "contains password input field" do
        expect(last_response.body).to include('name="password"')
      end

      it "displays the label for the confirm password input field" do
        expect(last_response.body).to include("Confirm new password:")
      end

      it "contains confirm password input field" do
        expect(last_response.body).to include('name="conf_password"')
      end

      it "masks the password fields in the reset password form" do
        expect(last_response.body).to include('type="password"')
      end
    end

    context "with specific admin data" do
      before do
        admin = add_test_admin_to_db("AdminUsername", "Bibi", "Carter", "employee@gmail.com")
        get_as_employee(admin, "/admin-settings")
      end

      it "displays the correct username" do
        expect(last_response.body).to include("Username:")
        expect(last_response.body).to include("AdminUsername")
      end

      it "displays the correct email" do
        expect(last_response.body).to include("Email:")
        expect(last_response.body).to include("employee@gmail.com")
      end

      it "displays full name correctly" do
        expect(last_response.body).to include("Name:")
        expect(last_response.body).to include("Bibi Carter")
      end
    end

    context "when admin is not found in the database" do
      it "redirects to default page" do
        admin = create_employee("admin", "Alex", "Jones", "email@gmail.com", "Admin")
        get_as_employee(admin, "/admin-settings")
        expect(last_response).to be_redirect
        expect(last_response.location).to end_with("/")
      end
    end

    context "when not logged in" do
      it "redirects to employee login page" do
        get "/admin-settings"
        expect(last_response).to be_redirect
        expect(last_response.location).to include("/employee-login-page?error")
      end
    end
  end

  describe "GET /admin-inbox" do
    context "when no messages exist" do
      before do
        admin = add_test_admin_to_db
        get_as_employee(admin, "/admin-inbox")
      end

      it "has a status code of 200 (OK)" do
        expect(last_response).to be_ok
      end

      it "displays the correct title" do
        expect(last_response.body).to include("<title>Admin inbox</title>")
      end

      it "displays the correct headline" do
        expect(last_response.body).to include("<h2>Admin inbox</h2>")
      end

      it "displays a default message" do
        expect(last_response.body).to include("No actions need to be taken.")
      end
    end

    context "when messages exist" do
      before do
        admin = add_test_admin_to_db
        @flagged_customer = add_flagged_customer_to_db(1)
        @suspended_customer = add_suspended_customer_to_db(
          2, Time.now.utc - SECONDS_IN_DAY * 95, Time.now.utc - SECONDS_IN_DAY * 90
        )
        get_as_employee(admin, "/admin-inbox")
      end

      it "displays the correct messages" do
        expect(last_response.body).to include("Customer #")
        expect(last_response.body).to include(
          "has been flagged as 6 months inactive. Suspend option now available."
        )
        expect(last_response.body).to include(
          "has not returned within 3 months of their suspension. Delete option now available."
        )
      end

      it "contains links to the customers pages" do
        expect(last_response.body).to include("/admin-customer?loyalty_number=1")
        expect(last_response.body).to include("/admin-customer?loyalty_number=2")
      end

      it "displays a timestamp for each message" do
        formatted_flagged_time = uk_time(Time.parse(@flagged_customer.flagged_at)).strftime("%d/%m/%Y %H:%M")
        expect(last_response.body).to include(formatted_flagged_time)

        formatted_suspension_time = 
          uk_time(Time.parse(@suspended_customer.suspended_at) + SECONDS_IN_MONTH * 3).strftime("%d/%m/%Y %H:%M")
        expect(last_response.body).to include(formatted_suspension_time)
      end
    end
  end

  describe "GET /admin-dashboard" do
    context "when logged in as the admin" do
      before do
        admin = add_test_admin_to_db
        get_as_employee(admin, "/admin-dashboard")
      end

      it "has a status code of 200 (OK)" do
        expect(last_response).to be_ok
      end

      it "displays the correct title" do
        expect(last_response.body).to include("<title>Admin Dashboard</title>")
      end

      it "displays the correct headline" do
        expect(last_response.body).to include("<h1>Admin Dashboard</h1>")
      end
    end

    context "when customers exist" do
      it "displays the correct customer counts" do
        admin = add_test_admin_to_db
        add_test_customer_to_db(1)
        add_flagged_customer_to_db(2)
        add_flagged_customer_to_db(3)
        add_suspended_customer_to_db(4)
        add_suspended_customer_to_db(5)
        add_suspended_customer_to_db(6)
        add_deleted_customer_to_db(7)
        add_deleted_customer_to_db(8)
        add_deleted_customer_to_db(9)
        add_deleted_customer_to_db(10)
        get_as_employee(admin, "/admin-dashboard")

        expect(last_response.body).to include("<h2>Customer Stats</h2>")
        expect(last_response.body).to include("Active:")
        expect(last_response.body).to include(">1<")
        expect(last_response.body).to include("Flagged:")
        expect(last_response.body).to include(">2<")
        expect(last_response.body).to include("Suspended:")
        expect(last_response.body).to include(">3<")
        expect(last_response.body).to include("Deleted:")
        expect(last_response.body).to include(">4<")
      end
    end

    context "when there are less than 2 months of data for customers" do
      it "displays a default message for the monthly change in signups" do
        admin = add_test_admin_to_db
        add_test_customer_to_db
        get_as_employee(admin, "/admin-dashboard")
        expect(last_response.body).to include("Not enough data to display")
      end
    end

    context "when customer accounts have been registered across multiple months" do
      it "displays the monthly change in signups provided 2 months of data exist" do
        admin = add_test_admin_to_db
        add_test_customer_to_db(
          1, "Alex", "Nate", "addr1", "addr2", "Shef", "S1 1AA", "7710002000", "email@gmail.com", 0, Time.now.utc
        )
        add_test_customer_to_db(
          2, "Alex", "Nate", "addr1", "addr2", "Shef", "S1 1AA", "7710002001", "email@mail.com", 0, Time.now.utc
        )
        add_test_customer_to_db(
          3, "Alex", "Nate", "addr1", "addr2", "Shef", "S1 1AA", "7710002002", "email@email.com", 0, Time.now.utc
        )
        add_test_customer_to_db(
          4, "Alex", "Nate", "addr1", "addr2", "Shef", "S1 1AA", "7710002003", "gmail@gmail.com", 0, Time.now.utc - SECONDS_IN_MONTH
        )
        add_test_customer_to_db(
          5, "Alex", "Nate", "addr1", "addr2", "Shef", "S1 1AA", "7710002004", "mail@mail.com", 0, Time.now.utc - SECONDS_IN_MONTH * 2
        )
        add_test_customer_to_db(
          6, "Alex", "Nate", "addr1", "addr2", "Shef", "S1 1AA", "7710002005", "gmail@email.com", 0, Time.now.utc - SECONDS_IN_MONTH * 2
        )
        add_test_customer_to_db(
          7, "Alex", "Nate", "addr1", "addr2", "Shef", "S1 1AA", "7710002006", "mail@email.com", 0, Time.now.utc - SECONDS_IN_MONTH * 3
        )
        get_as_employee(admin, "/admin-dashboard")

        current_month = Time.now.utc.to_s[0, 7]
        previous_month = (Time.now.utc - SECONDS_IN_MONTH).to_s[0, 7]
        before_prev_month = (Time.now.utc - SECONDS_IN_MONTH * 2).to_s[0, 7]
        expect(last_response.body).to include("<h2>Monthly Change in Signups (Last 6 Months)</h2>")
        expect(last_response.body).to include("#{format_month(current_month)}:")
        expect(last_response.body).to include("3 signups")
        expect(last_response.body).to include("(+2)")
        expect(last_response.body).to include("#{format_month(previous_month)}:")
        expect(last_response.body).to include("1 signup")
        expect(last_response.body).to include("(-1)")
        expect(last_response.body).to include("#{format_month(before_prev_month)}:")
        expect(last_response.body).to include("2 signups")
        expect(last_response.body).to include("(+1)")
      end
    end

    context "when orders exist" do
      before do
        admin = add_test_admin_to_db
        add_test_order_to_db(1, Time.now.utc - SECONDS_IN_MONTH, 7.3, 7.7, 1, "ABC12345", "Online", 1, "Completed", "Paid")
        add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC123456", "Online", 1, "Completed", "Unpaid")
        add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC1234567", "Online", 1, "Completed", "Unpaid")
        add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC1234578", "Online", 1, "Completed", "Owed")
        add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC1234545", "Online", 1, "Completed", "Owed")
        add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC1234512", "Online", 1, "Completed", "Owed")
        get_as_employee(admin, "/admin-dashboard")
      end

      it "displays the correct order counts" do
        expect(last_response.body).to include("<h2>Order and Revenue Stats</h2>")
        expect(last_response.body).to include("Total orders:")
        expect(last_response.body).to include(">6<")
        expect(last_response.body).to include("Paid:")
        expect(last_response.body).to include(">1<")
        expect(last_response.body).to include("Unpaid:")
        expect(last_response.body).to include(">2<")
        expect(last_response.body).to include("Owed:")
        expect(last_response.body).to include(">3<")
      end

      it "displays the correct revenue and profit" do
        expect(last_response.body).to include("Total Revenue:")
        expect(last_response.body).to include(format_price(7.7))
        expect(last_response.body).to include("Total Profit:")
        expect(last_response.body).to include(format_price(0.4))
      end
    end

    context "when no orders exist" do
      before do
        admin = add_test_admin_to_db
        get_as_employee(admin, "/admin-dashboard")
      end

      it "displays a default message for the top 3 baristas" do
        expect(last_response.body).to include("No orders exist")
      end

      it "displays a default message for the monthly change in orders" do
        expect(last_response.body).to include("Not enough data to display")
      end
    end

    context "when there is only 1 month of data for orders" do
      it "displays a default message for the monthly change in orders" do
        admin = add_test_admin_to_db
        add_test_barista_to_db("barista")
        add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC12345", "barista")
        get_as_employee(admin, "/admin-dashboard")
        expect(last_response.body).to include("Not enough data to display")
      end
    end

    context "when orders have been placed across multiple months" do
      it "displays the monthly change in orders provided 2 months of data exist" do
        admin = add_test_admin_to_db
        add_test_order_to_db(1, Time.now.utc - SECONDS_IN_MONTH * 2, 7.3, 7.7, 1, "ABC12344", "Online", 1, "Completed", "Paid")
        add_test_order_to_db(1, Time.now.utc - SECONDS_IN_MONTH, 7.3, 7.7, 1, "ABC12345", "Online", 1, "Completed", "Paid")
        add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC123456", "Online", 1, "Completed", "Unpaid")
        add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC1234567", "Online", 1, "Completed", "Unpaid")
        add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC1234578", "Online", 1, "Completed", "Owed")
        add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC1234545", "Online", 1, "Completed", "Owed")
        add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC1234512", "Online", 1, "Completed", "Owed")
        get_as_employee(admin, "/admin-dashboard")

        expect(last_response.body).to include("<h2>Monthly Change in Orders (Last 6 Months)</h2>")
        current_month = Time.now.utc.to_s[0, 7]
        previous_month = (Time.now.utc - SECONDS_IN_MONTH).to_s[0, 7]
        expect(last_response.body).to include("#{format_month(current_month)}:")
        expect(last_response.body).to include("5 orders")
        expect(last_response.body).to include("(+4)")
        expect(last_response.body).to include("#{format_month(previous_month)}:")
        expect(last_response.body).to include("1 order")
        expect(last_response.body).to include("(+0)")
      end
    end

    context "when employees exist" do
      before do
        admin = add_test_admin_to_db
        add_test_barista_to_db("barista1", "Mr", "Barista", "mr@gmail.com")
        add_test_barista_to_db("barista2", "Mrs", "Barista", "mrs@gmail.com")
        add_test_barista_to_db("barista3", "Guy", "Barry", "guy@gmail.com")
        add_test_manager_to_db
        add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC12345", "barista1")
        add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC12344", "barista1")
        add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC12346", "barista2")
        get_as_employee(admin, "/admin-dashboard")
      end

      it "displays the correct employee counts" do
        expect(last_response.body).to include("<h2>Employee Stats</h2>")
        expect(last_response.body).to include("Baristas:")
        expect(last_response.body).to include(">3<")
        expect(last_response.body).to include("Managers:")
        expect(last_response.body).to include(">1<")
        expect(last_response.body).to include("Deleted:")
        expect(last_response.body).to include(">0<")
      end

      it "displays the top 3 baristas by their order count" do
        expect(last_response.body).to include("<h2>Top 3 Baristas</h2>")
        expect(last_response.body).to include("barista1 - ")
        expect(last_response.body).to include(">2<")
        expect(last_response.body).to include("barista2 - ")
      end
    end
  end

  describe "POST /admin-update-username" do
    context "when admin submits form with no input" do
      before do
        admin = add_test_admin_to_db("old_username")
        post_as_employee(admin, "/admin-update-username", { "username" => "" })
      end

      it "has a status code of 200 (OK)" do
        expect(last_response).to be_ok
      end

      it "tells the admin the username cannot be empty" do
        expect(last_response.body).to include("Username cannot be empty.")
      end

      it "displays the value of the username before submission" do
        expect(last_response.body).to include("Username:")
        expect(last_response.body).to include("old_username")
      end

      it "does not save the empty username in the database" do
        admin = Employee.first(username: 'old_username')
        expect(admin).not_to be_nil
      end
    end

    context "when admin submits a username with spaces" do
      before do
        admin = add_test_admin_to_db("old_username")
        post_as_employee(admin, "/admin-update-username", { "username" => "new username" })
      end

      it "tells the admin the username cannot contain spaces" do
        expect(last_response.body).to include("Username cannot contain spaces.")
      end

      it "displays the value of the username before submission" do
        expect(last_response.body).to include("Username:")
        expect(last_response.body).to include("old_username")
      end

      it "does not change the username in the database" do
        admin = Employee.first(username: 'old_username')
        expect(admin).not_to be_nil
      end
    end

    context "when admin submits the same username as their current one" do
      before do
        admin = add_test_admin_to_db("same_username")
        post_as_employee(admin, "/admin-update-username", { "username" => "same_username" })
      end

      it "has a status code of 200 (OK)" do
        expect(last_response).to be_ok
      end

      it "tells the admin the username cannot be the same" do
        expect(last_response.body).to include("Username must not be the same as the current one.")
      end

      it "displays the value of the username before submission" do
        expect(last_response.body).to include("Username:")
        expect(last_response.body).to include("same_username")
      end

      it "does not change the username in the database" do
        admin = Employee.first(username: 'same_username')
        expect(admin).not_to be_nil
      end
    end

    context "when admin submits a username already taken" do
      before do
        admin = add_test_admin_to_db("admin_username")
        add_test_barista_to_db("existing_username")
        post_as_employee(admin, "/admin-update-username", { "username" => "existing_username" })
      end

      it "has a status code of 200 (OK)" do
        expect(last_response).to be_ok
      end

      it "tells the admin the username already exists" do
        expect(last_response.body).to include("Username already exists.")
      end

      it "displays the value of the username before submission" do
        expect(last_response.body).to include("Username:")
        expect(last_response.body).to include("admin_username")
      end

      it "does not change the username in the database" do
        admin = Employee.first(username: 'admin_username')
        expect(admin).not_to be_nil
      end
    end

    context "when admin submits a valid username" do
      before do
        admin = add_test_admin_to_db("old_username")
        post_as_employee(admin, "/admin-update-username", { "username" => "valid_username"})
      end

      it "has a status code of 200 (OK)" do
        expect(last_response).to be_ok
      end

      it "displays a confirmation message" do
        expect(last_response.body).to include("Username updated successfully.")
      end

      it "displays the new value of the username" do
        expect(last_response.body).to include("Username:")
        expect(last_response.body).to include("valid_username")
      end

      it "saves the value of the username in the database" do
        admin = Employee.first(username: 'valid_username')
        expect(admin).not_to be_nil
      end

      it "removes the old username from the database" do
        expect(Employee.first(username: 'old_username')).to be_nil
      end
    end
  end

  describe "POST /admin-update-email" do
    context "when admin submits form with no input" do
      before do
        admin = add_test_admin_to_db("admin", "Name", "Surname", "old@gmail.com")
        post_as_employee(admin, "/admin-update-email", { "email" => "" })
      end

      it "has a status code of 200 (OK)" do
        expect(last_response).to be_ok
      end

      it "tells the admin the email cannot be empty" do
        expect(last_response.body).to include("Email cannot be empty.")
      end

      it "displays the value of the email before submission" do
        expect(last_response.body).to include("Email:")
        expect(last_response.body).to include("old@gmail.com")
      end

      it "does not save the empty email in the database" do
        admin = Employee.first(email: 'old@gmail.com')
        expect(admin).not_to be_nil
      end
    end

    context "when admin submits the same email as their current one" do
      before do
        admin = add_test_admin_to_db("admin", "Name", "Surname", "same@gmail.com")
        post_as_employee(admin, "/admin-update-email", { "email" => "same@gmail.com" })
      end

      it "has a status code of 200 (OK)" do
        expect(last_response).to be_ok
      end

      it "tells the admin the email cannot be the same" do
        expect(last_response.body).to include("Email must not be the same as the current one.")
      end

      it "displays the value of the email before submission" do
        expect(last_response.body).to include("Email:")
        expect(last_response.body).to include("same@gmail.com")
      end

      it "does not change the email in the database" do
        admin = Employee.first(email: 'same@gmail.com')
        expect(admin).not_to be_nil
      end
    end

    context "when admin submits an email already taken" do
      before do
        admin = add_test_admin_to_db("admin", "Mr", "Admin", "email@gmail.com")
        add_test_barista_to_db("barista", "Mr", "Barista", "email@yahoo.com")
        post_as_employee(admin, "/admin-update-email", { "email" => "email@yahoo.com" })
      end

      it "has a status code of 200 (OK)" do
        expect(last_response).to be_ok
      end

      it "tells the admin the email already exists" do
        expect(last_response.body).to include("Email already exists.")
      end

      it "displays the value of the email before submission" do
        expect(last_response.body).to include("Email:")
        expect(last_response.body).to include("email@gmail.com")
      end

      it "does not change the email in the database" do
        admin = Employee.first(email: 'email@gmail.com')
        expect(admin).not_to be_nil
      end
    end

    context "when admin submits an invalid email" do
      before do
        admin = add_test_admin_to_db("admin", "Name", "Surname", "email@gmail.com")
        post_as_employee(admin, "/admin-update-email", { "email" => "invalidgmail.com"})
      end

      it "has a status code of 200 (OK)" do
        expect(last_response).to be_ok
      end

      it "tells the admin the email is invalid" do
        expect(last_response.body).to include("Email is not valid.")
      end

      it "displays the value of the email before submission" do
        expect(last_response.body).to include("Email:")
        expect(last_response.body).to include("email@gmail.com")
      end

      it "does not change the email in the database" do
        admin = Employee.first(email: 'email@gmail.com')
        expect(admin).not_to be_nil
      end
    end

    context "when admin submits a valid email" do
      before do
        admin = add_test_admin_to_db("admin", "Name", "Surname", "old@gmail.com")
        post_as_employee(admin, "/admin-update-email", { "email" => "valid@gmail.com"})
      end

      it "has a status code of 200 (OK)" do
        expect(last_response).to be_ok
      end

      it "displays a confirmation message" do
        expect(last_response.body).to include("Email updated successfully.")
      end

      it "displays the new value of the email" do
        expect(last_response.body).to include("Email:")
        expect(last_response.body).to include("valid@gmail.com")
      end

      it "saves the value of the email in the database" do
        admin = Employee.first(email: 'valid@gmail.com')
        expect(admin).not_to be_nil
      end

      it "removes the old email from the database" do
        expect(Employee.first(email: 'old@gmail.com')).to be_nil
      end
    end
  end

  describe "POST /admin-update-first-name" do
    context "when admin submits form with no input" do
      before do
        admin = add_test_admin_to_db("admin", "Kons", "Ioan")
        post_as_employee(admin, "/admin-update-first-name", { "first" => "" })
      end

      it "has a status code of 200 (OK)" do
        expect(last_response).to be_ok
      end

      it "tells the admin the first name cannot be empty" do
        expect(last_response.body).to include("First name cannot be empty.")
      end

      it "displays the value of the first name before submission" do
        expect(last_response.body).to include("Name:")
        expect(last_response.body).to include("Kons Ioan")
      end

      it "does not save the empty first name in the database" do
        admin = Employee.first(first_name: 'Kons')
        expect(admin).not_to be_nil
      end
    end

    context "when admin submits the same first name as their current one" do
      before do
        admin = add_test_admin_to_db("admin", "Kons", "Ioan")
        post_as_employee(admin, "/admin-update-first-name", { "first" => "Kons" })
      end

      it "tells the admin the first name cannot be the same" do
        expect(last_response.body).to include("First name must not be the same as the current one.")
      end

      it "displays the value of the first name before submission" do
        expect(last_response.body).to include("Name:")
        expect(last_response.body).to include("Kons Ioan")
      end

      it "does not change the first name in the database" do
        admin = Employee.first(first_name: 'Kons')
        expect(admin).not_to be_nil
      end
    end

    context "when admin submits a first name that does not start with a capital letter" do
      before do
        admin = add_test_admin_to_db("admin", "Kons", "Ioan")
        post_as_employee(admin, "/admin-update-first-name", { "first" => "kons" })
      end

      it "tells the admin the first name must start with a capital letter" do
        expect(last_response.body).to include("First name must start with a capital letter.")
      end

      it "displays the value of the first name before submission" do
        expect(last_response.body).to include("Name:")
        expect(last_response.body).to include("Kons Ioan")
      end

      it "does not change the first name in the database" do
        admin = Employee.first(first_name: 'Kons')
        expect(admin).not_to be_nil
      end
    end

    context "when admin submits a first name with invalid characters" do
      before do
        admin = add_test_admin_to_db("admin", "Kons", "Ioan")
        post_as_employee(admin, "/admin-update-first-name", { "first" => "Kons123" })
      end

      it "tells the admin the first name contains invalid characters" do
        expect(last_response.body).to include("First name must contain only letters, hyphens, apostrophes and spaces.")
      end

      it "displays the value of the first name before submission" do
        expect(last_response.body).to include("Name:")
        expect(last_response.body).to include("Kons Ioan")
      end

      it "does not change the first name in the database" do
        admin = Employee.first(first_name: 'Kons')
        expect(admin).not_to be_nil
      end
    end

    context "when admin submits a valid first name" do
      before do
        admin = add_test_admin_to_db("admin", "Kons", "Ioan")
        post_as_employee(admin, "/admin-update-first-name", { "first" => "Konstantinos" })
      end

      it "displays a confirmation message" do
        expect(last_response.body).to include("First name updated successfully.")
      end

      it "displays the new value of the first name" do
        expect(last_response.body).to include("Name:")
        expect(last_response.body).to include("Konstantinos Ioan")
      end

      it "saves the value of the first name in the database" do
        admin = Employee.first(first_name: 'Konstantinos')
        expect(admin).not_to be_nil
      end

      it "removes the old first name from the database" do
        admin = Employee.first(username: 'admin')
        expect(admin.first_name).not_to eq("Kons")
      end
    end
  end

  describe "POST /admin-update-last-name" do
    context "when admin submits form with no input" do
      before do
        admin = add_test_admin_to_db("admin", "Kons", "Ioan")
        post_as_employee(admin, "/admin-update-last-name", { "last" => "" })
      end

      it "has a status code of 200 (OK)" do
        expect(last_response).to be_ok
      end

      it "tells the admin the last name cannot be empty" do
        expect(last_response.body).to include("Last name cannot be empty.")
      end

      it "displays the value of the surname before submission" do
        expect(last_response.body).to include("Name:")
        expect(last_response.body).to include("Kons Ioan")
      end

      it "does not save the empty last name in the database" do
        admin = Employee.first(last_name: 'Ioan')
        expect(admin).not_to be_nil
      end
    end

    context "when admin submits the same last name as their current one" do
      before do
        admin = add_test_admin_to_db("admin", "Kons", "Ioan")
        post_as_employee(admin, "/admin-update-last-name", { "last" => "Ioan" })
      end

      it "tells the admin the last name cannot be the same" do
        expect(last_response.body).to include("Last name must not be the same as the current one.")
      end

      it "displays the value of the last name before submission" do
        expect(last_response.body).to include("Name:")
        expect(last_response.body).to include("Kons Ioan")
      end

      it "does not change the last name in the database" do
        admin = Employee.first(last_name: 'Ioan')
        expect(admin).not_to be_nil
      end
    end

    context "when admin submits a last name that does not start with a capital letter" do
      before do
        admin = add_test_admin_to_db("admin", "Kons", "Ioan")
        post_as_employee(admin, "/admin-update-last-name", { "last" => "ioan" })
      end

      it "tells the admin the last name must start with a capital letter" do
        expect(last_response.body).to include("Last name must start with a capital letter.")
      end

      it "displays the value of the first name before submission" do
        expect(last_response.body).to include("Name:")
        expect(last_response.body).to include("Kons Ioan")
      end

      it "does not change the last name in the database" do
        admin = Employee.first(last_name: 'Ioan')
        expect(admin).not_to be_nil
      end
    end

    context "when admin submits a last name with invalid characters" do
      before do
        admin = add_test_admin_to_db("admin", "Kons", "Ioan")
        post_as_employee(admin, "/admin-update-last-name", { "last" => "Ioan7" })
      end

      it "tells the admin the last name contains invalid characters" do
        expect(last_response.body).to include("Last name must contain only letters, hyphens, apostrophes and spaces.")
      end

      it "displays the value of the last name before submission" do
        expect(last_response.body).to include("Name:")
        expect(last_response.body).to include("Kons Ioan")
      end

      it "does not change the last name in the database" do
        admin = Employee.first(last_name: 'Ioan')
        expect(admin).not_to be_nil
      end
    end

    context "when admin submits a valid last name" do
      before do
        admin = add_test_admin_to_db("admin", "Kons", "Ioan")
        post_as_employee(admin, "/admin-update-last-name", { "last" => "Ioannou" })
      end

      it "displays a confirmation message" do
        expect(last_response.body).to include("Last name updated successfully.")
      end

      it "displays the new value of the last name" do
        expect(last_response.body).to include("Name:")
        expect(last_response.body).to include("Kons Ioannou")
      end

      it "saves the value of the last name in the database" do
        admin = Employee.first(last_name: 'Ioannou')
        expect(admin).not_to be_nil
      end

      it "removes the previous last name from the database" do
        admin = Employee.first(username: 'admin')
        expect(admin.last_name).not_to eq("Ioan")
      end
    end
  end

  describe "POST /admin-change-password" do
    context "when admin submits form with no input" do
      before do
        @admin = add_test_admin_to_db
        post_as_employee(@admin, "/admin-change-password", { "password" => "", "conf_password" => "" })
      end

      it "has a status code of 200 (OK)" do
        expect(last_response).to be_ok
      end

      it "does not display any message" do
        possible_message_prefixes = [
          "Password has", "Password not", "Password is", "The passwords", "Password must"
        ]

        possible_message_prefixes.each do |message|
          expect(last_response.body).not_to include(message)
        end
      end

      it "does not save the empty password" do
        admin = Employee.first(username: @admin.username)
        expect(admin.authenticate("validPass7!")).to be true
      end
    end

    context "when admin submits an invalid password" do
      before do
        @admin = add_test_admin_to_db
        post_as_employee(@admin, "/admin-change-password", { "password" => "invalid", "conf_password" => "invalid" })
      end

      it "displays error messages" do
        expect(last_response.body).to include(
          "Password is not valid. Must be 8+ characters with at least 1 uppercase, 1 digit and 1 special character."
        )
        expect(last_response.body).to include("Password not updated. Requirements not met.")
      end

      it "does not save the invalid password" do
        admin = Employee.first(username: @admin.username)
        expect(admin.authenticate("validPass7!")).to be true
      end
    end

    context "when admin submits different passwords" do
      before do
        @admin = add_test_admin_to_db
        post_as_employee(@admin, "/admin-change-password", { "password" => "Admin17!", "conf_password" => "Admin18!" })
      end

      it "displays error messages" do
        expect(last_response.body).to include("The passwords do not match.")
        expect(last_response.body).to include("Password not updated. Requirements not met.")
      end 

      it "does not change the admin's password" do
        admin = Employee.first(username: @admin.username)
        expect(admin.authenticate("validPass7!")).to be true
      end
    end

    context "when admin submits the same password as their current one" do
      before do
        @admin = add_test_admin_to_db
        post_as_employee(@admin, "/admin-change-password", { "password" => "validPass7!", "conf_password" => "validPass7!" })
      end

      it "displays error messages" do
        expect(last_response.body).to include("Password must not be the same as the current one.")
        expect(last_response.body).to include("Password not updated. Requirements not met.")
      end
      
      it "does not change the admin's password" do
        admin = Employee.first(username: @admin.username)
        expect(admin.authenticate("validPass7!")).to be true
      end
    end

    context "when admin only fills the Update password field" do
      before do
        @admin = add_test_admin_to_db
        post_as_employee(@admin, "/admin-change-password", { "password" => "Admin17!", "conf_password" => "" })
      end

      it "displays error messages" do
        expect(last_response.body).to include("The passwords do not match.")
        expect(last_response.body).to include("Password not updated. Requirements not met.")
      end

      it "does not change the admin's password" do
        admin = Employee.first(username: @admin.username)
        expect(admin.authenticate("validPass7!")).to be true
      end
    end

    context "when admin only fills the Confirm new password field" do
      before do
        @admin = add_test_admin_to_db
        post_as_employee(@admin, "/admin-change-password", { "password" => "", "conf_password" => "Admin17!" })
      end

      it "does not display any message" do
        possible_message_prefixes = [
          "Password has", "Password not", "Password is", "The passwords", "Password must"
        ]

        possible_message_prefixes.each do |message|
          expect(last_response.body).not_to include(message)
        end
      end

      it "does not change the admin's password" do
        admin = Employee.first(username: @admin.username)
        expect(admin.authenticate("validPass7!")).to be true
      end
    end

    context "when admin submits a valid password" do
      before do
        @admin = add_test_admin_to_db
        post_as_employee(@admin, "/admin-change-password", { "password" => "Admin17!", "conf_password" => "Admin17!" })
      end

      it "displays a confirmation message" do
        expect(last_response.body).to include("Password has been updated successfully.")
      end 

      it "saves the password in the database" do
        admin = Employee.first(username: @admin.username)
        expect(admin.authenticate("Admin17!")).to be true
        expect(admin.authenticate("validPass7!")).to be false
      end
    end
  end
end
