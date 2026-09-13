RSpec.describe OrderStatusAudit do
  describe "#validate" do
    it "is invalid if reason note is empty" do
      audit = OrderStatusAudit.new
      audit.reason_note = ""

      expect(audit.valid?).to be false
      expect(audit.errors["reason_note"]).to include("A reason note is required.")
    end

    it "is invalid if reason note is nil" do
      audit = OrderStatusAudit.new
      audit.reason_note = nil

      expect(audit.valid?).to be false
      expect(audit.errors["reason_note"]).to include("A reason note is required.")
    end

    it "is valid if reason note is valid" do
      audit = OrderStatusAudit.new
      audit.reason_note = "Customer has provided sufficient proof."

      expect(audit.valid?).to be true
      expect(audit.errors.empty?).to be true
    end
  end

  describe ".create_audit_note" do
    it "correctly assigns all fields" do
      audit = OrderStatusAudit.create_audit_note(1, "Unpaid", "Paid", "Sufficient proof", "admin")

      expect(audit.order_unique_id).to eq(1)
      expect(audit.old_status).to eq("Unpaid")
      expect(audit.new_status).to eq("Paid")
      expect(audit.reason_note).to eq("Sufficient proof")
      expect(audit.changed_by).to eq("admin")
      expect(audit.changed_at).not_to be_nil
    end
  end
end
