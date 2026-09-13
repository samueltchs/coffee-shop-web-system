require 'time'
require 'securerandom'

# Provide various functions for controllers and views
module LocalHelpers
  CAFE_NAME = "Badly Brewed Coffee"
  VALID_REFERENCE_IDS = [
    "ABC12345",
    "ABC123456",
    "ABC1234567",
    "ABC12345678",
    "ABC123456789"
  ]

  def generate_reference_id
    letters = ""
    digits = ""

    letter_index = 0
    while letter_index < 3
      letters += (65 + SecureRandom.random_number(26)).chr
      letter_index += 1
    end

    no_of_digits = 5 + SecureRandom.random_number(5)

    digit_index = 0
    while digit_index < no_of_digits
      digits += SecureRandom.random_number(10).to_s
      digit_index += 1
    end

    letters + digits
  end

  def generate_tracking_id
    id = SecureRandom.random_number(9) + 1
    for i in 1..8
      id = id * 10 + SecureRandom.random_number(10)
    end
    id
  end

  def generate_unique_reference_id
    loop do
      reference_id = generate_reference_id

      return reference_id if Order.first(reference_id: reference_id).nil?
    end
  end

  # simulates verification of a payment via an external payment service
  # by checking if the reference id matches any fixed ones
  def verify_reference_id(reference_id)
    VALID_REFERENCE_IDS.include?(reference_id)
  end

  def admin
    admin = Employee.first(username: session[:username], role: 'Admin')

    redirect "/" if admin.nil?

    admin
  end

  def employee
    username = params["username"]

    user_not_found unless username

    employee = Employee[username]

    user_not_found if employee.nil?

    employee
  end

  def get_customer
    loyalty_number = params["loyalty_number"]

    user_not_found unless loyalty_number

    customer = Customer[loyalty_number]

    user_not_found if customer.nil?

    customer
  end

  def order
    order_id = params["order_id"]

    order_not_found unless order_id

    order = Order[order_id]

    order_not_found if order.nil?

    order
  end

  def title_of_user_page(user, page_name)
    if user
      "#{user.name} - #{page_name}"
    else
      page_name.to_s
    end
  end

  def title_of_order_page(order)
    if order
      "#{order.order_unique_id} - Order Admin View"
    else
      "Order - Admin View"
    end
  end

  def redirect_to_search_page(key, message)
    redirect "/admin-search?#{URI.encode_www_form(key => message)}"
  end

  def user_not_found
    redirect_to_search_page("error", "User not found or deleted.")
  end

  def order_not_found
    redirect_to_search_page("error", "Order not found.")
  end

  def delete_employee_success
    redirect_to_search_page("success", "The former employee's account has been deleted successfully.")
  end

  def employee_not_logged_in
    error = { "error" => "Access denied : Login required." }
    error_query = URI.encode_www_form(error)
    redirect "/employee-login-page?#{error_query}"
  end

  def require_login
    employee_not_logged_in unless session[:username] && session[:role]
  end

  def products_of_an_order(order)
    return [] unless order

    ItemInOrder
      .join(:products, product_id: :item_id)
      .where(order_unique_id: order.order_unique_id)
      .map([:name, :price_for_one, :quantity, :image_path, :size_id, :milk_id])
  end

  def format_count(count, word)
    if count == 1
      "1 #{word}"
    else
      "#{count} #{word}s"
    end
  end

  def format_month(month)
    return nil unless month
    
    Date.strptime(month, "%Y-%m").strftime("%B %Y")
  end

  def format_time(time)
    return nil unless time

    parsed_time = Time.parse(time.to_s)

    uk_time(parsed_time).strftime("%d/%m/%Y %H:%M")
  end

  def format_date(time)
    return nil unless time

    format_time(time).split(" ").first
  end

  def format_price(price)
    return "N/A" unless price && price != "N/A"

    "£#{'%.2f' % price}"
  end

  def format_total(price, quantity)
    return "N/A" unless price && quantity

    "£#{'%.2f' % (price * quantity)}"
  end

  def admin_inbox_messages
    messages = []

    Customer.exclude(status: 'Deleted').each do |cust|
      loyalty_no = cust.loyalty_number

      add_flagged_message(cust, loyalty_no, messages)
      add_suspended_message(cust, loyalty_no, messages)
    end

    messages_sorted = messages.sort_by do |element|
      element[0]
    end

    messages_sorted.reverse
  end

  def add_flagged_message(cust, loyalty_no, messages)
    return unless cust.status == "Flagged" && cust.flagged_at

    text = "has been flagged as 6 months inactive. Suspend option now available."
    time = Time.parse(cust.flagged_at)

    messages << [time, text, loyalty_no]
  end

  def add_suspended_message(cust, loyalty_no, messages)
    return unless cust.status == "Suspended" && three_months_since_suspended(cust) && cust.suspended_at && cust.suspension_reason_id == 1

    suspended_time = Time.parse(cust.suspended_at)
    seconds_in_three_months = 60 * 60 * 24 * 30 * 3
    text = "has not returned within 3 months of their suspension. Delete option now available."
    time = suspended_time + seconds_in_three_months

    messages << [time, text, loyalty_no]
  end

  def setup_admin_email(title, subject)
    @title = title
    @subject = subject
    @cafe_name = CAFE_NAME
    @admin = admin
    @customer = get_customer
    @sender_email = @admin.email
    @sender_name = @admin.name
    @receiver_email = @customer.email
    @receiver_name = @customer.name
    @automated_email = false
  end

  def setup_automated_email(title, subject, receiver_email = nil, receiver_name = nil)
    @title = title
    @subject = subject
    @cafe_name = CAFE_NAME
    @sender_email = "noreply@badlybrewedcoffee.com"
    @sender_name = "The #{CAFE_NAME} Team"
    @automated_email = true

    if receiver_email && receiver_name
      @receiver_email = receiver_email
      @receiver_name = receiver_name
    else
      @customer = get_customer
      @receiver_email = @customer.email
      @receiver_name = @customer.name
    end
  end

  def setup_admin_customer_page(customer)
    @active = customer_times_recorded(customer).length >= 2
    @inactivity_time = inactivity_in_months(customer)
    @four_days_since_flagged = four_days_since_flagged(customer)
    @five_months_inactive = five_months_inactive(customer)
    @three_months_since_suspended = three_months_since_suspended(customer)
    @top_items = top_items_for_habits(customer)
  end

  def size_abbreviation(size)
    return "" unless size && !size.empty? && size != "N/A"

    "(#{size[0].upcase})"
  end

  def redirect_based_on_role
    case session[:role]
    when "Barista"
      redirect "/barista/main"
    when "Admin"
      redirect "/admin-main"
    when "Manager"
      redirect "/manager/dashboard"
    else
      redirect "/"
    end

    halt
  end
end
