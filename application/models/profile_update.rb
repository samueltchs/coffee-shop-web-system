class ProfileUpdate < Sequel::Model
  # returns a customer's last 10 updates
  def self.get_customer_profile_updates(loyalty_number)
    ProfileUpdate.where(loyalty_number: loyalty_number).reverse_order(:time_updated).limit(10)
  end

  def self.record_new_update(loyalty_number, field_updated, old_value, new_value)
    update = ProfileUpdate.new
    update.loyalty_number = loyalty_number
    update.field_updated = field_updated
    update.old_value = old_value
    update.new_value = new_value
    update.time_updated = Time.now.utc.to_s
    update.save_changes
  end

  def display_field
    field_updated.gsub("_", " ").capitalize
  end

  def display_value(value)
    if field_updated == "password"
      "Private info"
    else
      value
    end
  end

  def self.record_new_password_update(loyalty_number)
    record_new_update(loyalty_number, "password", nil, nil)
  end

  def self.find_and_record_updates(loyalty_number, fname, lname, phone_no)
    cust = Customer.get_customer(loyalty_number)
    if fname != cust.first_name
      record_new_update(loyalty_number, "first_name", cust.first_name, fname)
    end

    if lname != cust.last_name
      record_new_update(loyalty_number, "last_name", cust.last_name, lname)
    end

    if phone_no != cust.phone_number
      record_new_update(loyalty_number, "phone_number", cust.phone_number, phone_no)
    end
  end
end
