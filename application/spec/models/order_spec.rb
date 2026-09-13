require_relative "../spec_helper"

RSpec.describe Order do
  include Validation

  let(:barista) { "Barista1!" }

  describe ".create_order" do
    it "creates a new order entry in the database" do
      Order.create_order(barista)
      expect(Order.where(barista: barista, order_fulfilment: "Incomplete", status: "Unpaid").count).to eq(1)
    end
  end

  describe ".get_order" do
    it "returns the order when it exists" do
      order = add_test_order_to_db
      expect(Order.get_order(order.order_unique_id)).not_to be_nil
    end

    it "returns nil when the order does not exist" do
      expect(Order.get_order(-1)).to be_nil
    end
  end

  describe ".get_complete_orders" do
    it "excludes Incomplete orders" do
      Order.create_order(barista)
      expect(Order.get_complete_orders.any? { |order| order.order_fulfilment == "Incomplete" }).to be false
    end

    it "excludes Unpaid orders" do
      add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "REF001", "Online", 1, "Completed", "Unpaid")
      expect(Order.get_complete_orders.any? { |order| order.status == "Unpaid" }).to be false
    end

    it "includes Paid completed orders" do
      order = add_test_order_to_db
      expect(Order.get_complete_orders.map(&:order_unique_id)).to include(order.order_unique_id)
    end
  end

  describe ".get_deliverable" do
    it "returns orders that are Paid, Completed, undelivered, and have no tracking_id" do
      order = add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 0, "REF001", "Online", 0, "Completed", "Paid")
      expect(Order.get_deliverable.map(&:order_unique_id)).to include(order.order_unique_id)
    end

    it "excludes orders that already have a tracking_id" do
      order = add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "REF002", "Online", 0, "Completed", "Paid")
      expect(Order.get_deliverable.map(&:order_unique_id)).not_to include(order.order_unique_id)
    end

    it "excludes already delivered orders" do
      order = add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 0, "REF003", "Online", 1, "Completed", "Paid")
      expect(Order.get_deliverable.map(&:order_unique_id)).not_to include(order.order_unique_id)
    end

    it "excludes orders with a non-Paid status" do
      unpaid = add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 0, "REF004", "Online", 0, "Completed", "Unpaid")
      refunded = add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 0, "REF005", "Online", 0, "Completed", "Refunded")
      ids = Order.get_deliverable.map(&:order_unique_id)
      expect(ids).not_to include(unpaid.order_unique_id)
      expect(ids).not_to include(refunded.order_unique_id)
    end
  end

  describe ".get_all_orders_by_customer" do
    it "returns all orders for a customer" do
      add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "REF001")
      add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "REF002")
      expect(Order.get_all_orders_by_customer(1).count).to eq(2)
    end
  end

  describe ".get_delivered_id" do
    it "returns 1 for Delivered" do
      expect(Order.get_delivered_id("Delivered")).to eq(1)
    end

    it "returns 0 for anything else" do
      expect(Order.get_delivered_id("Not Delivered")).to eq(0)
    end
  end

  describe ".cleanup" do
    it "deletes all incomplete orders for the barista" do
      Order.create_order(barista)
      Order.cleanup(barista)
      expect(Order.where(barista: barista, order_fulfilment: "Incomplete").count).to eq(0)
    end
  end

  describe ".get_all_orders_details_by_customer" do
    it "returns an array of order detail hashes" do
      add_test_order_to_db(1)
      details = Order.get_all_orders_details_by_customer(1)
      expect(details).to be_an(Array)
      expect(details.first).to include("id", "no_items", "price", "date")
    end
  end

  context "with a basic saved order" do
    let(:order) { add_test_order_to_db }

    describe "#set_customer" do
      it "updates the loyalty number" do
        order.set_customer(42)
        expect(Order.first(order_unique_id: order.order_unique_id).loyalty_number).to eq(42)
      end
    end

    describe "#set_reference_id" do
      it "updates the reference id" do
        order.set_reference_id("XYZ99999")
        expect(Order.first(order_unique_id: order.order_unique_id).reference_id).to eq("XYZ99999")
      end
    end

    describe "#get_customer" do
      it "returns the loyalty number" do
        expect(order.get_customer).to eq(1)
      end
    end

    describe "#get_barista" do
      it "returns the barista value when set" do
        expect(order.get_barista).to eq("Online")
      end

      it "returns 'Online' when barista is nil" do
        order = Order.create_order(barista)
        order.update(barista: nil)
        expect(order.get_barista).to eq("Online")
      end
    end

    describe "#get_discount_code_used" do
      it "returns the discount code when set" do
        order = add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC12345", "Online", 1, "Completed", "Paid", "SAVE10")
        expect(order.get_discount_code_used).to eq("SAVE10")
      end

      it "returns 'None' when no discount code was used" do
        expect(order.get_discount_code_used).to eq("None")
      end
    end

    describe "#get_percentage_off" do
      it "returns the percentage off when set" do
        order.update(percentage_off: 20)
        expect(order.get_percentage_off).to eq("20%")
      end

      it "returns 'N/A' when percentage off is nil" do
        expect(order.get_percentage_off).to eq("N/A")
      end
   end

    describe "#get_loyalty_number" do
      it "returns the loyalty number when set" do
        expect(order.get_loyalty_number).to eq(1)
      end

      it "returns 'N/A' when no loyalty number" do
        order = Order.create_order(barista)
        expect(order.get_loyalty_number).to eq("N/A")
      end
    end

    describe "#get_tracking_id" do
      it "returns the tracking id when set" do
        expect(order.get_tracking_id).to eq(1)
      end

      it "returns 'Handled In-Store' when no tracking id" do
        order = Order.create_order(barista)
        expect(order.get_tracking_id).to eq("Handled In-Store")
      end
    end

    describe "#get_cost" do
      it "returns the cost rounded to 2 decimal places" do
        expect(order.get_cost).to eq(7.3)
      end

      it "returns 'N/A' when cost is nil" do
        order = Order.create_order(barista)
        expect(order.get_cost).to eq("N/A")
      end
    end

    describe "#get_price" do
      it "returns the price rounded to 2 decimal places" do
        expect(order.get_price).to eq(7.7)
      end

      it "returns 'N/A' when price is nil" do
        order = Order.create_order(barista)
        expect(order.get_price).to eq("N/A")
      end
    end

    describe "#get_net_price" do
      it "returns the net price rounded to 2 decimal places" do
        expect(order.get_net_price).to eq(7.5)
      end

      it "returns 'N/A' when net_price is nil" do
        order = Order.create_order(barista)
        expect(order.get_net_price).to eq("N/A")
      end
    end

    describe "#get_delivered" do
      it "returns 'Delivered' when delivered is 1" do
        expect(order.get_delivered).to eq("Delivered")
      end

      it "returns 'Not Delivered' when delivered is 0" do
        order = add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "REF002", "Online", 0)
        expect(order.get_delivered).to eq("Not Delivered")
      end

      it "returns 'Not Delivered' when delivered is nil" do
        order = add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "REF_NIL", "Online", nil)
        expect(order.get_delivered).to eq("Not Delivered")
      end
    end

    describe "#get_reference_id" do
      it "returns the reference id when set" do
        expect(order.get_reference_id).to eq("ABC12345")
      end

      it "returns 'N/A' when reference id is nil" do
        order = Order.create_order(barista)
        expect(order.get_reference_id).to eq("N/A")
      end
    end

    describe "#get_date_placed" do
      it "returns the date placed" do
        expect(order.get_date_placed).not_to be_nil
      end
    end

    describe "#mark_order_as_paid" do
      it "sets status to Paid" do
        order = Order.create_order(barista)
        order.mark_order_as_paid
        expect(Order.first(order_unique_id: order.order_unique_id).status).to eq("Paid")
      end
    end

    describe "#set_delivered" do
      it "sets delivered to 1" do
        order = add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "REF002", "Online", 0)
        order.set_delivered
        expect(Order.first(order_unique_id: order.order_unique_id).delivered).to eq(1)
      end
    end

    describe "#set_collected" do
      it "sets order_fulfilment to Collected" do
        order = Order.create_order(barista)
        order.set_collected
        expect(Order.first(order_unique_id: order.order_unique_id).order_fulfilment).to eq("Collected")
      end
    end

    describe "#owed?" do
      it "returns true when status is Owed" do
        order = add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "REF002", "Online", 1, "Completed", "Owed")
        expect(order.owed?).to be true
      end

      it "returns false when status is not Owed" do
        expect(order.owed?).to be false
      end
    end

    describe "#incomplete?" do
      it "returns true when order_fulfilment is Incomplete" do
        order = Order.create_order(barista)
        expect(order.incomplete?).to be true
      end

      it "returns false when order is not Incomplete" do
        expect(order.incomplete?).to be false
      end
    end

    describe "#refunded?" do
      it "returns true when status is Refunded" do
        order = add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "REF002", "Online", 1, "Completed", "Refunded")
        expect(order.refunded?).to be true
      end

      it "returns false when status is not Refunded" do
        expect(order.refunded?).to be false
      end
    end

    describe "#checkout" do
      it "marks the order as delivered, collected, and updates the barista" do
        order = add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "REF002", "Online", 0, "Completed", "Paid")
        order.checkout("NewBarista")
        refreshed = Order.first(order_unique_id: order.order_unique_id)
        expect(refreshed.delivered).to eq(1)
        expect(refreshed.order_fulfilment).to eq("Collected")
        expect(refreshed.barista).to eq("NewBarista")
      end

      it "sets the payment method and marks as Paid when payment_method is given" do
        payment = PaymentMethod.create(payment_method: "Cash")
        order = add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "REF002", "Online", 0, "Completed", "Owed")
        order.checkout("NewBarista", "Cash")
        refreshed = Order.first(order_unique_id: order.order_unique_id)
        expect(refreshed.status).to eq("Paid")
        expect(refreshed.payment_method).to eq(payment.id)
      end

      it "generates a new reference id when payment method is Card" do
        PaymentMethod.create(payment_method: "Card")
        order = add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "REF002", "Online", 0, "Completed", "Owed")
        order.checkout("NewBarista", "Card")
        refreshed = Order.first(order_unique_id: order.order_unique_id)
        expect(refreshed.reference_id).not_to eq("REF002")
      end
    end
  end

  context "with items in order" do
    before do
      country = add_test_country_to_db
      roast   = add_test_roast_level_to_db
      @size   = add_test_size_to_db("standard")
      @milk   = add_test_milk_option_to_db("none")
      @beans  = add_test_product_to_db("beans", "Test Beans", 10, 1, country.id, roast.id)
      @drink  = add_test_product_to_db("drinks", "Test Latte", nil, 1, country.id, roast.id)
      add_test_product_variant_to_db(@beans.product_id, @size.id, @milk.id, 5.0, 3.0)
      add_test_product_variant_to_db(@drink.product_id, @size.id, @milk.id, 3.7, 2.5)
      @order = add_test_order_to_db(1, Time.now.utc, 0, 0, 1, "REF001", "Online", 0, "Completed", "Paid", "", 0)
    end

    describe "#get_all_items_in_order" do
      it "returns nil when the order has no items" do
        expect(@order.get_all_items_in_order).to be_nil
      end

      it "returns items when the order has items" do
        add_test_item_in_order_to_db(@beans.product_id, @order.order_unique_id, 5.0, 1, @size.id, @milk.id)
        expect(@order.get_all_items_in_order).not_to be_nil
      end
    end

    describe "#all_items_beans?" do
      it "returns true when all items are beans" do
        add_test_item_in_order_to_db(@beans.product_id, @order.order_unique_id, 5.0, 1, @size.id, @milk.id)
        expect(@order.all_items_beans?).to be true
      end

      it "returns false when there are non-bean items" do
        add_test_item_in_order_to_db(@drink.product_id, @order.order_unique_id, 3.7, 1, @size.id, @milk.id)
        expect(@order.all_items_beans?).to be false
      end

      it "returns false when there are no items" do
        expect(@order.all_items_beans?).to be false
      end
    end

    describe "#get_beans" do
      it "returns bean items when present" do
        add_test_item_in_order_to_db(@beans.product_id, @order.order_unique_id, 5.0, 1, @size.id, @milk.id)
        expect(@order.get_beans).not_to be_nil
      end

      it "returns nil when there are no bean items" do
        add_test_item_in_order_to_db(@drink.product_id, @order.order_unique_id, 3.7, 1, @size.id, @milk.id)
        expect(@order.get_beans).to be_nil
      end
    end

    describe "#get_drinks" do
      it "returns drink items when present" do
        add_test_item_in_order_to_db(@drink.product_id, @order.order_unique_id, 3.7, 1, @size.id, @milk.id)
        expect(@order.get_drinks).not_to be_nil
      end

      it "returns nil when there are no drink items" do
        add_test_item_in_order_to_db(@beans.product_id, @order.order_unique_id, 5.0, 1, @size.id, @milk.id)
        expect(@order.get_drinks).to be_nil
      end
    end

    describe "#set_price" do
      it "sets the price to the sum of item prices times quantity" do
        add_test_item_in_order_to_db(@beans.product_id, @order.order_unique_id, 5.0, 2, @size.id, @milk.id)
        @order.set_price
        expect(Order.first(order_unique_id: @order.order_unique_id).price).to eq(10.0)
      end

      it "returns 0 when there are no items" do
        expect(@order.set_price).to eq(0)
      end
    end

    describe "#set_cost" do
      it "sets the cost from product variant costs times quantity" do
        add_test_item_in_order_to_db(@beans.product_id, @order.order_unique_id, 5.0, 2, @size.id, @milk.id)
        @order.set_cost
        expect(Order.first(order_unique_id: @order.order_unique_id).cost).to eq(6.0)
      end

      it "returns 0 when there are no items" do
        expect(@order.set_cost).to eq(0)
      end
    end

    describe "#get_total_price_by_type" do
      before do
        add_test_item_in_order_to_db(@beans.product_id, @order.order_unique_id, 5.0, 2, @size.id, @milk.id)
        add_test_item_in_order_to_db(@drink.product_id, @order.order_unique_id, 3.7, 1, @size.id, @milk.id)
      end

      it "returns total price for beans only" do
        expect(@order.get_total_price_by_type("beans")).to eq(10.0)
      end

      it "returns total price for drinks only" do
        expect(@order.get_total_price_by_type("drinks")).to eq(3.7)
      end

      it "returns total price for all items when type is 'both'" do
        expect(@order.get_total_price_by_type("both")).to eq(13.7)
      end
    end

    describe "#get_total_quantity_by_type" do
      before do
        add_test_item_in_order_to_db(@beans.product_id, @order.order_unique_id, 5.0, 3, @size.id, @milk.id)
        add_test_item_in_order_to_db(@drink.product_id, @order.order_unique_id, 3.7, 2, @size.id, @milk.id)
      end

      it "returns quantity for beans only" do
        expect(@order.get_total_quantity_by_type("beans")).to eq(3)
      end

      it "returns quantity for drinks only" do
        expect(@order.get_total_quantity_by_type("drinks")).to eq(2)
      end
    end

    describe "#get_total_quantity_by_id" do
      it "returns total quantity for a specific product" do
        add_test_item_in_order_to_db(@beans.product_id, @order.order_unique_id, 5.0, 4, @size.id, @milk.id)
        expect(@order.get_total_quantity_by_id(@beans.product_id)).to eq(4)
      end
    end

    describe "#get_most_expensive_drink" do
      it "returns the most expensive drink" do
        add_test_item_in_order_to_db(@drink.product_id, @order.order_unique_id, 3.7, 1, @size.id, @milk.id)
        result = @order.get_most_expensive_drink
        expect(result).not_to be_nil
        expect(result.item_id).to eq(@drink.product_id)
      end

      it "returns nil when there are no drink items" do
        add_test_item_in_order_to_db(@beans.product_id, @order.order_unique_id, 5.0, 1, @size.id, @milk.id)
        expect(@order.get_most_expensive_drink).to be_nil
      end
    end

    describe "#get_cheapest_drink_entry" do
      it "returns the cheapest drink item" do
        add_test_item_in_order_to_db(@drink.product_id, @order.order_unique_id, 3.7, 1, @size.id, @milk.id)
        result = @order.get_cheapest_drink_entry
        expect(result).not_to be_nil
        expect(result.item_id).to eq(@drink.product_id)
      end
    end

    describe "#set_net_price_barista" do
      it "sets the net price to the sum of item prices times quantity" do
        add_test_item_in_order_to_db(@beans.product_id, @order.order_unique_id, 5.0, 2, @size.id, @milk.id)
        total = @order.set_net_price_barista
        expect(total).to eq(10.0)
      end

      it "returns 0 when there are no items" do
        expect(@order.set_net_price_barista).to eq(0)
      end
    end

    describe "#remove_all_items" do
      it "removes all items from the order" do
        add_test_item_in_order_to_db(@beans.product_id, @order.order_unique_id, 5.0, 1, @size.id, @milk.id)
        @order.remove_all_items
        expect(@order.get_all_items_in_order).to be_nil
      end
    end

    describe ".total_in_daterange_by_type" do
      it "returns the sum of prices for a given type across all orders" do
        add_test_item_in_order_to_db(@beans.product_id, @order.order_unique_id, 5.0, 2, @size.id, @milk.id)
        expect(Order.total_in_daterange_by_type("beans")).to eq(10.0)
      end

      it "returns 0 when the order falls outside the date range" do
        add_test_item_in_order_to_db(@beans.product_id, @order.order_unique_id, 5.0, 2, @size.id, @milk.id)
        expect(Order.total_in_daterange_by_type("beans", Date.today - 20, Date.today - 10)).to eq(0)
      end
    end

    describe "#give_stamps" do
      it "adds 1 stamp per drink to the customer" do
        customer = add_test_customer_to_db
        order = add_test_order_to_db(customer.loyalty_number)
        add_test_item_in_order_to_db(@drink.product_id, order.order_unique_id, 3.7, 2, @size.id, @milk.id)
        order.give_stamps
        expect(Customer.first(loyalty_number: customer.loyalty_number).stamps).to eq(2)
      end

      it "adds 3 stamps per unit of beans to the customer" do
        customer = add_test_customer_to_db
        order = add_test_order_to_db(customer.loyalty_number)
        add_test_item_in_order_to_db(@beans.product_id, order.order_unique_id, 5.0, 2, @size.id, @milk.id)
        order.give_stamps
        expect(Customer.first(loyalty_number: customer.loyalty_number).stamps).to eq(6)
      end
    end

    describe "#remove_all_discounts" do
      it "does not raise an error when called on an order with items" do
        add_test_item_in_order_to_db(@beans.product_id, @order.order_unique_id, 5.0, 1, @size.id, @milk.id)
        expect { @order.remove_all_discounts }.not_to raise_error
      end
    end

    describe "#refund" do
      it "sets the order status to Refunded" do
        add_test_item_in_order_to_db(@beans.product_id, @order.order_unique_id, 5.0, 1, @size.id, @milk.id)
        @order.refund
        expect(Order.get_order(@order.order_unique_id).status).to eq("Refunded")
      end

      it "marks each item as refunded" do
        item = add_test_item_in_order_to_db(@beans.product_id, @order.order_unique_id, 5.0, 1, @size.id, @milk.id)
        @order.refund
        expect(ItemInOrder.get_item(item.item_in_order_id).refunded).to eq(1)
      end
    end

    describe "#submit" do
      it "marks the order as Paid, Collected, and Delivered with the given payment method" do
        payment_method = PaymentMethod.create(payment_method: "Cash")
        add_test_item_in_order_to_db(@drink.product_id, @order.order_unique_id, 3.7, 1, @size.id, @milk.id)
        @order.submit(payment_method.id, "XYZ12345")
        refreshed = Order.first(order_unique_id: @order.order_unique_id)
        expect(refreshed.status).to eq("Paid")
        expect(refreshed.order_fulfilment).to eq("Collected")
        expect(refreshed.delivered).to eq(1)
        expect(refreshed.payment_method).to eq(payment_method.id)
      end
    end
  end

  describe "#validate_reference_id" do
    it "returns false if the reference id is not valid" do
      order = Order.new
      order.reference_id = "invalid"

      expect(order.validate_reference_id).to be false
      expect(order.errors["reference_id"]).to include(
        "is not valid. Must be 8-12 characters long and be of the form ABC1234567."
      )
    end

    it "returns false if reference id the same as current one" do
      order = Order.new
      order.reference_id = "ABC12345"
      order.old_values = { reference_id: "ABC12345" }

      expect(order.validate_reference_id).to be false
      expect(order.errors["reference_id"]).to include("must not be the same as the current one.")
    end

    it "returns false if reference id already exists" do
      add_test_order_to_db
      order = Order.new
      order.reference_id = "ABC12345"

      expect(order.validate_reference_id).to be false
      expect(order.errors["reference_id"]).to include("already exists.")
    end

    it "returns false if reference id could not be verified" do
      order = Order.new
      order.reference_id = "ABC54321"

      expect(order.validate_reference_id).to be false
      expect(order.errors["reference_id"]).to include("could not be verified.")
    end

    it "returns true if reference id is valid" do
      order = Order.new
      order.reference_id = "ABC12345"
      expect(order.validate_reference_id).to be true
    end
  end

  describe "#validate_status" do
    it "returns false if the status is not valid" do
      order = Order.new
      order.status = "invalid"

      expect(order.validate_status).to be false
      expect(order.errors["status"]).to include("is not valid.")
    end

    it "returns false if status is the same as current one" do
      order = Order.new
      order.status = "Paid"
      order.old_values = { status: "Paid" }

      expect(order.validate_status).to be false
      expect(order.errors["status"]).to include("must not be the same as the current one.")
    end

    it "returns true if status is valid" do
      order = Order.new
      order.status = "Owed"
      expect(order.validate_status).to be true
    end
  end

  describe "#load" do
    it "loads correctly the values from params" do
      order = Order.new

      params = {
        "order_fulfilment" => "Completed",
        "status" => "Paid"
      }

      order.load(params)

      expect(order.order_fulfilment).to eq("Completed")
      expect(order.status).to eq("Paid")
    end

    it "generates a reference id if one is not already set" do
      order = Order.new

      params = {
        "order_fulfilment" => "Collected",
        "status" => "Unpaid"
      }

      order.load(params)

      expect(order.reference_id).not_to be_nil
      expect(valid_reference_id?(order.reference_id)).to be true
    end
  end

  describe "#get_payment_method" do
    it "returns the name of the payment method" do
      payment_method = PaymentMethod.create(payment_method: "Card")
      order = add_test_order_to_db
      order.update(payment_method: payment_method.id)
      expect(order.get_payment_method).to eq("Card")
    end

    it "returns nil when no payment method is set" do
      order = add_test_order_to_db
      expect(order.get_payment_method).to be_nil
    end
  end

  describe ".past_sales_filtering" do
    before do
      @customer = add_test_customer_to_db
      @order = add_test_order_to_db(@customer.loyalty_number, Time.now.utc, 7.3, 7.7, 1, "REF001", "barista1", 1, "Completed", "Paid")
    end

    it "returns all completed paid orders when all filters are empty" do
      result = Order.past_sales_filtering(nil, "", "", "", "", "", "", "", "", "")
      expect(result.map(&:order_unique_id)).to include(@order.order_unique_id)
    end

    it "filters by barista" do
      order2 = add_test_order_to_db(@customer.loyalty_number, Time.now.utc, 7.3, 7.7, 1, "REF002", "barista2", 1, "Completed", "Paid")
      result = Order.past_sales_filtering(nil, "barista1", "", "", "", "", "", "", "", "")
      ids = result.map(&:order_unique_id)
      expect(ids).to include(@order.order_unique_id)
      expect(ids).not_to include(order2.order_unique_id)
    end

    it "filters by fulfilment" do
      order2 = add_test_order_to_db(@customer.loyalty_number, Time.now.utc, 7.3, 7.7, 1, "REF002", "barista1", 1, "Collected", "Paid")
      result = Order.past_sales_filtering(nil, "", "Completed", "", "", "", "", "", "", "")
      ids = result.map(&:order_unique_id)
      expect(ids).to include(@order.order_unique_id)
      expect(ids).not_to include(order2.order_unique_id)
    end

    it "filters by loyalty number" do
      customer2 = add_test_customer_to_db(2)
      order2 = add_test_order_to_db(customer2.loyalty_number, Time.now.utc, 7.3, 7.7, 1, "REF002", "barista1", 1, "Completed", "Paid")
      result = Order.past_sales_filtering(nil, "", "", @customer.loyalty_number.to_s, "", "", "", "", "", "")
      ids = result.map(&:order_unique_id)
      expect(ids).to include(@order.order_unique_id)
      expect(ids).not_to include(order2.order_unique_id)
    end

    it "filters by payment_status=Paid" do
      order2 = add_test_order_to_db(@customer.loyalty_number, Time.now.utc, 7.3, 7.7, 1, "REF002", "barista1", 1, "Completed", "Refunded")
      result = Order.past_sales_filtering(nil, "", "", "", "", "", "Paid", "", "", "")
      ids = result.map(&:order_unique_id)
      expect(ids).to include(@order.order_unique_id)
      expect(ids).not_to include(order2.order_unique_id)
    end

    it "excludes paid orders when payment_status=Owed" do
      order2 = add_test_order_to_db(@customer.loyalty_number, Time.now.utc, 7.3, 7.7, 1, "REF002", "barista1", 1, "Completed", "Refunded")
      result = Order.past_sales_filtering(nil, "", "", "", "", "", "Owed", "", "", "")
      ids = result.map(&:order_unique_id)
      expect(ids).not_to include(@order.order_unique_id)
      expect(ids).to include(order2.order_unique_id)
    end

    it "filters by delivery=Not Delivered" do
      order2 = add_test_order_to_db(@customer.loyalty_number, Time.now.utc, 7.3, 7.7, 1, "REF002", "barista1", 0, "Completed", "Paid")
      result = Order.past_sales_filtering(nil, "", "", "", "", "Not Delivered", "", "", "", "")
      ids = result.map(&:order_unique_id)
      expect(ids).to include(order2.order_unique_id)
      expect(ids).not_to include(@order.order_unique_id)
    end

    it "filters by delivery=Delivered" do
      order2 = add_test_order_to_db(@customer.loyalty_number, Time.now.utc, 7.3, 7.7, 1, "REF002", "barista1", 0, "Completed", "Paid")
      result = Order.past_sales_filtering(nil, "", "", "", "", "Delivered", "", "", "", "")
      ids = result.map(&:order_unique_id)
      expect(ids).to include(@order.order_unique_id)
      expect(ids).not_to include(order2.order_unique_id)
    end

    it "filters by tracking=Handled In-Store" do
      order_in_store = add_test_order_to_db(@customer.loyalty_number, Time.now.utc, 7.3, 7.7, nil, "REF002", "barista1", 1, "Completed", "Paid")
      result = Order.past_sales_filtering(nil, "", "", "", "", "", "", "Handled In-Store", "", "")
      ids = result.map(&:order_unique_id)
      expect(ids).to include(order_in_store.order_unique_id)
      expect(ids).not_to include(@order.order_unique_id)
    end

    it "filters by tracking=Has Tracking" do
      order_in_store = add_test_order_to_db(@customer.loyalty_number, Time.now.utc, 7.3, 7.7, nil, "REF002", "barista1", 1, "Completed", "Paid")
      result = Order.past_sales_filtering(nil, "", "", "", "", "", "", "Has Tracking", "", "")
      ids = result.map(&:order_unique_id)
      expect(ids).to include(@order.order_unique_id)
      expect(ids).not_to include(order_in_store.order_unique_id)
    end

    it "filters by start date to exclude older orders" do
      @order.update(date_placed: (Time.now.utc - SECONDS_IN_DAY * 10).to_s)
      order2 = add_test_order_to_db(@customer.loyalty_number, Time.now.utc, 7.3, 7.7, 1, "REF002", "barista1", 1, "Completed", "Paid")
      yesterday = (Time.now.utc - SECONDS_IN_DAY).strftime("%Y-%m-%d")
      result = Order.past_sales_filtering(nil, "", "", "", "", "", "", "", yesterday, "")
      ids = result.map(&:order_unique_id)
      expect(ids).to include(order2.order_unique_id)
      expect(ids).not_to include(@order.order_unique_id)
    end

    it "filters by end date to exclude future orders" do
      order2 = add_test_order_to_db(@customer.loyalty_number, (Time.now.utc + SECONDS_IN_DAY * 10), 7.3, 7.7, 1, "REF002", "barista1", 1, "Completed", "Paid")
      tomorrow = (Time.now.utc + SECONDS_IN_DAY).strftime("%Y-%m-%d")
      result = Order.past_sales_filtering(nil, "", "", "", "", "", "", "", "", tomorrow)
      ids = result.map(&:order_unique_id)
      expect(ids).to include(@order.order_unique_id)
      expect(ids).not_to include(order2.order_unique_id)
    end
  end

  describe ".create_online_order" do
    before { @customer = add_test_customer_to_db }

    it "creates an Incomplete Unpaid order with delivered=0 when delivery is true" do
      order = Order.create_online_order(@customer.loyalty_number, true)
      expect(order.order_fulfilment).to eq("Incomplete")
      expect(order.status).to eq("Unpaid")
      expect(order.delivered).to eq(0)
      expect(order.loyalty_number).to eq(@customer.loyalty_number)
    end

    it "creates an order with delivered=nil when delivery is false" do
      order = Order.create_online_order(@customer.loyalty_number, false)
      expect(order.delivered).to be_nil
    end
  end

  describe ".set_net_price" do
    it "returns nil when the order does not exist" do
      expect(Order.set_net_price(-1)).to be_nil
    end

    it "sets net_price equal to price when no discount code is used" do
      order = add_test_order_to_db(1, Time.now.utc, 7.3, 10.0, 1, "REF001", "Online", 1, "Completed", "Paid", "", 0)
      Order.set_net_price(order.order_unique_id)
      expect(Order.first(order_unique_id: order.order_unique_id).net_price).to eq(10.0)
    end

    it "sets net_price using the discount multiplier when a code is applied" do
      code = DiscountCode.new
      code.discount_code = "NET20"
      code.percentage_off = 20
      code.save_changes
      order = add_test_order_to_db(1, Time.now.utc, 7.3, 10.0, 1, "REF001", "Online", 1, "Completed", "Paid", "NET20", 0)
      Order.set_net_price(order.order_unique_id)
      expect(Order.first(order_unique_id: order.order_unique_id).net_price).to be_within(0.01).of(8.0)
    end
  end

  describe ".select_relevant_orders" do
    it "returns all orders when no date range is given" do
      order = add_test_order_to_db
      result = Order.select_relevant_orders(Order.all)
      expect(result.map(&:order_unique_id)).to include(order.order_unique_id)
    end

    it "returns only orders on or after from_date" do
      old_order = add_test_order_to_db(1, Time.now.utc - SECONDS_IN_DAY * 10, 7.3, 7.7, 1, "REF001")
      new_order = add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "REF002")
      result = Order.select_relevant_orders(Order.all, Date.today - 1, nil)
      ids = result.map(&:order_unique_id)
      expect(ids).to include(new_order.order_unique_id)
      expect(ids).not_to include(old_order.order_unique_id)
    end

    it "returns only orders on or before to_date" do
      today_order = add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "REF001")
      future_order = add_test_order_to_db(1, Time.now.utc + SECONDS_IN_DAY * 10, 7.3, 7.7, 1, "REF002")
      result = Order.select_relevant_orders(Order.all, nil, Date.today + 1)
      ids = result.map(&:order_unique_id)
      expect(ids).to include(today_order.order_unique_id)
      expect(ids).not_to include(future_order.order_unique_id)
    end

    it "returns only orders within the from and to date range" do
      old_order    = add_test_order_to_db(1, Time.now.utc - SECONDS_IN_DAY * 10, 7.3, 7.7, 1, "REF001")
      today_order  = add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "REF002")
      future_order = add_test_order_to_db(1, Time.now.utc + SECONDS_IN_DAY * 10, 7.3, 7.7, 1, "REF003")
      result = Order.select_relevant_orders(Order.all, Date.today - 1, Date.today + 1)
      ids = result.map(&:order_unique_id)
      expect(ids).to include(today_order.order_unique_id)
      expect(ids).not_to include(old_order.order_unique_id)
      expect(ids).not_to include(future_order.order_unique_id)
    end
  end

  describe ".get_date_range" do
    it "filters by start date to exclude older orders" do
      old_order = add_test_order_to_db(1, Time.now.utc - SECONDS_IN_DAY * 10, 7.3, 7.7, 1, "REF001")
      new_order = add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "REF002")
      yesterday = (Time.now.utc - SECONDS_IN_DAY).strftime("%Y-%m-%d")
      result = Order.get_date_range(Order.dataset, yesterday, "")
      ids = result.map(&:order_unique_id)
      expect(ids).to include(new_order.order_unique_id)
      expect(ids).not_to include(old_order.order_unique_id)
    end

    it "filters by end date to exclude future orders" do
      today_order  = add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "REF001")
      future_order = add_test_order_to_db(1, Time.now.utc + SECONDS_IN_DAY * 10, 7.3, 7.7, 1, "REF002")
      tomorrow = (Time.now.utc + SECONDS_IN_DAY).strftime("%Y-%m-%d")
      result = Order.get_date_range(Order.dataset, "", tomorrow)
      ids = result.map(&:order_unique_id)
      expect(ids).to include(today_order.order_unique_id)
      expect(ids).not_to include(future_order.order_unique_id)
    end

    it "returns all orders when both dates are empty" do
      order = add_test_order_to_db
      result = Order.get_date_range(Order.dataset, "", "")
      expect(result.map(&:order_unique_id)).to include(order.order_unique_id)
    end
  end

  describe ".get_todays_orders" do
    it "returns orders placed today" do
      today_order = add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "REF001")
      result = Order.get_todays_orders(Order.dataset)
      expect(result.map(&:order_unique_id)).to include(today_order.order_unique_id)
    end

    it "excludes orders placed on a previous day" do
      yesterday_order = add_test_order_to_db(1, Time.now.utc - SECONDS_IN_DAY, 7.3, 7.7, 1, "REF001")
      result = Order.get_todays_orders(Order.dataset)
      expect(result.map(&:order_unique_id)).not_to include(yesterday_order.order_unique_id)
    end
  end

  describe "#generate_order_id" do
    it "returns a positive integer" do
      order = add_test_order_to_db
      expect(order.generate_order_id).to be_a(Integer).and be > 0
    end
  end

  describe "#apply_free_drink" do
    before do
      @customer = add_test_customer_to_db
      country = add_test_country_to_db
      roast   = add_test_roast_level_to_db
      @drink_product = add_test_product_to_db("drinks", "Espresso", nil, 1, country.id, roast.id)
      @size_free     = add_test_size_to_db("medium")
      @milk_free     = add_test_milk_option_to_db("oat")
      add_test_product_variant_to_db(@drink_product.product_id, @size_free.id, @milk_free.id, 4.0, 2.5)
      @order_free = add_test_order_to_db(@customer.loyalty_number, Time.now.utc, 2.5, 12.0, 1, "REF_FREE", "Online", 0, "Completed", "Paid", "", 12.0)
      add_test_item_in_order_to_db(@drink_product.product_id, @order_free.order_unique_id, 4.0, 1, @size_free.id, @milk_free.id)
    end

    it "deducts the cheapest drink price when the customer has 9 stamps" do
      @customer.update(stamps: 9)
      @order_free.apply_free_drink(@customer.loyalty_number)
      expect(Order.first(order_unique_id: @order_free.order_unique_id).price).to eq(8.0)
    end

    it "does not modify the price when the customer is not eligible" do
      @order_free.apply_free_drink(@customer.loyalty_number)
      expect(Order.first(order_unique_id: @order_free.order_unique_id).price).to eq(12.0)
    end
  end

  describe "#apply_discount_code" do
    before do
      @customer  = add_test_customer_to_db
      @order_disc = add_test_order_to_db(@customer.loyalty_number, Time.now.utc, 2.0, 10.0, 1, "REF_DISC")
      code = DiscountCode.new
      code.discount_code = "SAVE10"
      code.percentage_off = 10
      code.save_changes
      DiscountRedemption.new_record(@customer.loyalty_number, "SAVE10")
    end

    it "reduces the price by the discount percentage" do
      @order_disc.apply_discount_code(@customer.loyalty_number, "SAVE10")
      expect(Order.first(order_unique_id: @order_disc.order_unique_id).price).to be_within(0.01).of(9.0)
    end

    it "sets discount_code_used on the order" do
      @order_disc.apply_discount_code(@customer.loyalty_number, "SAVE10")
      expect(Order.first(order_unique_id: @order_disc.order_unique_id).discount_code_used).to eq("SAVE10")
    end

    it "marks the code as redeemed" do
      @order_disc.apply_discount_code(@customer.loyalty_number, "SAVE10")
      expect(DiscountRedemption.customer_has_code_unredeemed?(@customer.loyalty_number, "SAVE10")).to be false
    end

    it "does nothing when the code is not assigned to the customer" do
      @order_disc.apply_discount_code(@customer.loyalty_number, "NOTEXIST")
      expect(Order.first(order_unique_id: @order_disc.order_unique_id).price).to eq(10.0)
    end
  end

  describe ".order_full_basket" do
    before { @customer = add_test_customer_to_db }

    it "returns -1 when the basket is empty" do
      expect(Order.order_full_basket(@customer.loyalty_number, false, "")).to eq(-1)
    end

    context "with a drink in the basket" do
      before do
        country = add_test_country_to_db
        roast   = add_test_roast_level_to_db
        @drink_product = add_test_product_to_db("drinks", "Cappuccino", nil, 1, country.id, roast.id)
        @size_basket   = add_test_size_to_db("small")
        @milk_basket   = add_test_milk_option_to_db("oat")
        add_test_product_variant_to_db(@drink_product.product_id, @size_basket.id, @milk_basket.id, 3.5, 2.0)
        add_test_basket_item_to_db(@customer.loyalty_number, @drink_product.product_id, 1, @milk_basket.id, @size_basket.id)
      end

      it "creates the order and returns a positive integer order id" do
        result = Order.order_full_basket(@customer.loyalty_number, false, "")
        expect(result).to be_a(Integer).and be > 0
      end

      it "creates the order with delivered=nil when delivery is false" do
        order_id = Order.order_full_basket(@customer.loyalty_number, false, "")
        expect(Order.get_order(order_id).delivered).to be_nil
      end

      it "creates the order with delivered=0 when delivery is true" do
        order_id = Order.order_full_basket(@customer.loyalty_number, true, "")
        expect(Order.get_order(order_id).delivered).to eq(0)
      end
    end

    context "with a bean item that exceeds stock" do
      before do
        country = add_test_country_to_db
        roast   = add_test_roast_level_to_db
        @bean   = add_test_product_to_db("beans", "Rare Beans", 1, 1, country.id, roast.id)
        DB[:sizes].insert(id: 1, size: "standard") unless Size.first(id: 1)
        DB[:milk_options].insert(id: 1, milk: "standard") unless MilkOption.first(id: 1)
        add_test_product_variant_to_db(@bean.product_id, 1, 1, 5.0, 3.0)
        add_test_basket_item_to_db(@customer.loyalty_number, @bean.product_id, 5, 1, 1)
      end

      it "raises a RuntimeError" do
        expect {
          Order.order_full_basket(@customer.loyalty_number, false, "")
        }.to raise_error(RuntimeError, /Only 1 units/)
      end
    end
  end
end
