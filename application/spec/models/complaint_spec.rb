RSpec.describe Complaint do
  describe "#pending?" do
    it "returns true when status is Pending" do
      complaint = add_test_complaint_to_db(1, "rude staff", "Pending")
      expect(complaint.pending?).to be true
    end

    it "returns false when status is not Pending" do
      complaint = add_test_complaint_to_db(1, "rude staff", "Resolved")
      expect(complaint.pending?).to be false
    end
  end

  describe "#resolved?" do
    it "returns true when status is Resolved" do
      complaint = add_test_complaint_to_db(1, "slow service", "Resolved")
      expect(complaint.resolved?).to be true
    end

    it "returns false when status is not Resolved" do
      complaint = add_test_complaint_to_db(1, "slow service", "Pending")
      expect(complaint.resolved?).to be false
    end
  end

  describe "#get_customer_name" do
    it "returns the full name when customer exists" do
      add_test_customer_to_db(1, "Manny", "Belkacem")
      complaint = add_test_complaint_to_db(1, "dirty table", "Pending")
      expect(complaint.get_customer_name).to eq("Manny Belkacem")
    end

    it "returns Unknown when customer does not exist" do
      complaint = add_test_complaint_to_db(999, "dirty table", "Pending")
      expect(complaint.get_customer_name).to eq("Unknown")
    end
  end
end