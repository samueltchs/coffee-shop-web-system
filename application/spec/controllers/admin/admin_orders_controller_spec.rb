RSpec.describe "admin orders controller" do
  include LocalHelpers
  include Conversions

  describe "GET /admin-order" do
    context "when logged in as admin" do
      before do
        admin = add_test_admin_to_db
        add_test_size_to_db("large")
        add_test_size_to_db("medium")
        add_test_milk_option_to_db("Whole")
        add_test_country_to_db("Ethiopian")
        add_test_roast_level_to_db("Light")
        add_test_product_to_db("Coffee", "Latte")
        add_test_product_to_db("Beans", "African Beans")
        add_test_product_variant_to_db(1, 2, 1, 3.7, 2.7)
        add_test_product_variant_to_db(2, 1, 1, 8.0, 5.0)
        @order = add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC12345", "Online", 1, "Completed", "Paid", "SAVE10", 7.5, 10)
        add_test_item_in_order_to_db(1, 1, 3.7, 2, 2, 1)
        add_test_item_in_order_to_db(2, 1, 8.0, 3, 1, 1)
        get_as_employee(admin, "/admin-order?order_id=1")
      end
        
      it "has a status code of 200 (OK)" do
        expect(last_response).to be_ok
      end

      it "displays the correct title" do
        expect(last_response.body).to include("<title>1 - Order Admin View</title>")
      end

      it "displays the correct headline" do
        expect(last_response.body).to include("<h1>Order: 1")
      end

      it "contains the loyalty number of the associated customer" do
        expect(last_response.body).to include("Loyalty no. of customer:")
        expect(last_response.body).to include(@order.loyalty_number.to_s)
      end

      it "contains the order's date placed" do
        expect(last_response.body).to include("Date placed:")
        expect(last_response.body).to include(format_time(@order.date_placed))
      end

      it "contains the order's price" do
        expect(last_response.body).to include("Price:")
        expect(last_response.body).to include(format_price(@order.price))
      end

      it "contains the order's cost" do
        expect(last_response.body).to include("Cost:")
        expect(last_response.body).to include(format_price(@order.cost))
      end

      it "contains the order's net price" do
        expect(last_response.body).to include("Net price:")
        expect(last_response.body).to include(format_price(@order.net_price))
      end

      it "contains the order's tracking id" do
        expect(last_response.body).to include("Tracking ID:")
        expect(last_response.body).to include(@order.tracking_id.to_s)
      end

      it "contains the order's reference id" do
        expect(last_response.body).to include("Reference ID:")
        expect(last_response.body).to include(@order.reference_id)
      end

      it "contains how the order was processed" do
        expect(last_response.body).to include("Processed by:")
        expect(last_response.body).to include(@order.barista)
      end

      it "contains the order's fulfilment status" do
        expect(last_response.body).to include("Order fulfilment:")
        expect(last_response.body).to include(@order.order_fulfilment)
      end

      it "contains the order's delivery status" do
        expect(last_response.body).to include("Order delivery status:")
        expect(last_response.body).to include("Delivered")
      end

      it "contains the order's status" do
        expect(last_response.body).to include("Status:")
        expect(last_response.body).to include(@order.status)
      end

      it "contain the order's payment method" do
        expect(last_response.body).to include("Payment method:")
      end

      it "contains the discount code used" do
        expect(last_response.body).to include("Discount code:")
        expect(last_response.body).to include("SAVE10")
      end

      it "contains the percentage off" do
        expect(last_response.body).to include("Discount")
        expect(last_response.body).to include("10%")
      end

      it "displays the order's contents" do
        expect(last_response.body).to include("Latte")
        expect(last_response.body).to include(format_price(3.7))
        expect(last_response.body).to include("(M)")
        expect(last_response.body).to include("Milk Type: Whole")
        expect(last_response.body).to include("Quantity: 2")
        expect(last_response.body).to include(format_total(3.7, 2))
        expect(last_response.body).to include("African Beans")
        expect(last_response.body).to include(format_price(8.0))
        expect(last_response.body).to include("Quantity: 3")
        expect(last_response.body).to include(format_total(8.0, 3))
        expect(last_response.body).to include("Total:")
      end

      it "contains the change order status form" do
        expect(last_response.body).to include('action="/admin-change-order-status"')
      end

      it "contains the status dropdown" do
        expect(last_response.body).to include('select name="status"')
      end

      it "contains the status dropdown options" do
        expect(last_response.body).to include('option value=""')
        expect(last_response.body).to include('option value="Paid"')
        expect(last_response.body).to include('option value="Unpaid"')
        expect(last_response.body).to include('option value="Owed"')
      end

      it "contains the audit note input field" do
        expect(last_response.body).to include('name="reason_note"')
      end

      it "contains the change status button" do
        expect(last_response.body).to include('value="Change"')
      end

      it "has the current status pre-selected in the dropdown" do
        expect(last_response.body).to include('value="Paid" selected')
      end
    end

    context "when the order is unpaid" do
      before do
        admin = add_test_admin_to_db
        add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC12345", "Online", 1, "Completed", "Unpaid")
        get_as_employee(admin, "/admin-order?order_id=1")
      end

      it "contains the payment reference id form" do
        expect(last_response.body).to include('action="/admin-payment-reference-id"')
      end

      it "contains the reference id input field" do
        expect(last_response.body).to include('name="reference_id"')
      end

      it "contains the reference id submit button" do
        expect(last_response.body).to include('value="Submit"')
      end
    end

    context "when the order is not unpaid" do
      before do
        admin = add_test_admin_to_db
        add_test_order_to_db(1)
        get_as_employee(admin, "/admin-order?order_id=1")
      end

      it "does not contain the payment reference id form" do
        expect(last_response.body).not_to include('action="/admin-payment-reference-id"')
      end

      it "displays a default message" do
        expect(last_response.body).to include("Reference ID verification is only possible for unpaid orders.")
      end
    end

    context "when not logged in as admin" do
      it "redirects to employee login page" do
        get "/admin-order?order_id=1"
        expect(last_response).to be_redirect
        expect(last_response.location).to include("/employee-login-page?error")
      end
    end
  end

  describe "POST /admin-payment-reference-id" do
    context "given an order is unpaid" do
      context "when admin submits an invalid reference id" do
        before do
          admin = add_test_admin_to_db
          add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC12345", "Online", 1, "Completed", "Unpaid")
          post_as_employee(admin, "/admin-payment-reference-id", {
            "order_id" => "1", "reference_id" => "invalid"
          })
        end

        it "has a status code of 200 (OK)" do
          expect(last_response).to be_ok
        end

        it "tells the admin the reference id is not valid" do
          expect(last_response.body).to include(
            "The Reference ID is not valid. Must be 8-12 characters long and be of the form ABC1234567."
          )
        end

        it "displays the value of reference id before submission" do
          expect(last_response.body).to include("ABC12345")
        end

        it "does not save the reference id in the database" do
          expect(Order.first(reference_id: 'invalid')).to be_nil
        end
      end

      context "when admin submits the same reference id as current one" do
        before do
          admin = add_test_admin_to_db
          add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC12345", "Online", 1, "Completed", "Unpaid")
          post_as_employee(admin, "/admin-payment-reference-id", {
            "order_id" => "1", "reference_id" => "ABC12345"
          })
        end

        it "has a status code of 200 (OK)" do
          expect(last_response).to be_ok
        end

        it "tells the admin the reference id cannot be the same" do
          expect(last_response.body).to include("The Reference ID must not be the same as the current one.")
        end

        it "displays the value of reference id before submission" do
          expect(last_response.body).to include("ABC12345")
        end

        it "does not change the reference id in the database" do
          expect(Order.first(reference_id: 'ABC12345')).not_to be_nil
        end
      end

      context "when admin submits an existing reference id" do
        before do
          admin = add_test_admin_to_db
          add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC12345")
          add_test_order_to_db(2, Time.now.utc, 7.3, 7.7, 1, "ABC123456", "Online", 1, "Completed", "Unpaid")
          post_as_employee(admin, "/admin-payment-reference-id", {
            "order_id" => "2", "reference_id" => "ABC12345"
          })
        end

        it "has a status code of 200 (OK)" do
          expect(last_response).to be_ok
        end

        it "tells the admin the reference id already exists" do
          expect(last_response.body).to include("The Reference ID already exists.")
        end

        it "displays the value of reference id before submission" do
          expect(last_response.body).to include("ABC123456")
        end

        it "does not change reference id in the database" do
          expect(Order.first(reference_id: 'ABC123456')).not_to be_nil
        end
      end

      context "when the reference id submitted cannot be verified" do
        before do
          admin = add_test_admin_to_db
          add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC12345", "Online", 1, "Completed", "Unpaid")
          post_as_employee(admin, "/admin-payment-reference-id", {
            "order_id" => "1", "reference_id" => "ABC54321"
          })
        end

        it "has a status code of 200 (OK)" do
          expect(last_response).to be_ok
        end

        it "tells the admin the reference id could not be verified" do
          expect(last_response.body).to include("The Reference ID could not be verified.")
        end

        it "displays the value of reference id before submission" do
          expect(last_response.body).to include("ABC12345")
        end

        it "does not change reference id in the database" do
          expect(Order.first(reference_id: 'ABC12345')).not_to be_nil
        end
      end

      context "when admin submits a valid reference id that is verified" do
        before do
          admin = add_test_admin_to_db
          add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC12345", "Online", 1, "Completed", "Unpaid")
          post_as_employee(admin, "/admin-payment-reference-id", {
            "order_id" => "1", "reference_id" => "ABC123456"
          })
        end

        it "has a status code of 200 (OK)" do
          expect(last_response).to be_ok
        end

        it "tells the admin to proceed with marking the order as paid" do
          expect(last_response.body).to include(
            "The payment has been successfully verified. Please proceed with marking the order as paid."
          )
        end

        it "displays the new value of the reference id" do
          expect(last_response.body).to include("ABC123456")
        end

        it "saves the value of the reference id in the database" do
          expect(Order.first(reference_id: 'ABC123456')).not_to be_nil
          expect(Order.first(reference_id: 'ABC12345')).to be_nil
        end
      end
    end
  end

  describe "POST /admin-change-order-status" do
    context "when admin submits an invalid status" do
      before do
        admin = add_test_admin_to_db
        add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC12345", "Online", 1, "Collected", "Paid")
        post_as_employee(admin, "/admin-change-order-status", {
          "order_id" => "1", "status" => "invalid", "reason_note" => "proof"
        })
      end

      it "has a status code of 200 (OK)" do
        expect(last_response).to be_ok
      end

      it "tells the admin the status is not valid" do
        expect(last_response.body).to include("The order's status is not valid.")
      end

      it "displays the value of the status before submission" do
        expect(last_response.body).to include("Paid")
      end

      it "does not change the status in the database" do
        expect(Order.first(status: 'Paid')).not_to be_nil
      end

      it "does not save the reason note in the database" do
        expect(OrderStatusAudit.first(reason_note: 'proof')).to be_nil
      end
    end

    context "when admin submits the same status as current one" do
      before do
        admin = add_test_admin_to_db
        add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC12345", "Online", 1, "Collected", "Paid")
        post_as_employee(admin, "/admin-change-order-status", {
          "order_id" => "1", "status" => "Paid", "reason_note" => "proof"
        })
      end

      it "has a status code of 200 (OK)" do
        expect(last_response).to be_ok
      end

      it "tells the admin the status must not be the same" do
        expect(last_response.body).to include("The order's status must not be the same as the current one.")
      end

      it "displays the value of the status before submission" do
        expect(last_response.body).to include("Paid")
      end

      it "does not change the status in the database" do
        expect(Order.first(status: 'Paid')).not_to be_nil
      end

      it "does not save the reason note in the database" do
        expect(OrderStatusAudit.first(reason_note: 'proof')).to be_nil
      end
    end

    context "when admin submits a valid status but no reason note" do
      before do
        admin = add_test_admin_to_db
        add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC12345", "Online", 1, "Collected", "Paid")
        post_as_employee(admin, "/admin-change-order-status", {
          "order_id" => "1", "status" => "Owed", "reason_note" => ""
        })
      end

      it "has a status code of 200 (OK)" do
        expect(last_response).to be_ok
      end

      it "tells the admin that a reason note is required" do
        expect(last_response.body).to include("A reason note is required.")
      end

      it "displays the value of the status before submission" do
        expect(last_response.body).to include("Paid")
      end

      it "does not change the status in the database" do
        expect(Order.first(status: 'Paid')).not_to be_nil
      end

      it "does not save the reason note in the database" do
        expect(OrderStatusAudit.first(reason_note: '')).to be_nil
      end
    end

    context "when admin submits a valid status with a reason note" do
      before do
        admin = add_test_admin_to_db("admin")
        add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC12345", "Online", 1, "Collected", "Unpaid")
        post_as_employee(admin, "/admin-change-order-status", {
          "order_id" => "1", "status" => "Paid", "reason_note" => "sufficient proof"
        })
      end

      it "has a status code of 200 (OK)" do
        expect(last_response).to be_ok
      end

      it "displays a confirmation message" do
        expect(last_response.body).to include("The order")
        expect(last_response.body).to include("status has been updated successfully.")
      end

      it "displays the new value of the status" do
        expect(last_response.body).to include("Paid")
      end

      it "has the new status selected in dropdown" do
        expect(last_response.body).to include('value="Paid" selected')
      end

      it "saves the value of the status in the database" do
        expect(Order.first(status: 'Paid')).not_to be_nil
        expect(Order.first(status: 'Unpaid')).to be_nil
      end

      it "saves the reason note in the database" do
        audit = OrderStatusAudit.first(order_unique_id: 1)
        expect(audit.old_status).to eq("Unpaid")
        expect(audit.new_status).to eq("Paid")
        expect(audit.reason_note).to eq("sufficient proof")
        expect(audit.changed_by).to eq("admin")
        expect(audit.changed_at).not_to be_nil
      end
    end
  end
end
