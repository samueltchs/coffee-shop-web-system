RSpec.describe "admin customers controller" do
  include LocalHelpers
  include Conversions

  describe "GET /admin-customer" do
    context "when viewing an active customer" do
      before do
        admin = add_test_admin_to_db
        @customer = add_test_customer_to_db
        get_as_employee(admin, "/admin-customer?loyalty_number=#{@customer.loyalty_number}")
      end

      it "has a status code of 200 (OK)" do
        expect(last_response).to be_ok
      end

      it "displays the correct title" do
        expect(last_response.body).to include("<title>#{@customer.name} - Customer Admin View</title>")
      end

      it "displays the correct headline" do
        expect(last_response.body).to include("<h1>Full Name: #{@customer.name}</h1>")
      end

      it "displays the customer's loyalty number" do
        expect(last_response.body).to include("Unique Loyalty Card Number:")
        expect(last_response.body).to include(@customer.loyalty_number.to_s)
      end

      it "displays the customer's email" do
        expect(last_response.body).to include("Email:")
        expect(last_response.body).to include(@customer.email)
      end

      it "displays the customer's phone number" do
        expect(last_response.body).to include("Phone Number:")
        expect(last_response.body).to include(@customer.phone_number)
      end

      it "displays the customer's number of stamps" do
        expect(last_response.body).to include("Stamps:")
        expect(last_response.body).to include(@customer.stamps.to_s)
      end

      it "displays the customer's time registered" do
        expect(last_response.body).to include("Registered At:")
        expect(last_response.body).to include(format_time(@customer.registered_time))
      end

      it "displays the customer's status" do
        expect(last_response.body).to include("Status:")
        expect(last_response.body).to include(@customer.status)
      end

      it "contains link to reset password email" do
        expect(last_response.body).to include("/admin-reset-pass-email?loyalty_number=#{@customer.loyalty_number}")
      end

      it "contains the customer suspend form" do
        expect(last_response.body).to include('action="/admin-customer-suspend"')
      end

      it "contains the suspend account button" do
        expect(last_response.body).to include("Suspend Account")
      end

      it "does not contain the customer delete form" do
        expect(last_response.body).not_to include('action="/admin-customer-delete"')
      end

      it "does not contain the customer reactivate form" do
        expect(last_response.body).not_to include('action="/admin-customer-reactivate"')
      end

      it "contains link to activity logs page" do
        expect(last_response.body).to include("/admin-customer-activity-logs")
        expect(last_response.body).to include("View Activity Logs")
      end
    end

    context "given a customer has at least 3 items bought" do
      before do
        @admin = add_test_admin_to_db
        add_test_size_to_db
        add_test_milk_option_to_db
        add_test_country_to_db
        add_test_roast_level_to_db
        add_test_product_to_db("Coffee", "Latte")
        add_test_product_to_db("Coffee", "Cappuccino")
        add_test_product_to_db("Coffee", "Mocha")
        add_test_product_variant_to_db(1, 1, 1)
        add_test_product_variant_to_db(2, 1, 1)
        add_test_product_variant_to_db(3, 1, 1)
        add_test_order_to_db(1)
        add_test_item_in_order_to_db(1, 1, 3.7, 1, 1, 1)
        add_test_item_in_order_to_db(2, 1, 3.7, 1, 1, 1)
        add_test_item_in_order_to_db(3, 1, 3.7, 1, 1, 1)
      end

      context "when the customer is active" do
        before do
          add_test_customer_to_db(1)
          get_as_employee(@admin, "/admin-customer?loyalty_number=1")
        end

        it "contains the send ad form" do
          expect(last_response.body).to include('action="/admin-send-ad"')
        end

        it "contains the send ad button" do
          expect(last_response.body).to include("Send ad")
        end
      end

      context "when the customer is flagged" do
        before do
          add_flagged_customer_to_db(1)
          get_as_employee(@admin, "/admin-customer?loyalty_number=1")
        end

        it "contains the send ad form" do
          expect(last_response.body).to include('action="/admin-send-ad"')
        end

        it "contains the send ad button" do
          expect(last_response.body).to include("Send ad")
        end
      end
    end

    context "given a customer has less than 3 items bought" do
      before do
        @admin = add_test_admin_to_db
      end

      context "when the customer is active" do
        before do
          add_test_customer_to_db(1)
          get_as_employee(@admin, "/admin-customer?loyalty_number=1")
        end

        it "does not contain the send ad form" do
          expect(last_response.body).not_to include('action="/admin-send-ad"')
        end

        it "displays a default message" do
          expect(last_response.body).to include("Not enough data to generate ad")
        end
      end

      context "when the customer is flagged" do
        before do
          add_flagged_customer_to_db(1)
          get_as_employee(@admin, "/admin-customer?loyalty_number=1")
        end

        it "does not contain the send ad form" do
          expect(last_response.body).not_to include('action="/admin-send-ad"')
        end

        it "displays a default message" do
          expect(last_response.body).to include("Not enough data to generate ad")
        end
      end
    end

    context "when viewing a 5 months inactive customer" do
      before do
        admin = add_test_admin_to_db
        add_test_customer_to_db(
          1, "Mikel", "Merino", "addr1", "addr2", "Shef", "S1 1AA", "7710002000", "mail@mail.com", 0, Time.now.utc - SECONDS_IN_MONTH * 5
        )
        get_as_employee(admin, "/admin-customer?loyalty_number=1")
      end

      it "contains link to the inactivity warning email" do
        expect(last_response.body).to include("/admin-inactivity-warning-email?loyalty_number=1")
      end

      it "contains link to activity logs page" do
        expect(last_response.body).to include("/admin-customer-activity-logs")
        expect(last_response.body).to include("View Activity Logs")
      end
    end

    context "when viewing a flagged customer" do
      before do
        admin = add_test_admin_to_db
        @customer = add_flagged_customer_to_db(1)
        get_as_employee(admin, "/admin-customer?loyalty_number=1")
      end

      it "displays the flagged at time" do
        expect(last_response.body).to include("Flagged at:")
        expect(last_response.body).to include(format_time(@customer.flagged_at))
      end

      it "contains link to reset password email" do
        expect(last_response.body).to include("/admin-reset-pass-email?loyalty_number=1")
      end

      it "contains the customer suspend form" do
        expect(last_response.body).to include('action="/admin-customer-suspend"')
      end

      it "contains link to activity logs page" do
        expect(last_response.body).to include("/admin-customer-activity-logs")
        expect(last_response.body).to include("View Activity Logs")
      end

      it "does not contain the customer delete form" do
        expect(last_response.body).not_to include('action="/admin-customer-delete"')
      end

      it "does not contain the customer reactivate form" do
        expect(last_response.body).not_to include('action="/admin-customer-reactivate"')
      end
    end

    context "when viewing a flagged customer 1 day before suspension" do
      before do
        admin = add_test_admin_to_db
        add_flagged_customer_to_db(1, Time.now.utc - SECONDS_IN_DAY * 4)
        get_as_employee(admin, "/admin-customer?loyalty_number=1")
      end

      it "contains link to suspension warning email" do
        expect(last_response.body).to include("/admin-suspension-warning-email?loyalty_number=1")
      end

      it "contains link to activity logs page" do
        expect(last_response.body).to include("/admin-customer-activity-logs")
        expect(last_response.body).to include("View Activity Logs")
      end
    end

    context "when viewing a suspended due to inactivity for less than 3 months customer" do
      before do
        admin = add_test_admin_to_db
        @customer = add_suspended_customer_to_db(1, Time.now.utc - SECONDS_IN_DAY * 5, Time.now.utc, 1)
        get_as_employee(admin, "/admin-customer?loyalty_number=1")
      end

      it "contains link to inactivity suspension email" do
        expect(last_response.body).to include("/admin-inactivity-suspension-email?loyalty_number=1")
      end

      it "displays the customer's suspension time" do
        expect(last_response.body).to include("Suspended at:")
        expect(last_response.body).to include(format_time(@customer.suspended_at))
      end

      it "displays the flagged at time" do
        expect(last_response.body).to include("Flagged at:")
        expect(last_response.body).to include(format_time(@customer.flagged_at))
      end

      it "does not contain link to reset password email" do
        expect(last_response.body).not_to include("/admin-reset-pass-email?loyalty_number=1")
      end

      it "does not contain the customer suspend form" do
        expect(last_response.body).not_to include('action="/admin-customer-suspend"')
      end

      it "does not contain the customer delete form" do
        expect(last_response.body).not_to include('action="/admin-customer-delete"')
      end

      it "contains the customer reactivate form" do
        expect(last_response.body).to include('action="/admin-customer-reactivate"')
      end

      it "contains the reactivate account button" do
        expect(last_response.body).to include("Reactivate Account")
      end

      it "contains link to activity logs page" do
        expect(last_response.body).to include("/admin-customer-activity-logs")
        expect(last_response.body).to include("View Activity Logs")
      end
    end

    context "when viewing a suspended due to disciplinary reasons customer" do
      before do
        admin = add_test_admin_to_db
        add_suspended_customer_to_db(1, nil, Time.now.utc, 2)
        get_as_employee(admin, "/admin-customer?loyalty_number=1")
      end

      it "contains link to disciplinary suspension email" do
        expect(last_response.body).to include("/admin-disciplinary-suspension-email?loyalty_number=1")
      end

      it "does not contain any flagged at time" do
        expect(last_response.body).not_to include("Flagged at:")
      end

      it "contains the customer delete form" do
        expect(last_response.body).to include('action="/admin-customer-delete"')
      end

      it "contains the delete account button" do
        expect(last_response.body).to include("Delete Account")
      end

      it "contains the reactivate account form" do
        expect(last_response.body).to include('action="/admin-customer-reactivate"')
      end

      it "contains link to activity logs page" do
        expect(last_response.body).to include("/admin-customer-activity-logs")
        expect(last_response.body).to include("View Activity Logs")
      end
    end

    context "when viewing a suspended due to inactivity customer past 3 months" do
      before do
        admin = add_test_admin_to_db
        add_suspended_customer_to_db(1, Time.now.utc - SECONDS_IN_DAY * 95, Time.now.utc - SECONDS_IN_MONTH * 3, 1)
        get_as_employee(admin, "/admin-customer?loyalty_number=1")
      end

      it "contains the customer delete form" do
        expect(last_response.body).to include('action="/admin-customer-delete"')
      end

      it "does not contain customer reactivate form" do
        expect(last_response.body).not_to include('action="/admin-customer-reactivate"')
      end

      it "contains link to activity logs page" do
        expect(last_response.body).to include("/admin-customer-activity-logs")
        expect(last_response.body).to include("View Activity Logs")
      end
    end

    context "when viewing a deleted due to inactivity customer" do
      before do
        admin = add_test_admin_to_db
        @customer = add_deleted_customer_to_db(1, 1)
        get_as_employee(admin, "/admin-customer?loyalty_number=1")
      end

      it "displays the correct headline" do
        expect(last_response.body).to include("<h1>Deleted Customer</h1>")
      end

      it "displays the customer's deleted time" do
        expect(last_response.body).to include("Deleted at:")
        expect(last_response.body).to include(format_time(@customer.deleted_at))
      end

      it "does not display how long customer has been inactive for" do
        expect(last_response.body).not_to include("Inactive for:")
      end

      it "does not display the customer's time registered" do
        expect(last_response.body).not_to include("Registered At:")
      end

      it "does not display the customer's suspension time" do
        expect(last_response.body).not_to include("Suspended at:")
      end

      it "does not contain link to reset password email" do
        expect(last_response.body).not_to include("/admin-reset-pass-email?loyalty_number=1")
      end

      it "does not contain customer suspend form" do
        expect(last_response.body).not_to include('action="/admin-customer-suspend"')
      end

      it "does not contain customer delete form" do
        expect(last_response.body).not_to include('action="/admin-customer-delete"')
      end

      it "does not contain customer reactivate form" do
        expect(last_response.body).not_to include('action="/admin-customer-reactivate"')
      end

      it "contains link to inactivity deletion email" do
        expect(last_response.body).to include("/admin-inactivity-deletion-email?loyalty_number=1")
      end

      it "contains link to activity logs page" do
        expect(last_response.body).to include("/admin-customer-activity-logs")
        expect(last_response.body).to include("View Activity Logs")
      end
    end

    context "when viewing a deleted due to disciplinary reasons customer" do
      before do
        admin = add_test_admin_to_db
        add_deleted_customer_to_db(1, 2)
        get_as_employee(admin, "/admin-customer?loyalty_number=1")
      end
      
      it "contains link to disciplinary deletion email" do
        expect(last_response.body).to include("/admin-disciplinary-deletion-email?loyalty_number=1")
      end

      it "contains link to activity logs page" do
        expect(last_response.body).to include("/admin-customer-activity-logs")
        expect(last_response.body).to include("View Activity Logs")
      end
    end

    context "when viewing a non deleted customer with no times recorded" do
      it "displays a default message" do
        admin = add_test_admin_to_db
        add_test_customer_to_db(1)
        get_as_employee(admin, "/admin-customer?loyalty_number=1")
        expect(last_response.body).to include("No activity has been recorded")
      end
    end

    context "when viewing a non deleted customer with times recorded" do
      it "displays how long customer has been inactive for" do
        admin = add_test_admin_to_db
        add_test_customer_to_db(1, "Mikel", "Merino", "addr1", "addr2", "Shef", "S1 1AA", "7710002000", "mail@mail.com", 0, Time.now.utc - SECONDS_IN_MONTH * 2)
        add_test_login_time_to_db(1, Time.now.utc - SECONDS_IN_MONTH * 2)
        add_test_login_time_to_db(1, Time.now.utc - SECONDS_IN_MONTH)
        get_as_employee(admin, "/admin-customer?loyalty_number=1")
        expect(last_response.body).to include("1 month")
      end
    end
  end

  describe "POST /admin-customer-suspend" do
    context "when suspending a flagged account" do
      before do
        admin = add_test_admin_to_db
        add_flagged_customer_to_db(1)
        post_as_employee(admin, "/admin-customer-suspend", { "loyalty_number" => "1" })
      end

      it "has a status code of 200 (OK)" do
        expect(last_response).to be_ok
      end

      it "displays a confirmation message" do
        expect(last_response.body).to include("The user has been suspended.")
      end

      it "suspends the customer due to inactivity" do
        customer = Customer.first(loyalty_number: 1)
        expect(customer.status).to eq("Suspended")
        expect(customer.suspension_reason_id).to eq(1)
        expect(customer.suspended_at).not_to be_nil
      end

      it "contains link to inactivity suspension email" do
        expect(last_response.body).to include("/admin-inactivity-suspension-email?loyalty_number=1")
        expect(last_response.body).to include("View the account suspension email")
      end
    end

    context "when suspending an active account" do
      before do
        admin = add_test_admin_to_db
        add_test_customer_to_db(1)
        post_as_employee(admin, "/admin-customer-suspend", { "loyalty_number" => "1" })
      end

      it "has a status code of 200 (OK)" do
        expect(last_response).to be_ok
      end

      it "displays a confirmation message" do
        expect(last_response.body).to include("The user has been suspended.")
      end

      it "suspends the customer due to disciplinary reasons" do
        customer = Customer.first(loyalty_number: 1)
        expect(customer.status).to eq("Suspended")
        expect(customer.suspension_reason_id).to eq(2)
        expect(customer.suspended_at).not_to be_nil
      end

      it "contains link to disciplinary suspension email" do
        expect(last_response.body).to include("/admin-disciplinary-suspension-email?loyalty_number=1")
        expect(last_response.body).to include("View the account suspension email")
      end
    end

    context "when suspending an already suspended account" do
      it "does not update their suspension time" do
        admin = add_test_admin_to_db
        customer = add_suspended_customer_to_db(1)
        original_time = customer.suspended_at
        post_as_employee(admin, "/admin-customer-suspend", { "loyalty_number" => "1" })
        expect(Customer.first(loyalty_number: 1).suspended_at).to eq(original_time)
      end
    end

    context "when suspending a deleted account" do
      it "does not change the status of the account" do
        admin = add_test_admin_to_db
        add_deleted_customer_to_db(1)
        post_as_employee(admin, "/admin-customer-suspend", { "loyalty_number" => "1" })
        expect(Customer.first(loyalty_number: 1).status).to eq("Deleted")
      end
    end
  end

  describe "POST /admin-customer-delete" do
    context "when deleting a suspended due to inactivity customer past 3 months" do
      before do
        admin = add_test_admin_to_db
        add_suspended_customer_to_db(1, Time.now.utc - SECONDS_IN_DAY * 95, Time.now.utc - SECONDS_IN_MONTH * 3, 1)
        post_as_employee(admin, "/admin-customer-delete", { "loyalty_number" => "1" })
      end

      it "has a status code of 200 (OK)" do
        expect(last_response).to be_ok
      end

      it "displays a confirmation message" do
        expect(last_response.body).to include("The customer has been deleted.")
      end

      it "deletes the customer" do
        expect(Customer.where(status: 'Deleted').count).to eq(1)
      end

      it "contains link to inactivity deletion email" do
        expect(last_response.body).to include("/admin-inactivity-deletion-email?loyalty_number=")
      end
    end

    context "when deleting a suspended due to inactivity for less than 3 months customer" do
      it "does not change the status of the account" do
        admin = add_test_admin_to_db
        add_suspended_customer_to_db(1, Time.now.utc - SECONDS_IN_DAY * 5, Time.now.utc, 1)
        post_as_employee(admin, "/admin-customer-delete", { "loyalty_number" => "1" })
        expect(Customer.first(loyalty_number: 1).status).to eq("Suspended")
      end
    end

    context "when deleting a suspended due to disciplinary reasons customer" do
      before do
        admin = add_test_admin_to_db
        add_suspended_customer_to_db(1, nil, Time.now.utc - SECONDS_IN_MONTH * 3, 2)
        post_as_employee(admin, "/admin-customer-delete", { "loyalty_number" => "1" })
      end

      it "has a status code of 200 (OK)" do
        expect(last_response).to be_ok
      end

      it "displays a confirmation message" do
        expect(last_response.body).to include("The customer has been deleted.")
      end

      it "deletes the customer" do
        expect(Customer.where(status: 'Deleted').count).to eq(1)
      end

      it "contains link to disciplinary deletion email" do
        expect(last_response.body).to include("/admin-disciplinary-deletion-email?loyalty_number=")
      end
    end

    context "when deleting a non suspended customer" do
      it "does not change the status of the account" do
        admin = add_test_admin_to_db
        add_test_customer_to_db(1)
        post_as_employee(admin, "/admin-customer-delete", { "loyalty_number" => "1" })    
        expect(Customer.first(loyalty_number: 1).status).to eq("Active")   
      end
    end
  end

  describe "POST /admin-customer-reactivate" do
    context "when reactivating a suspended due to inactivity for less than 3 months customer" do
      before do
        admin = add_test_admin_to_db
        add_suspended_customer_to_db(1, Time.now.utc - SECONDS_IN_DAY * 5, Time.now.utc, 1)
        post_as_employee(admin, "/admin-customer-reactivate", { "loyalty_number" => "1" })        
      end

      it "has a status code of 200 (OK)" do
        expect(last_response).to be_ok
      end

      it "displays a confirmation message" do
        expect(last_response.body).to include("The user")
        expect(last_response.body).to include("account has successfully been reactivated as per their request.")
      end

      it "reactivates the customer" do
        customer = Customer.first(loyalty_number: 1)
        expect(customer.status).to eq("Active")
        expect(customer.flagged_at).to be_nil
        expect(customer.suspended_at).to be_nil
        expect(customer.suspension_reason_id).to be_nil
      end

      it "records a new login time" do
        expect(LoginTime.where(loyalty_number: 1).count).to eq(1)
      end

      it "contains link to the account reactivated email" do
        expect(last_response.body).to include("/admin-account-reactivated-email?loyalty_number=1")
      end
    end

    context "when reactivating a suspended due to inactivity customer past 3 months" do
      before do
        admin = add_test_admin_to_db
        add_suspended_customer_to_db(1, Time.now.utc - SECONDS_IN_DAY * 95, Time.now.utc - SECONDS_IN_MONTH * 3, 1)
        post_as_employee(admin, "/admin-customer-reactivate", { "loyalty_number" => "1" })
      end
      
      it "redirects to the customer page" do
        expect(last_response).to be_redirect
        expect(last_response.location).to end_with("/admin-customer?loyalty_number=1")
      end

      it "does not change the status of the account" do
        expect(Customer.first(loyalty_number: 1).status).to eq("Suspended")
      end

      it "does not record a new login time" do
        expect(LoginTime.where(loyalty_number: 1).count).to eq(0)
      end
    end

    context "when reactivating a suspended due to disciplinary reasons customer" do
      before do
        admin = add_test_admin_to_db
        add_suspended_customer_to_db(1, nil, Time.now.utc - SECONDS_IN_MONTH * 3, 2)
        post_as_employee(admin, "/admin-customer-reactivate", { "loyalty_number" => "1" })
      end

      it "has a status code of 200 (OK)" do
        expect(last_response).to be_ok
      end

      it "displays a confirmation message" do
        expect(last_response.body).to include("The user")
        expect(last_response.body).to include("account has successfully been reactivated as per their request.")
      end

      it "reactivates the customer" do
        customer = Customer.first(loyalty_number: 1)
        expect(customer.status).to eq("Active")
        expect(customer.flagged_at).to be_nil
        expect(customer.suspended_at).to be_nil
        expect(customer.suspension_reason_id).to be_nil
      end

      it "records a new login time" do
        expect(LoginTime.where(loyalty_number: 1).count).to eq(1)
      end

      it "contains link to the account reactivated email" do
        expect(last_response.body).to include("/admin-account-reactivated-email?loyalty_number=1")
      end
    end

    context "when reactivating a non suspended customer" do
      before do
        admin = add_test_admin_to_db
        add_flagged_customer_to_db(1)
        post_as_employee(admin, "/admin-customer-reactivate", { "loyalty_number" => "1" })
      end

      it "redirects to the customer page" do
        expect(last_response).to be_redirect
        expect(last_response.location).to end_with("/admin-customer?loyalty_number=1")
      end

      it "does not change the status of the account" do
        expect(Customer.first(loyalty_number: 1).status).to eq("Flagged")
      end

      it "does not record a new login time" do
        expect(LoginTime.where(loyalty_number: 1).count).to eq(0)
      end
    end
  end

  describe "POST /admin-send-ad" do
    context "when customer has bought at least 3 items" do
      before do
        admin = add_test_admin_to_db
        @customer = add_test_customer_to_db(1)
        add_test_size_to_db
        add_test_milk_option_to_db
        add_test_country_to_db
        add_test_roast_level_to_db
        add_test_product_to_db("Coffee", "Latte", 1, 1, 1, 1, "classic")
        add_test_product_to_db("Coffee", "Cappuccino", 1, 1, 1, 1, "refreshment")
        add_test_product_to_db("Coffee", "Mocha", 1, 1, 1, 1, "sweet")
        add_test_product_variant_to_db(1, 1, 1, 3.7)
        add_test_product_variant_to_db(2, 1, 1, 4.7)
        add_test_product_variant_to_db(3, 1, 1, 5.7)
        add_test_order_to_db(1)
        add_test_item_in_order_to_db(1, 1, 3.7, 1, 1, 1)
        add_test_item_in_order_to_db(2, 1, 4.7, 1, 1, 1)
        add_test_item_in_order_to_db(3, 1, 5.7, 1, 1, 1)
        post_as_employee(admin, "/admin-send-ad", { "loyalty_number" => "1" })
      end

      it "has a status code of 200 (OK)" do
        expect(last_response).to be_ok
      end

      it "displays the correct title" do
        expect(last_response.body).to include("<title>#{@customer.name} - Ad Preview</title>")
      end

      it "contains link back to the customer's page" do
        expect(last_response.body).to include("/admin-customer?loyalty_number=1")
      end

      it "displays the 3 item names along with their description and price" do
        expect(last_response.body).to include("Latte")
        expect(last_response.body).to include("classic")
        expect(last_response.body).to include(format_price(3.7))
        expect(last_response.body).to include("Cappuccino")
        expect(last_response.body).to include("refreshment")
        expect(last_response.body).to include(format_price(4.7))
        expect(last_response.body).to include("Mocha")
        expect(last_response.body).to include("sweet")
        expect(last_response.body).to include(format_price(5.7))
      end

      it "creates a promotion" do
        expect(Promotion.where(loyalty_number: 1).count).to eq(1)
      end
    end

    context "when customer has bought less than 3 items" do
      before do
        admin = add_test_admin_to_db
        add_test_customer_to_db(1)
        post_as_employee(admin, "/admin-send-ad", { "loyalty_number" => "1" })
      end

      it "redirects to customer page" do
        expect(last_response).to be_redirect
        expect(last_response.location).to end_with("/admin-customer?loyalty_number=1")
      end

      it "does not create a promotion" do
        expect(Promotion.where(loyalty_number: 1).count).to eq(0)
      end
    end
  end

  describe "GET /admin-customer-activity-logs" do
    context "when viewing a customer's activity logs" do
      before do
        admin = add_test_admin_to_db
        @customer = add_test_customer_to_db(1)
        get_as_employee(admin, "/admin-customer-activity-logs?loyalty_number=1")
      end

      it "has a status code of 200 (OK)" do
        expect(last_response).to be_ok
      end

      it "displays the correct title" do
        expect(last_response.body).to include("<title>#{@customer.name} - Customer Activity Logs</title>")
      end

      it "displays the correct headline" do
        expect(last_response.body).to include("<h1>#{@customer.name} - Customer Activity Logs</h1>")
      end

      it "contains a link back to the customer's profile" do
        expect(last_response.body).to include("Back to the customer's profile")
        expect(last_response.body).to include("/admin-customer?loyalty_number=1")
      end

      it "contains a link to the purchase history page" do
        expect(last_response.body).to include("View customer purchase history")
        expect(last_response.body).to include("/admin-customer-purchase-history?loyalty_number=1")
      end

      it "contains a link to the purchasing habits page" do
        expect(last_response.body).to include("View customer purchasing habits")
        expect(last_response.body).to include("/admin-customer-purchasing-habits?loyalty_number=1")
      end

      it "displays the correct subheadings" do
        expect(last_response.body).to include("<h2>Time Spent Per Week</h2>")
        expect(last_response.body).to include("<h2>Recent Login Times</h2>")
        expect(last_response.body).to include("<h2>Recent Profile Updates</h2>")
        expect(last_response.body).to include("<h2>Recently Viewed Items</h2>")
        expect(last_response.body).to include("<h2>Favourited Items</h2>")
      end

      it "displays default messages when there is no activity" do
        expect(last_response.body).to include("No recorded activity")
        expect(last_response.body).to include("No login activity")
        expect(last_response.body).to include("No profile updates have been made")
        expect(last_response.body).to include("No items viewed")
        expect(last_response.body).to include("No items have been favourited")
      end
    end

    context "when a customer has recorded activity" do
      before do
        admin = add_test_admin_to_db
        add_test_customer_to_db(1)
        @login = add_test_login_time_to_db(1)
        @profile_update = add_test_profile_update_to_db(1, "city", "Manchester", "Sheffield")
        @recent_view = add_test_recent_view_to_db(1, 1, Time.now.utc, "Latte")
        @favourite = add_test_favourite_to_db(1, 1, "Cappuccino")
        get_as_employee(admin, "/admin-customer-activity-logs?loyalty_number=1")
      end

      it "displays the time spent per week" do
        expect(last_response.body).to include("Week")
        expect(last_response.body).to include("Time Spent")
        expect(last_response.body).not_to include("No recorded activity")
      end

      it "displays the login times" do
        expect(last_response.body).to include("Login Time")
        expect(last_response.body).to include(format_time(@login.login_time))
      end

      it "displays the profile updates" do
        expect(last_response.body).to include("Field")
        expect(last_response.body).to include("City")
        expect(last_response.body).to include("Old Value")
        expect(last_response.body).to include("Manchester")
        expect(last_response.body).to include("Sheffield")
        expect(last_response.body).to include("New Value")
        expect(last_response.body).to include("Time Updated")
        expect(last_response.body).to include(format_time(@profile_update.time_updated))
      end

      it "displays recently viewed items" do
        expect(last_response.body).to include("Item")
        expect(last_response.body).to include("Latte")
        expect(last_response.body).to include("Item ID")
        expect(last_response.body).to include(@recent_view.item_id.to_s)
        expect(last_response.body).to include("Time Viewed")
        expect(last_response.body).to include(format_time(@recent_view.time_viewed))
      end

      it "displays favourited items" do
        expect(last_response.body).to include("Item")
        expect(last_response.body).to include("Cappuccino")
        expect(last_response.body).to include("Item ID")
        expect(last_response.body).to include(@favourite.item_id.to_s)
      end
    end
  end

  describe "GET /admin-customer-purchase-history" do
    context "when viewing a customer's purchase history" do
      before do
        admin = add_test_admin_to_db
        @customer = add_test_customer_to_db
        get_as_employee(admin, "/admin-customer-purchase-history?loyalty_number=1")
      end

      it "has a status code of 200 (OK)" do
        expect(last_response).to be_ok
      end

      it "displays the correct title" do
        expect(last_response.body).to include("<title>#{@customer.name} - Customer Purchase History</title>")
      end

      it "displays the correct headline" do
        expect(last_response.body).to include("<h1>#{@customer.name} - Customer Purchase History</h1>")
      end

      it "contains a link back to the activity logs page" do
        expect(last_response.body).to include("Back to the activity logs")
        expect(last_response.body).to include("/admin-customer-activity-logs?loyalty_number=1")
      end

      it "displays a default message if customer has no orders" do
        expect(last_response.body).to include("This customer has not made any orders yet.")
      end
    end

    context "when a customer has orders" do
      it "displays the orders' details" do
        admin = add_test_admin_to_db
        add_test_customer_to_db(1)
        order = add_test_order_to_db(1)
        get_as_employee(admin, "/admin-customer-purchase-history?loyalty_number=1")

        expect(last_response.body).to include("ID")
        expect(last_response.body).to include(order.order_unique_id.to_s)
        expect(last_response.body).to include("Date Placed")
        expect(last_response.body).to include(format_date(order.date_placed))
        expect(last_response.body).to include("Price")
        expect(last_response.body).to include(format_price(order.price))
        expect(last_response.body).to include("Reference ID")
        expect(last_response.body).to include(order.reference_id)
      end
    end
  end

  describe "GET /admin-customer-purchasing-habits" do
    context "when viewing a customer's purchasing habits" do
      before do
        admin = add_test_admin_to_db
        @customer = add_test_customer_to_db
        get_as_employee(admin, "/admin-customer-purchasing-habits?loyalty_number=1")
      end

      it "has a status code of 200 (OK)" do
        expect(last_response).to be_ok
      end

      it "displays the correct title" do
        expect(last_response.body).to include("<title>#{@customer.name} - Customer Purchasing Habits</title>")
      end

      it "displays the correct headline" do
        expect(last_response.body).to include("<h1>#{@customer.name} - Customer Purchasing Habits</h1>")
      end

      it "contains a link back to the activity logs page" do
        expect(last_response.body).to include("Back to the activity logs")
        expect(last_response.body).to include("/admin-customer-activity-logs?loyalty_number=1")
      end

      it "displays the correct subheadings" do
        expect(last_response.body).to include("<h2>Average Expenditure:")
        expect(last_response.body).to include("<h2>Most frequently bought items</h2>")
      end

      it "displays the average expenditure" do
        expect(last_response.body).to include(format_price(0))
      end

      it "displays a default message when customer has not bought any items" do
        expect(last_response.body).to include("This customer has not purchased any items yet.")
      end
    end

    context "when a customer has bought items before" do
      before do
        admin = add_test_admin_to_db
        add_test_customer_to_db(1)
        add_test_size_to_db("large")
        add_test_milk_option_to_db("Whole")
        add_test_milk_option_to_db("")
        add_test_country_to_db("Ethiopian")
        add_test_roast_level_to_db("Light")
        add_test_product_to_db("Coffee", "Latte", 10, 1, 1, 1)
        add_test_product_to_db("Beans", "African beans", 10, 1, 1, 1)
        add_test_product_variant_to_db(1, 1, 1, 3.7)
        add_test_product_variant_to_db(2, 1, 2, 5.0)
        add_test_order_to_db(1, Time.now.utc, 7.3, 12.4)
        add_test_item_in_order_to_db(1, 1, 3.7, 2, 1, 1)
        add_test_item_in_order_to_db(2, 1, 5.0, 1, 1, 2)
        get_as_employee(admin, "/admin-customer-purchasing-habits?loyalty_number=1")
      end

      it "displays the correct table column headers" do
        expect(last_response.body).to include("Item")
        expect(last_response.body).to include("Item ID")
        expect(last_response.body).to include("Times Purchased")
      end

      it "displays the customer's top items" do
        expect(last_response.body).to include("Latte")
        expect(last_response.body).to include("(L) - Whole")
        expect(last_response.body).to include("2")
        expect(last_response.body).to include("African beans")
        expect(last_response.body).to include("1")
      end

      it "displays the average expenditure" do
        expect(last_response.body).to include(format_price(12.4))
      end
    end
  end
end
