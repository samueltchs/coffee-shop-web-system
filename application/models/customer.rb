require "bcrypt"
require "time"

class Customer < Sequel::Model
  include Conversions
    # check if an account with the given email exists in the customers table
    def self.email_exists?(email)
        return false if email.nil?
        return false if Customer.where(email: email).empty?
        return true # otherwise - ie this record exists
    end

  # return the Customer object with the given email
  def self.get_customer_by_email(email)
      if email_exists?(email)
          return Customer.first(email: email)
      else
          return nil 
      end
  end

  # return the Customer object with the given loyalty number
  def self.get_customer(loyalty_number)
    return Customer.first(loyalty_number: loyalty_number)
  end

  # return the customer with the given email and loyalty number, but only if they match the same Customer
  def self.get_customer_by_email_and_loyalty_no(email, loyalty_number)
    cust = get_customer_by_email(email)
    return nil unless cust && cust.loyalty_number.to_s == loyalty_number
    cust
  end

  # return the number of stamps of the customer with the given loyalty number (id)
  def self.get_amount_of_stamps(id)
    customer = Customer.first(loyalty_number: id)
    customer.stamps unless customer.nil?
  end

  # check email and password are correct and return the corresponding Customer object
  def self.login(email, pass)
    cust = get_customer_by_email(email)
    return nil if cust.nil? || !cust.correct_pass(pass)
    return cust # if login credentials are correct
  end

  # create a new customer account with the given details. Raises ArgumentError if customer account with the given email already exists
  def self.create_account(first_name, last_name, phone_no, email, pass)
    if Customer.email_exists?(email)
      raise ArgumentError.new("Account with this email already exists")
    else
      # store details
      cust = Customer.new
      cust.first_name = first_name
      cust.last_name = last_name
      cust.phone_number = phone_no
      cust.email = email
      cust.password = pass
      cust.stamps = 0
      cust.registered_time = Time.now.utc
      cust.status = "Active"
      cust.flagged_at = nil
      cust.suspended_at = nil
      cust.deleted_at = nil
      cust.save_changes
    end
  end
    
  #Checks whether the query entered is a name, loyalty number or email
  def self.search_type_recognition(query)
      if !query.to_i.zero?
          customers = search_customer_by_loyalty_number(query)
      elsif query.to_s.include?('@')
          customers = search_customer_by_email(query.downcase)     
      else
          customers = search_customer_by_name(query)
      end
      return customers
  end
    
  #Gets all customers' data by name 
  def self.search_customer_by_name(name)
      return Customer.all if name.to_s.strip.empty?
      customers = Customer.where(Sequel.|(
          Sequel.ilike(:first_name, "%#{name}%"),
          Sequel.ilike(:last_name, "%#{name}%"))
      )
      return customers
  end

  
  #Gets all customers' data by loyalty number 
  def self.search_customer_by_loyalty_number(loyalty_number)
      #where is meant to be first, kept like this for search type recognition
      customer = Customer.where(loyalty_number: loyalty_number)
      return customer if customer
      return nil
  end

  # return all customers with a given email (there will only be one!)
  def self.search_customer_by_email(email)
    return Customer.where(email: email.downcase)
  end

  # add or subtract stamps from the customer with the given loyalty number
  # operand (string) - "+" or "-", determines whether to add or subtract stamps
  # amount - the number of stamps to add to subtract
  def self.add_subtract_stamps(customer_loyalty_number, operand, amount)
      customer = Customer.first(loyalty_number: customer_loyalty_number)
      unless amount.to_i.nil? or amount.to_i < 1
          unless customer.nil?
              stamps = customer.stamps
              case operand
              when "+"
                  stamps = stamps + amount.to_i
              when "-"
                  stamps = stamps - amount.to_i
              else
                 return
              end

              if stamps < 0
                stamps = 0
              elsif stamps > 9
                stamps = 9
              end
                customer.update(stamps: stamps)
          end
      end
  end

  # reset the customer's stamps to 0
  def reset_stamps()
    self.stamps = 0
    self.save_changes
  end

  # hash the provided plaintext password, and store the hash in the db under the field pass_hash, 
  # in the row corresponding to this customer
  def password=(plaintext_password)
      self.pass_hash = BCrypt::Password.create(plaintext_password)
  end

  # return boolean value - true if password_attempt matches the stored password, false otherwise
  def correct_pass(password_attempt)
      BCrypt::Password.new(pass_hash) == password_attempt
  end

  # get the customer's full name (first and last)
  def name
      "#{first_name} #{last_name}"
  end

  # get this customer's address as a hash
  def address_hash
      {
          "address_line_1" => self.address_line_1,
          "address_line_2" => self.address_line_2,
          "city" => self.city,
          "postcode" => self.postcode
      }
  end

  # update the customer's address using the provided hash
  def set_address(address_hash)
      # TODO VALIDATE
      self.address_line_1 = address_string_validation(address_hash["address_line_1"])
      self.address_line_2 = address_string_validation(address_hash["address_line_2"])
      self.city = address_string_validation(address_hash["city"])
      self.postcode = address_string_validation(address_hash["postcode"])
      self.save_changes
  end

  # get all of this customer's orders between from_date and to_date
  def filtered_orders(from_date = nil, to_date = nil)
    orders = Order.where(loyalty_number: loyalty_number).all
    Order.select_relevant_orders(orders, from_date, to_date)
  end

  # get the total amount of money this customer spent between from_date and to_date
  def total_purchase(from_date = nil, to_date = nil)
    filtered_orders(from_date, to_date).sum(&:price)
  end

  # get the total number of purchases this customer made between from_date and to_date
  def num_purchase(from_date = nil, to_date = nil)
    filtered_orders(from_date, to_date).count
  end

  # get the average price of this customer's purchases
  def average_purchase_amount()
    orders = filtered_orders()
    return 0 if orders.empty?
    orders.sum { |o| o.price.to_f } / orders.count
  end

  def total_purchase_by_type(type, value_to_get, from_date, to_date)
    total = 0

    filtered_orders(from_date, to_date).each do |order|
      items = order.get_all_items_in_order
      next if items.nil?

      items.each do |item|
        next if Product.get_type_by_id(item.item_id) != type
        
        if value_to_get == :amount
          total += item.price_for_one * item.quantity
        elsif value_to_get == :quantity
          total += item.quantity
        end
      end
    end
    total
  end

  def total_drinks_purchase_amount(from_date, to_date)
    total_purchase_by_type("drinks", :amount, from_date, to_date)
  end

  def total_beans_purchase_amount(from_date, to_date)
    total_purchase_by_type("beans", :amount, from_date, to_date)
  end

  def total_drinks_purchase_quantity(from_date, to_date)
    total_purchase_by_type("drinks", :quantity, from_date, to_date)
  end

  def total_beans_purchase_quantity(from_date, to_date)
    total_purchase_by_type("beans", :quantity, from_date, to_date)
  end

  def total_purchase_quantity(from_date, to_date)
    d = total_purchase_by_type("drinks", :quantity, from_date, to_date)
    b = total_purchase_by_type("beans", :quantity, from_date, to_date)
    d + b
  end

  #parse registered time into time object
  def parse_regtime
    return nil if registered_time.to_s.empty?

    parse_time(registered_time)
  end
  
  #check whether an account is signed up in the current month
  def curr_month_signup?
    time = parse_regtime
    return false unless time

    now = Time.now.utc
    time.month == now.month && time.year == now.year
  end
end
