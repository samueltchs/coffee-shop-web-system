require "time"
require "securerandom"

# Provide various functions for customer-related operations 
module CustomerHelpers
  SECONDS_IN_DAY = 60 * 60 * 24
  SECONDS_IN_MONTH = SECONDS_IN_DAY * 30

  def customer_times_recorded(customer)
    return [] unless customer

    loyalty_number = customer.loyalty_number

    get_customer_times(loyalty_number)
  end

  def get_customer_times(loyalty_number)
    times_recorded = []

    Order.where(loyalty_number: loyalty_number).each do |order|
      times_recorded << order.date_placed if order.date_placed
    end

    LoginTime.where(loyalty_number: loyalty_number).each do |login_record|
      times_recorded << login_record.login_time if login_record.login_time
    end

    Favourite.where(loyalty_number: loyalty_number).each do |favourite|
      times_recorded << favourite.time_favourited if favourite.time_favourited
    end

    RecentView.where(loyalty_number: loyalty_number).each do |recent_view|
      times_recorded << recent_view.time_viewed if recent_view.time_viewed
    end

    ProfileUpdate.where(loyalty_number: loyalty_number).each do |profile_update|
      times_recorded << profile_update.time_updated if profile_update.time_updated
    end
    
    times_recorded
  end

  def compute_inactivity(customer)
    times_recorded = customer_times_recorded(customer)

    if times_recorded.empty?
      return nil unless customer.registered_time

      registration_time = Time.parse(customer.registered_time)

      return Time.now.utc - registration_time
    end

    most_recent_time = times_recorded.max

    Time.now.utc - Time.parse(most_recent_time)
  end

  def inactivity_in_months(customer)
    seconds = compute_inactivity(customer)

    return nil unless seconds

    months = (seconds / SECONDS_IN_MONTH).floor

    return "1 month" if months == 1

    return "< 1 month" if months.zero?

    "#{months} months"
  end

  def five_months_inactive(customer)
    seconds_inactive = compute_inactivity(customer)

    return false unless seconds_inactive

    seconds_in_five_months = SECONDS_IN_MONTH * 5

    seconds_inactive >= seconds_in_five_months
  end

  def four_days_since_flagged(customer)
    return false unless customer.status == "Flagged" && customer.flagged_at

    flagged_time = Time.parse(customer.flagged_at)
    seconds_in_four_days = SECONDS_IN_DAY * 4

    Time.now.utc - flagged_time >= seconds_in_four_days
  end

  def three_months_since_suspended(customer)
    return false unless customer.status == "Suspended" && customer.suspended_at

    suspended_time = Time.parse(customer.suspended_at)
    seconds_in_three_months = SECONDS_IN_MONTH * 3

    Time.now.utc - suspended_time >= seconds_in_three_months
  end

  def automatic_flag(customer)
    return unless customer.status == "Active"

    seconds_inactive = compute_inactivity(customer)
    seconds_in_six_months = SECONDS_IN_MONTH * 6

    return unless seconds_inactive && seconds_inactive >= seconds_in_six_months

    customer.status = "Flagged"
    customer.flagged_at = Time.now.utc
    customer.save_changes
  end

  def automatic_reactivation(customer)
    return unless customer.status == "Flagged" && customer.flagged_at

    seconds_inactive = compute_inactivity(customer)
    seconds_in_six_months = SECONDS_IN_MONTH * 6

    return unless seconds_inactive && seconds_inactive < seconds_in_six_months

    customer.status = "Active"
    customer.flagged_at = nil
    customer.save_changes
  end

  def automatic_suspension(customer)
    return unless customer.status == "Flagged" && customer.flagged_at

    flagged_time = Time.parse(customer.flagged_at)
    seconds_in_five_days = SECONDS_IN_DAY * 5

    return unless Time.now.utc - flagged_time >= seconds_in_five_days

    customer.status = "Suspended"
    customer.suspended_at = Time.now.utc
    customer.suspension_reason_id = 1
    customer.save_changes
  end

  def automatic_deletion(customer)
    return unless three_months_since_suspended(customer) && customer.suspension_reason_id == 1

    suspended_time = Time.parse(customer.suspended_at)
    seconds_in_three_months = SECONDS_IN_MONTH * 3
    seconds_in_week = SECONDS_IN_DAY * 7
    deletion_time = suspended_time + seconds_in_three_months + seconds_in_week

    return unless Time.now.utc >= deletion_time

    anonymize_customer(customer, 1)
  end

  def run_inactivity_checks
    customers = Customer.all

    customers.each do |cust|
      automatic_flag(cust)
      automatic_reactivation(cust)
      automatic_suspension(cust)
      automatic_deletion(cust)
    end
  end

  def run_inactivity_checks_once_per_hour
    last_checked = session["last_inactivity_check"]

    return if last_checked && Time.now.utc - Time.parse(last_checked) < 3600

    run_inactivity_checks

    session["last_inactivity_check"] = Time.now.utc.to_s
  end

  def anonymize_customer(customer, deletion_reason_id)
    DB.transaction do
      old_loyalty_no = customer.loyalty_number
      new_loyalty_no = unique_deleted_cust_loyalty_no

      update_customer_associations(old_loyalty_no, new_loyalty_no)

      updated_rows = anonymize_customer_record(old_loyalty_no, new_loyalty_no, deletion_reason_id)

      raise Sequel::Rollback if updated_rows.zero?

      new_loyalty_no
    end
  end

  def anonymize_customer_record(old_loyalty_no, new_loyalty_no, deletion_reason_id)
    DB[:customers].where(loyalty_number: old_loyalty_no).update(
      loyalty_number: new_loyalty_no,
      first_name: 'Deleted',
      last_name: SecureRandom.alphanumeric(6),
      pass_hash: nil,
      address_line_1: nil,
      address_line_2: nil,
      city: nil,
      postcode: nil,
      phone_number: nil,
      email: nil,
      status: 'Deleted',
      registered_time: nil,
      flagged_at: nil,
      suspended_at: nil,
      deleted_at: Time.now.utc,
      suspension_reason_id: nil,
      deletion_reason_id: deletion_reason_id
    )
  end

  def update_customer_associations(old_loyalty_no, new_loyalty_no)
    model_classes = [Order, LoginTime, Favourite, RecentView, FreeCoffeeRedemption]

    model_classes.each do |model|
      model.where(loyalty_number: old_loyalty_no).update(loyalty_number: new_loyalty_no)
    end

    BasketItem.where(loyalty_number: old_loyalty_no).delete

    ProfileUpdate.where(loyalty_number: old_loyalty_no).update(
      loyalty_number: new_loyalty_no,
      old_value: nil,
      new_value: nil
    )

    Refund.where(loyalty_number: old_loyalty_no).update(
      loyalty_number: new_loyalty_no,
      refund_reason: ''
    )

    DiscountRedemption.where(loyalty_number: old_loyalty_no).update(loyalty_number: new_loyalty_no)
    Promotion.where(loyalty_number: old_loyalty_no).update(loyalty_number: new_loyalty_no)

    Complaint.where(loyalty_number: old_loyalty_no).update(
      loyalty_number: new_loyalty_no,
      complaint_text: 'Deleted'
    )
  end

  def unique_deleted_cust_loyalty_no
    loop do
      new_loyalty_no = SecureRandom.random_number(999_999_999) + 1

      return new_loyalty_no if Customer.first(loyalty_number: new_loyalty_no).nil?
    end
  end
end
