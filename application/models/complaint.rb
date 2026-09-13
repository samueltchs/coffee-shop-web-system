class Complaint < Sequel::Model
  
  def self.get_all_complaints
    return Complaint.all
  end

  def self.get_complaint_by_id(complaint_id)
return Complaint.first(complaint_id: complaint_id)
  end

def self.get_complaints_by_customer(loyalty_no)
    return Complaint.where(loyalty_number: loyalty_no).all
end

  def self.get_date_range(complaints, start_date, end_date)
    unless start_date.nil? || start_date.empty?
      start_normalised = "#{start_date} 00:00:00 UTC"
      complaints = complaints.where { created_at >= start_normalised }
    end
    unless end_date.nil? || end_date.empty?
      end_normalised = "#{end_date} 23:59:59 UTC"
      complaints = complaints.where { created_at <= end_normalised }
    end
    complaints
  end

def pending?
return self.status == "Pending"
end

  def resolved?
    return self.status == "Resolved"
  end

def get_customer
return Customer.first(loyalty_number: self.loyalty_number)
end

  def get_customer_name
    cust = self.get_customer
if cust.nil?
return "Unknown"
else
return "#{cust.first_name} #{cust.last_name}"
end
  end

end