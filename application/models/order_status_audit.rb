class OrderStatusAudit < Sequel::Model
  include Validation
  
  def validate
    super
    errors.add("reason_note", "A reason note is required.") if !reason_note || reason_note.strip.empty?
  end

  def self.create_audit_note(order_id, old_status, new_status, reason_note, changed_by)
    audit_note = OrderStatusAudit.new

    audit_note.order_unique_id = order_id
    audit_note.old_status = old_status
    audit_note.new_status = new_status
    audit_note.reason_note = reason_note
    audit_note.changed_by = changed_by
    audit_note.changed_at = Time.now.utc

    audit_note
  end
end
