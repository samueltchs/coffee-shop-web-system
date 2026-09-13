RSpec.describe Analytics do
  include described_class
  include CustomerHelpers

  describe "#get_monthly_orders" do
    context "when no orders exist" do
      it "returns an empty array" do
        expect(get_monthly_orders).to eq([])
      end
    end

    context "when orders exist only in 1 month" do
      it "returns an empty array" do
        add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC12345")
        add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC12344")
        expect(get_monthly_orders).to eq([])
      end
    end

    context "when orders exist across multiple months" do
      it "returns the monthly change in orders in reverse chronological order" do
        add_test_order_to_db(1, Time.now.utc - SECONDS_IN_MONTH * 2, 7.3, 7.7, 1, "ABC12344")
        add_test_order_to_db(1, Time.now.utc - SECONDS_IN_MONTH, 7.3, 7.7, 1, "ABC12345")
        add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC123456")
        add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC1234567")
        current_month = Time.now.utc.to_s[0, 7]
        previous_month = (Time.now.utc - SECONDS_IN_MONTH).to_s[0, 7]
        result = get_monthly_orders
        expect(result.length).to eq(2)
        expect(result[0]).to eq([current_month, 2, 1])
        expect(result[1]).to eq([previous_month, 1, 0])
      end
    end

    context "when more than 6 months of data exists" do
      it "only returns the monthly changes in the last 6 months" do
        0.upto(7) do |i|
          add_test_order_to_db(1, Time.now.utc - SECONDS_IN_MONTH * i, 7.3, 7.7, 1, "ABC1234#{i}")
        end

        expect(get_monthly_orders.length).to eq(6)
      end
    end
  end

  describe "#get_monthly_signups" do
    context "when no customers exist" do
      it "returns an empty array" do
        expect(get_monthly_signups).to eq([])
      end
    end

    context "when customers exist only in 1 month" do
      it "returns an empty array" do
        add_test_customer_to_db(
          1, "Mikel", "Merino", "addr1", "addr2", "Shef", "S1 1AA", "7710002000", "email@gmail.com", 0, Time.now.utc
        )
        add_test_customer_to_db(
          2, "Mikel", "Arteta", "addr1", "addr2", "Shef", "S1 1AA", "7710002001", "mail@gmail.com", 0, Time.now.utc
        )
        expect(get_monthly_signups).to eq([])
      end
    end

    context "when customers exist across multiple months" do
      it "returns the monthly change in signups in reverse chronological order" do
        add_test_customer_to_db(
          1, "Alex", "Nate", "addr1", "addr2", "Shef", "S1 1AA", "7710002004", "mail@mail.com", 0, Time.now.utc - SECONDS_IN_MONTH * 2
        )
        add_test_customer_to_db(
          2, "Alex", "Nate", "addr1", "addr2", "Shef", "S1 1AA", "7710002003", "gmail@gmail.com", 0, Time.now.utc - SECONDS_IN_MONTH
        )
        add_test_customer_to_db(
          3, "Alex", "Nate", "addr1", "addr2", "Shef", "S1 1AA", "7710002001", "email@mail.com", 0, Time.now.utc
        )
        add_test_customer_to_db(
          4, "Alex", "Nate", "addr1", "addr2", "Shef", "S1 1AA", "7710002002", "email@email.com", 0, Time.now.utc
        )
        current_month = Time.now.utc.to_s[0, 7]
        previous_month = (Time.now.utc - SECONDS_IN_MONTH).to_s[0, 7]

        result = get_monthly_signups
        expect(result.length).to eq(2)
        expect(result[0]).to eq([current_month, 2, 1])
        expect(result[1]).to eq([previous_month, 1, 0])
      end
    end

    context "when more than 6 months of data exists" do
      it "only returns the monthly changes in the last 6 months" do
        0.upto(7) do |i|
          add_test_customer_to_db(
            i, "Mikel", "Pat", "addr1", "addr2", "Shef", "S1 1AA",
            "771000200#{i}", "mail#{i}@gmail.com", 0, Time.now.utc - SECONDS_IN_MONTH * i
          )
        end

        expect(get_monthly_signups.length).to eq(6)
      end
    end
  end

  describe "#time_spent_per_week" do
    context "when customer has less than 2 times recorded" do
      it "returns an empty array" do
        customer = add_test_customer_to_db(1)
        add_test_login_time_to_db(1, Time.now.utc)
        expect(time_spent_per_week(customer)).to eq([])
      end
    end

    context "when the customer's registered time is nil" do
      it "returns an empty array" do
        customer = add_test_customer_to_db(
          1, "Mikel", "Merino", "addr1", "addr2", "Shef", "S1 1AA", "7710002000", "email@mail.com", 0, nil
        )
        add_test_login_time_to_db(1)
        add_test_profile_update_to_db(1)
        expect(time_spent_per_week(customer)).to eq([])
      end
    end

    context "when customer has at least 2 times recorded" do
      it "returns an array of weekly timeframes with the time spent" do
        customer = add_test_customer_to_db(
          1, "Mikel", "Merino", "addr1", "addr2", "Shef", "S1 1AA", "7710002000", "email@mail.com", 0, Time.now.utc - SECONDS_IN_DAY
        )
        add_test_login_time_to_db(1, Time.now.utc - 300)
        add_test_recent_view_to_db(1, 1, Time.now.utc)
        result = time_spent_per_week(customer)
        expect(result[0].length).to eq(2)
        expect(result[0][0]).to match(/\A\d{4}-\d{2}\-\d{2} - \d{4}-\d{2}-\d{2}\z/)
        expect(result[0][1]).to eq("0h 10m")
      end
    end

    context "when customer registered less than 10 weeks ago" do
      it "returns only the weeks since registration" do
        customer = add_test_customer_to_db(
          1, "Mikel", "Merino", "addr1", "addr2", "Shef", "S1 1AA", "7710002000", "email@mail.com", 0, Time.now.utc - SECONDS_IN_DAY * 5
        )
        add_test_login_time_to_db(1, Time.now.utc - SECONDS_IN_DAY)
        add_test_recent_view_to_db(1, 1, Time.now.utc)
        result = time_spent_per_week(customer)
        expect(result.length).to eq(1)
      end
    end

    context "when customer has been registered at least 10 weeks" do
      it "returns only the last 10 weeks" do
        customer = add_test_customer_to_db(
          1, "Mikel", "Merino", "addr1", "addr2", "Shef", "S1 1AA", "7710002000", "email@mail.com", 0, Time.now.utc - SECONDS_IN_DAY * 7 * 15
        )

        0.upto(10) do |i|
          add_test_login_time_to_db(1, Time.now.utc - SECONDS_IN_DAY * 7 * i)
        end

        result = time_spent_per_week(customer)
        expect(result.length).to eq(10)
      end
    end

    context "when there is only 1 time recorded within each week" do
      it "counts 5 minutes for each event" do
        customer = add_test_customer_to_db(
          1, "Mikel", "Merino", "addr1", "addr2", "Shef", "S1 1AA", "7710002000", "mail@mail.com", 0, Time.now.utc - SECONDS_IN_DAY * 14
        )
        add_test_login_time_to_db(1, Time.now.utc - SECONDS_IN_DAY * 12)
        add_test_login_time_to_db(1, Time.now.utc - SECONDS_IN_DAY)
        result = time_spent_per_week(customer)
        expect(result[0][1]).to eq("0h 5m")
        expect(result[1][1]).to eq("0h 5m")
      end
    end

    context "when two times recorded are within 15 minutes of each other" do
      it "counts the actual time between them" do
        customer = add_test_customer_to_db(
          1, "Mikel", "Merino", "addr1", "addr2", "Shef", "S1 1AA", "7710002000", "mail@mail.com", 0, Time.now.utc - SECONDS_IN_DAY
        )
        add_test_login_time_to_db(1, Time.now.utc - 600)
        add_test_login_time_to_db(1, Time.now.utc)
        result = time_spent_per_week(customer)
        expect(result[0][1]).to eq("0h 15m")
      end
    end

    context "when two times recorded are more than 15 minutes apart" do
      it "counts 5 minutes instead of the actual time" do
        customer = add_test_customer_to_db(
          1, "Mikel", "Merino", "addr1", "addr2", "Shef", "S1 1AA", "7710002000", "mail@mail.com", 0, Time.now.utc - SECONDS_IN_DAY
        )
        add_test_login_time_to_db(1, Time.now.utc - 3000)
        add_test_login_time_to_db(1, Time.now.utc)
        result = time_spent_per_week(customer)
        expect(result[0][1]).to eq("0h 10m")
      end
    end
  end

  describe "#top_items_for_habits" do
    before do
      @customer = add_test_customer_to_db(1)
      add_test_size_to_db("large")
      add_test_milk_option_to_db("Whole")
      add_test_country_to_db("Ethiopian")
      add_test_roast_level_to_db("Light")
      add_test_product_to_db("Coffee", "Latte", 10, 1, 1, 1)
      add_test_product_variant_to_db(1, 1, 1, 3.7, 2.7)
      add_test_order_to_db(1)
    end

    context "when customer has no orders" do
      it "returns an empty array" do
        customer = add_test_customer_to_db(2)
        expect(top_items_for_habits(customer)).to eq([])
      end
    end

    context "when customer has orders with known products" do
      it "returns a 5-d array with the correct values" do
        add_test_item_in_order_to_db(1, 1, 3.7, 2, 1 , 1)
        result = top_items_for_habits(@customer)
        expect(result.length).to eq(1)
        expect(result[0]).to eq(["Latte", 1, "large", "Whole", 2])
      end
    end
  end

  describe "#top_items_for_ad" do
    before do
      @customer = add_test_customer_to_db(1)
      add_test_size_to_db
      add_test_milk_option_to_db
      add_test_country_to_db
      add_test_roast_level_to_db
      add_test_product_to_db("Coffee", "Latte", 10, 1, 1, 1, "delicious", "images/latte.jpg")
      add_test_product_variant_to_db(1, 1, 1, 3.7, 2.7)
      add_test_order_to_db(1)
    end

    context "when customer has no orders" do
      it "returns an empty array" do
        customer = add_test_customer_to_db(2)
        expect(top_items_for_ad(customer)).to eq([])
      end
    end

    context "when customer has orders with known products" do
      it "returns a 5-d array with the correct values" do
        add_test_item_in_order_to_db(1, 1, 3.7, 2, 1, 1)
        result = top_items_for_ad(@customer)
        expect(result.length).to eq(1)
        expect(result[0]).to eq(["Latte", "delicious", "images/latte.jpg", 3.7, 1])
      end
    end
  end

  describe "#top_baristas_by_orders" do
    context "when no orders exist" do
      it "returns an empty array" do
        expect(top_baristas_by_orders).to eq([])
      end
    end

    context "when only online orders exist" do
      it "returns an empty array" do
        add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC12345", "Online")
        expect(top_baristas_by_orders).to eq([])
      end
    end

    context "when barista orders exist" do
      it "returns the baristas in descending order of their order count" do
        add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC12345", "barista1")
        add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC12346", "barista1")
        add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC12347", "barista1")
        add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC12348", "barista2")
        add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC12349", "barista2")
        add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC12344", "barista3")
        result = top_baristas_by_orders
        expect(result[0]).to eq(["barista1", 3])
        expect(result[1]).to eq(["barista2", 2])
        expect(result[2]).to eq(["barista3", 1])
      end
    end

    context "when more than 3 baristas have fulfilled orders" do
      it "only returns the top 3 based on order count" do
        add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC12345", "barista1")
        add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC12346", "barista1")
        add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC12347", "barista2")
        add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC12348", "barista2")
        add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC12349", "barista3")
        add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC12343", "barista3")
        add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC12344", "barista4")
        expect(top_baristas_by_orders.length).to eq(3)
      end
    end
  end
end
