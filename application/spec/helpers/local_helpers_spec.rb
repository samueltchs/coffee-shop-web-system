RSpec.describe LocalHelpers do
  include described_class
  include Conversions
  include CustomerHelpers

  describe "#generate_reference_id" do
    it "returns a string" do
      expect(generate_reference_id).to be_instance_of(String)
    end

    it "starts with three capital letters" do
      reference_id = generate_reference_id

      reference_id[0..2].each_char do |char|
        expect(char.between?("A", "Z")).to be true
      end
    end

    it "contains 5-9 digits after the letters" do
      reference_id = generate_reference_id
      digits = reference_id[3..]

      digits.each_char do |char|
        expect(char.between?("0", "9")).to be true
      end

      expect(digits.length).to be_between(5, 9).inclusive
    end

    it "is between 8 and 12 characters long" do
      expect(generate_reference_id.length).to be_between(8, 12).inclusive
    end
  end

  describe "#generate_unique_reference_id" do
    it "returns a string" do
      expect(generate_unique_reference_id).to be_instance_of(String)
    end

    it "returns a unique reference id" do
      expect(Order.first(reference_id: generate_unique_reference_id)).to be_nil
    end
  end

  describe "#verify_reference_id" do
    context "when reference id is valid" do
      it "returns true" do
        expect(verify_reference_id("ABC12345")).to be true
      end
    end

    context "when reference id is invalid" do
      it "returns false" do
        expect(verify_reference_id("AbC12a45")).to be false
      end
    end
  end

  describe "#title_of_user_page" do
    context "when the user exists" do
      it "returns the user's name along with page name" do
        employee = add_test_barista_to_db("barista", "George", "Michael")
        result = title_of_user_page(employee, "Employee Admin View")
        expect(result).to eq("George Michael - Employee Admin View")
      end
    end

    context "when user does not exist" do
      it "returns only the page name" do
        result = title_of_user_page(nil, "Employee Admin View")
        expect(result).to eq("Employee Admin View")
      end
    end
  end

  describe "#title_of_order_page" do
    context "when the order exists" do
      it "returns the order's id along with page name" do
        order = add_test_order_to_db
        result = title_of_order_page(order)
        expect(result).to eq("#{order.order_unique_id} - Order Admin View")
      end
    end

    context "when order does not exist" do
      it "returns only the page name" do
        expect(title_of_order_page(nil)).to eq("Order - Admin View")
      end
    end
  end

  describe "#products_of_an_order" do
    context "when order is nil" do
      it "returns an empty array" do
        expect(products_of_an_order(nil)).to eq([])
      end
    end

    context "when order has no items" do
      it "returns an empty array" do
        order = add_test_order_to_db
        expect(products_of_an_order(order)).to eq([])
      end
    end

    context "when the order has items" do
      it "returns a 6-d array of the items in the order" do
        order = add_test_order_to_db
        add_test_country_to_db
        add_test_roast_level_to_db
        add_test_product_to_db("Coffee", "Latte", 10, 1, 1, 1, "", "/images/product_images/1.JPG")
        add_test_size_to_db
        add_test_milk_option_to_db
        add_test_product_variant_to_db
        add_test_item_in_order_to_db(1, order.order_unique_id, 3.7, 3, 1, 1)

        result = products_of_an_order(order)
        expect(result.length).to eq(1)
        expect(result).to eq([["Latte", 3.7, 3, "/images/product_images/1.JPG", 1, 1]])
      end
    end
  end

  describe "#format_count" do
    context "when count is 1" do
      it "returns the singular form of a word" do
        expect(format_count(1, "order")).to eq("1 order")
      end
    end

    context "when count is not 1" do
      it "returns the plural form of a word" do
        expect(format_count(2, "order")).to eq("2 orders")
      end
    end
  end

  describe "#format_month" do
    context "when the month is nil" do
      it "returns nil" do
        expect(format_month(nil)).to be_nil
      end
    end

    context "when the month is valid" do
      it "returns the month and year" do
        expect(format_month("2026-12")).to eq("December 2026")
      end
    end
  end

  describe "#format_time" do
    context "when the time is nil" do
      it "returns nil" do
        expect(format_time(nil)).to be_nil
      end
    end

    context "when the time is valid" do
      it "returns the time formatted correctly" do
        result = format_time(Time.now.utc)
        expect(result).to match(/\A\d{2}\/\d{2}\/\d{4} \d{2}:\d{2}\z/)
      end
    end
  end

  describe "#format_date" do
    context "when time is nil" do
      it "returns nil" do
        expect(format_date(nil)).to be_nil
      end
    end

    context "when the time is valid" do
      it "returns the date formatted correctly" do
        result = format_date(Time.now.utc)
        expect(result).to match(/\A\d{2}\/\d{2}\/\d{4}\z/)
      end
    end
  end

  describe "#format_price" do
    context "when the price is nil" do
      it "returns N/A" do
        expect(format_price(nil)).to eq("N/A")
      end
    end

    context "when price is N/A" do
      it "returns N/A" do
        expect(format_price("N/A")).to eq("N/A")
      end
    end

    context "when the price is valid" do
      it "returns the price with currency to 2 decimal places" do
        expect(format_price(7.7)).to eq("£7.70")
      end
    end
  end

  describe "#format_total" do
    context "when the price is nil" do
      it "returns N/A" do
        expect(format_total(nil, 2)).to eq("N/A")
      end
    end

    context "when quantity is nil" do
      it "returns N/A" do
        expect(format_total(7.7, nil)).to eq("N/A")
      end
    end

    context "when both the price and quantity are valid" do
      it "returns the total with currency to 2 decimal places" do
        expect(format_total(7.7, 2)).to eq("£15.40")
      end
    end
  end

  describe "#admin_inbox_messages" do
    context "when no flagged or suspended customers exist" do
      it "returns an empty array" do
        add_test_customer_to_db
        add_deleted_customer_to_db
        expect(admin_inbox_messages).to eq([])
      end
    end

    context "when a flagged customer exists" do
      it "adds a message" do
        add_flagged_customer_to_db
        expect(admin_inbox_messages.length).to eq(1)
      end
    end

    context "when a suspended due to inactivity customer past 3 months exists" do
      it "adds a message" do
        add_suspended_customer_to_db(
          1, Time.now.utc - SECONDS_IN_DAY * 95, Time.now.utc - SECONDS_IN_MONTH * 3
        )
        expect(admin_inbox_messages.length).to eq(1)
      end
    end

    context "when multiple messages exist" do
      it "returns the messages sorted by the most recent one 1st" do
        add_flagged_customer_to_db(1, Time.now.utc - SECONDS_IN_DAY * 2)
        add_flagged_customer_to_db(2, Time.now.utc)
        messages = admin_inbox_messages
        expect(messages[0][2]).to eq(2)
        expect(messages[1][2]).to eq(1)
      end
    end
  end

  describe "#add_flagged_message" do
    context "when customer is not flagged" do
      it "does not add a message" do
        customer = add_test_customer_to_db
        messages = []
        add_flagged_message(customer, customer.loyalty_number, messages)
        expect(messages).to eq([])
      end
    end

    context "when customer is flagged but flagged_at is nil" do
      it "does not add a message" do
        flagged_customer = add_flagged_customer_to_db(1, nil)
        messages = []
        add_flagged_message(flagged_customer, 1, messages)
        expect(messages).to eq([])
      end
    end

    context "when customer is flagged with a set flagged_at time" do
      it "adds a message" do
        flagged_customer = add_flagged_customer_to_db
        messages = []
        add_flagged_message(flagged_customer, flagged_customer.loyalty_number, messages)
        expect(messages.length).to eq(1)
        expect(messages[0][0]).to eq(Time.parse(flagged_customer.flagged_at))
        expect(messages[0][1]).to eq("has been flagged as 6 months inactive. Suspend option now available.")
        expect(messages[0][2]).to eq(flagged_customer.loyalty_number)
      end
    end
  end

  describe "#add_suspended_message" do
    context "when customer is not suspended" do
      it "does not add a message" do
        customer = add_test_customer_to_db
        messages = []
        add_suspended_message(customer, customer.loyalty_number, messages)
        expect(messages).to eq([])
      end
    end

    context "when customer is suspended for less than 3 months" do
      it "does not add a message" do
        suspended_cust = add_suspended_customer_to_db
        messages = []
        add_suspended_message(suspended_cust, suspended_cust.loyalty_number, messages)
        expect(messages).to eq([])
      end
    end

    context "when customer is suspended for disciplinary reasons" do
      it "does not add a message" do
        suspended_cust = add_suspended_customer_to_db(
          1, Time.now.utc - SECONDS_IN_DAY * 95, Time.now.utc - SECONDS_IN_MONTH * 3, 2
        )
        messages = []
        add_suspended_message(suspended_cust, suspended_cust.loyalty_number, messages)
        expect(messages).to eq([])
      end
    end

    context "when customer is suspended with a set suspended_at time" do
      it "adds a message" do
        suspended_cust = add_suspended_customer_to_db(
          1, Time.now.utc - SECONDS_IN_DAY * 95, Time.now.utc - SECONDS_IN_MONTH * 3
        )
        messages = []
        add_suspended_message(suspended_cust, suspended_cust.loyalty_number, messages)
        expect(messages.length).to eq(1)
        expect(messages[0][0]).to eq(Time.parse(suspended_cust.suspended_at) + SECONDS_IN_MONTH * 3)
        expect(messages[0][1]).to eq(
          "has not returned within 3 months of their suspension. Delete option now available."
        )
        expect(messages[0][2]).to eq(suspended_cust.loyalty_number)
      end
    end
  end

  describe "#size_abbreviation" do
    context "when size is nil" do
      it "returns an empty string" do
        expect(size_abbreviation(nil)).to eq("")
      end
    end

    context "when size is empty" do
      it "returns an empty string" do
        expect(size_abbreviation("")).to eq("")
      end
    end

    context "when size is N/A" do
      it "returns an empty string" do
        expect(size_abbreviation("N/A")).to eq("")
      end
    end

    context "when the size is valid" do
      it "returns within parentheses the 1st letter of the size in uppercase" do
        expect(size_abbreviation("small")).to eq("(S)")
      end
    end
  end
end
