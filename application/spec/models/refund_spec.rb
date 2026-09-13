RSpec.describe Refund do
  describe "#pending?" do
    it "returns true when status is Pending" do
      refund = add_test_refund_to_db(1, "wrong drink", "Pending")
      expect(refund.pending?).to be true
    end

    it "returns false when status is not Pending" do
      refund = add_test_refund_to_db(1, "wrong drink", "Resolved")
      expect(refund.pending?).to be false
    end
  end

  describe "#resolved?" do
    it "returns true when status is Resolved" do
      refund = add_test_refund_to_db(1, "cold coffee", "Resolved")
      expect(refund.resolved?).to be true
    end

    it "returns false when status is not Resolved" do
      refund = add_test_refund_to_db(1, "cold coffee", "Pending")
      expect(refund.resolved?).to be false
    end
  end

  describe "#get_order_id" do
    it "returns the order id when present" do
      order = add_test_order_to_db
      refund = add_test_refund_to_db(1, "wrong drink", "Pending")
      refund.order_id = order.order_unique_id
      refund.save_changes
      expect(refund.get_order_id).to eq(order.order_unique_id)
    end

    it "returns N/A when no order id" do
      refund = add_test_refund_to_db(1, "wrong drink", "Pending")
      expect(refund.get_order_id).to eq("N/A")
    end
  end

  describe "#get_order" do
    it "returns the order when order_id matches an existing order" do
      order = add_test_order_to_db
      refund = add_test_refund_to_db(1, "wrong drink", "Pending")
      refund.order_id = order.order_unique_id
      refund.save_changes
      expect(refund.get_order).to eq(order)
    end

    it "returns nil when no order matches the order_id" do
      refund = add_test_refund_to_db(1, "wrong drink", "Pending")
      expect(refund.get_order).to be_nil
    end
  end

  describe "#get_item_id" do
    it "returns N/A when no item id" do
      refund = add_test_refund_to_db(1, "wrong size", "Pending")
      expect(refund.get_item_id).to eq("N/A")
    end
  end

  describe "#get_customer_name" do
    it "returns the full name when customer exists" do
      add_test_customer_to_db(1, "Manny", "Belkacem")
      refund = add_test_refund_to_db(1, "cold drink", "Pending")
      expect(refund.get_customer_name).to eq("Manny Belkacem")
    end

    it "returns Unknown when customer does not exist" do
      refund = add_test_refund_to_db(999, "cold drink", "Pending")
      expect(refund.get_customer_name).to eq("Unknown")
    end
  end
end