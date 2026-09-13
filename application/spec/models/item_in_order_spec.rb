RSpec.describe ItemInOrder do
  describe ".get_most_frequently_bought_items" do
    before do
      add_test_size_to_db
      add_test_milk_option_to_db
      add_test_country_to_db
      add_test_roast_level_to_db

      1.upto(6) do |i|
        add_test_product_to_db
        add_test_product_variant_to_db(i, 1, 1)
      end

      add_test_order_to_db(1)
    end

    it "returns only a specific customer's top items" do
      add_test_order_to_db(2)
      add_test_item_in_order_to_db(1, 1, 3.7, 5)
      add_test_item_in_order_to_db(2, 2, 3.7, 10)

      items = ItemInOrder.get_most_frequently_bought_items(1)
      expect(items.length).to eq(1)
      expect(items[0][1]).to eq(5)
    end

    it "returns a maximum of 5 items" do
      1.upto(6) do |i|
        add_test_item_in_order_to_db(i, 1)
      end

      expect(ItemInOrder.get_most_frequently_bought_items(1).length).to eq(5)
    end

    it "returns the items in descending order of frequency" do
      add_test_item_in_order_to_db(1, 1, 3.7, 5)
      add_test_item_in_order_to_db(2, 1, 3.7, 10)
      add_test_item_in_order_to_db(3, 1, 3.7, 1)

      items = ItemInOrder.get_most_frequently_bought_items(1)

      expect(items[0][1]).to eq(10)
      expect(items[1][1]).to eq(5)
      expect(items[2][1]).to eq(1)
    end
  end

  context "with basic test data" do
    before do
      @size    = add_test_size_to_db("standard")
      add_test_milk_option_to_db("N/A")
      @milk    = add_test_milk_option_to_db("whole")
      @country = add_test_country_to_db("Ethiopia")
      @roast   = add_test_roast_level_to_db("medium")
      @drink   = add_test_product_to_db("drinks", "Latte", nil, 1, @country.id, @roast.id)
      @bean    = add_test_product_to_db("beans", "Arabic Beans", 50, 1, @country.id, @roast.id)
      add_test_product_variant_to_db(@drink.product_id, @size.id, @milk.id, 3.7, 2.7)
      add_test_product_variant_to_db(@bean.product_id, @size.id, 1, 22.99, 15.33)
      @order = add_test_order_to_db(1)
      @item  = add_test_item_in_order_to_db(@drink.product_id, @order.order_unique_id, 3.7, 2, @size.id, @milk.id)
    end

    describe ".get_all_items_in_order" do
      it "returns items belonging to the given order" do
        expect(ItemInOrder.get_all_items_in_order(@order.order_unique_id).count).to eq(1)
      end

      it "returns an empty dataset for an order with no items" do
        order2 = add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 2, "XYZ99999")
        expect(ItemInOrder.get_all_items_in_order(order2.order_unique_id).count).to eq(0)
      end
    end

    describe ".get_item" do
      it "returns the item when it exists" do
        expect(ItemInOrder.get_item(@item.item_in_order_id)).not_to be_nil
      end

      it "returns nil when the item does not exist" do
        expect(ItemInOrder.get_item(-1)).to be_nil
      end
    end

    describe ".all_refunded?" do
      it "returns false when an item has refunded set to 0" do
        @item.update(refunded: 0)
        expect(ItemInOrder.all_refunded?(@order.order_unique_id)).to be false
      end

      it "returns true when all items are marked as refunded" do
        @item.update(refunded: 1)
        expect(ItemInOrder.all_refunded?(@order.order_unique_id)).to be true
      end

      it "returns true when there are no items for the order" do
        order2 = add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 2, "XYZ99999")
        expect(ItemInOrder.all_refunded?(order2.order_unique_id)).to be true
      end
    end

    describe ".remove" do
      it "returns false when amount is 0" do
        expect(ItemInOrder.remove(@item.item_in_order_id, 0)).to be false
      end

      it "returns false when amount is negative" do
        expect(ItemInOrder.remove(@item.item_in_order_id, -1)).to be false
      end

      it "returns false when the item does not exist" do
        expect(ItemInOrder.remove(-1, 1)).to be false
      end

      it "deletes the item and returns true when the amount exceeds the current quantity" do
        result = ItemInOrder.remove(@item.item_in_order_id, 5)
        expect(result).to be true
        expect(ItemInOrder.get_item(@item.item_in_order_id)).to be_nil
      end

      it "decrements the quantity and returns false when amount is less than the current quantity" do
        result = ItemInOrder.remove(@item.item_in_order_id, 1)
        expect(result).to be false
        expect(ItemInOrder.get_item(@item.item_in_order_id).quantity).to eq(1)
      end
    end

    describe ".add_drink_to_order" do
      it "creates a new item in order when the item does not already exist" do
        new_order = add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 2, "XYZ99999")
        ItemInOrder.add_drink_to_order(new_order.order_unique_id, @drink.product_id, 2, @milk.id, @size.id)
        item = ItemInOrder.first(order_unique_id: new_order.order_unique_id, item_id: @drink.product_id)
        expect(item).not_to be_nil
        expect(item.quantity).to eq(2)
      end

      it "increments the quantity when the item already exists in the order" do
        ItemInOrder.add_drink_to_order(@order.order_unique_id, @drink.product_id, 3, @milk.id, @size.id)
        item = ItemInOrder.first(
          order_unique_id: @order.order_unique_id,
          item_id: @drink.product_id,
          milk_id: @milk.id,
          size_id: @size.id
        )
        expect(item.quantity).to eq(5)
      end
    end

    describe ".add_beans_to_order" do
      it "creates a new bean item in order when it does not already exist" do
        ItemInOrder.add_beans_to_order(@order.order_unique_id, @bean.product_id, 2)
        item = ItemInOrder.first(order_unique_id: @order.order_unique_id, item_id: @bean.product_id)
        expect(item).not_to be_nil
        expect(item.quantity).to eq(2)
      end

      it "increments the quantity when the bean item already exists" do
        add_test_item_in_order_to_db(@bean.product_id, @order.order_unique_id, 22.99, 1, @size.id, 1)
        ItemInOrder.add_beans_to_order(@order.order_unique_id, @bean.product_id, 2)
        item = ItemInOrder.first(order_unique_id: @order.order_unique_id, item_id: @bean.product_id)
        expect(item.quantity).to eq(3)
      end
    end

    describe ".add_bean_to_order" do
      it "creates an item in order for the given bean with the correct quantity" do
        ItemInOrder.add_bean_to_order(@order.order_unique_id, @bean.product_id, 3)
        item = ItemInOrder.first(order_unique_id: @order.order_unique_id, item_id: @bean.product_id)
        expect(item).not_to be_nil
        expect(item.quantity).to eq(3)
      end
    end

    describe "#get_name" do
      it "returns the name of the product" do
        expect(@item.get_name).to eq("Latte")
      end
    end

    describe "#get_product_id" do
      it "returns the product id" do
        expect(@item.get_product_id).to eq(@drink.product_id)
      end
    end

    describe "#get_cost_for_one" do
      it "returns the cost of one unit from the product variant" do
        expect(@item.get_cost_for_one).to be_within(0.01).of(2.7)
      end
    end

    describe "#get_roast_level" do
      it "returns the roast level of the product" do
        bean_item = add_test_item_in_order_to_db(@bean.product_id, @order.order_unique_id, 22.99, 1, @size.id, 1)
        expect(bean_item.get_roast_level).not_to be_nil
      end
    end

    describe "#get_milk_name" do
      it "returns the milk name for the item" do
        expect(@item.get_milk_name).to eq("whole")
      end
    end

    describe "#get_size_id" do
      it "returns the size id" do
        expect(@item.get_size_id).to eq(@size.id)
      end
    end

    describe "#get_size_text" do
      it "returns the size text" do
        expect(@item.get_size_text).to eq("standard")
      end
    end

    describe "#get_origin" do
      it "returns the origin of the product" do
        bean_item = add_test_item_in_order_to_db(@bean.product_id, @order.order_unique_id, 22.99, 1, @size.id, 1)
        expect(bean_item.get_origin).not_to be_nil
      end
    end

    describe "#get_refund_status" do
      it "returns 'Not Refunded' when refunded is 0" do
        @item.update(refunded: 0)
        expect(@item.get_refund_status).to eq("Not Refunded")
      end

      it "returns 'Refunded' when refunded is 1" do
        @item.update(refunded: 1)
        expect(@item.get_refund_status).to eq("Refunded")
      end

      it "returns 'N/A' when refunded is nil" do
        @item.update(refunded: nil)
        expect(@item.get_refund_status).to eq("N/A")
      end
    end

    describe "#get_product_entry" do
      it "returns the associated product record" do
        expect(@item.get_product_entry.product_id).to eq(@drink.product_id)
      end
    end

    describe "#is_bean?" do
      it "returns false for a drink item" do
        expect(@item.is_bean?).to be false
      end

      it "returns true for a bean item" do
        bean_item = add_test_item_in_order_to_db(@bean.product_id, @order.order_unique_id, 22.99, 1, @size.id, 1)
        expect(bean_item.is_bean?).to be true
      end
    end

    describe "#is_drink?" do
      it "returns true for a drink item" do
        expect(@item.is_drink?).to be true
      end

      it "returns false for a bean item" do
        bean_item = add_test_item_in_order_to_db(@bean.product_id, @order.order_unique_id, 22.99, 1, @size.id, 1)
        expect(bean_item.is_drink?).to be false
      end
    end

    describe "#has_milk?" do
      it "returns true for a drink item" do
        expect(@item.has_milk?).to be true
      end

      it "returns false for a bean item" do
        bean_item = add_test_item_in_order_to_db(@bean.product_id, @order.order_unique_id, 22.99, 1, @size.id, 1)
        expect(bean_item.has_milk?).to be false
      end
    end

    describe "#refund" do
      it "marks the item as refunded when quantity is 1" do
        item = add_test_item_in_order_to_db(@drink.product_id, @order.order_unique_id, 3.7, 1, @size.id, @milk.id)
        item.update(refunded: 0)
        item.refund
        expect(ItemInOrder.first(item_in_order_id: item.item_in_order_id).refunded).to eq(1)
      end

      it "creates a refunded copy and decrements the quantity when quantity > 1" do
        @item.update(refunded: 0)
        @item.refund
        expect(ItemInOrder.first(item_in_order_id: @item.item_in_order_id).quantity).to eq(1)
        expect(
          ItemInOrder.where(order_unique_id: @order.order_unique_id, item_id: @drink.product_id, refunded: 1).count
        ).to eq(1)
      end

      it "increments the existing refunded entry when one already exists and quantity > 1" do
        existing = add_test_item_in_order_to_db(@drink.product_id, @order.order_unique_id, 3.7, 1, @size.id, @milk.id)
        existing.update(refunded: 1)
        @item.update(refunded: 0)
        @item.refund
        expect(ItemInOrder.first(item_in_order_id: existing.item_in_order_id).quantity).to eq(2)
        expect(ItemInOrder.first(item_in_order_id: @item.item_in_order_id).quantity).to eq(1)
      end

      it "merges into the original item when quantity is 1 and a refunded entry already exists" do
        item = add_test_item_in_order_to_db(@drink.product_id, @order.order_unique_id, 3.7, 1, @size.id, @milk.id)
        item.update(refunded: 0)
        existing = add_test_item_in_order_to_db(@drink.product_id, @order.order_unique_id, 3.7, 1, @size.id, @milk.id)
        existing.update(refunded: 1)
        item.refund
        refreshed = ItemInOrder.first(item_in_order_id: item.item_in_order_id)
        expect(refreshed.refunded).to eq(1)
        expect(refreshed.quantity).to eq(2)
        expect(ItemInOrder.first(item_in_order_id: existing.item_in_order_id)).to be_nil
      end
    end

    describe "#redemption_check" do
      it "returns false when there is no redemption for the order" do
        expect(@item.redemption_check(@order.order_unique_id)).to be false
      end

      it "returns true when the redemption matches this item" do
        redemption = add_test_free_coffee_redemption_to_db(1, "", @drink.product_id, @size.id, @milk.id)
        redemption.update(order_unique_id: @order.order_unique_id, item_in_order_id: @item.item_in_order_id)
        expect(@item.redemption_check(@order.order_unique_id)).to be true
      end
    end
  end
end
