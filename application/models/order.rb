require_relative '../helpers/local_helpers'

class Order < Sequel::Model
  include LocalHelpers
  include Validation
  include Conversions
  extend Conversions
  extend Validation
  attr_accessor :old_values


  def self.create_order(barista_username)
    
    self.create(
      barista: barista_username,
      order_fulfilment: "Incomplete",
      status: "Unpaid"
    )

  end

  def set_customer(loyalty_number)
    self.update(loyalty_number: loyalty_number)
  end

  def set_reference_id(ref_id)
    self.update(reference_id: ref_id)
  end
  
  def self.get_complete_orders
    order = Order.exclude(order_fulfilment: "Incomplete")
    return order.exclude(status: "Unpaid") if order
    return order
  end

  def self.get_deliverable
    order = Order.where(status: "Paid")
    .where(order_fulfilment: "Completed")
    .where(delivered: 0)
    .where(tracking_id: [0, nil])
    return order if order
    return nil
  end


  def get_customer
    return self.loyalty_number
  end

  def get_barista
    barista = self.barista
    return barista if barista
    return "Online"
  end

  def get_discount_code_used
    discount_code = self.discount_code_used
    return discount_code if discount_code && !discount_code.empty?
    "None"
  end

  def get_percentage_off
    percentage_off = self.percentage_off
    return "#{percentage_off}%" if percentage_off
    "N/A"
  end

  def self.get_order(order_id)
    order = self.first(order_unique_id: order_id)  
    unless order.nil?
      return order
    end
    return nil
  end

  def get_beans
    product_ids = Product.get_beans.select(:product_id)
    items = self.get_all_items_in_order
    unless items.nil? || product_ids.empty?
      beans = items.where(item_id: product_ids)
      return beans if beans.any?
    end
    return nil
  end

  def all_items_beans?
    items = get_all_items_in_order
    return false unless items
    items.each do |item|
      return false unless item.is_bean?
    end
    true
  end

  def get_drinks
    product_ids = Product.get_drinks.select(:product_id)
    items = self.get_all_items_in_order
    unless items.nil? || product_ids.empty?
      drinks = items.where(item_id: product_ids)
      return drinks if drinks.any?
    end
    return nil
  end
    
  def get_date_placed
    return self.date_placed
  end

  def get_loyalty_number
    id = self.loyalty_number
    return id if id
    "N/A"
  end

  def get_tracking_id
    id = self.tracking_id
    return id if id
    "Handled In-Store"
  end
  
  def get_cost
    cost = self.cost
    return cost.round(2) if cost
    return "N/A"
  end

  def get_price
    price = self.price
    return price.round(2) if price
    return "N/A"
  end

  def get_payment_method
    PaymentMethod.get_name(self.payment_method)
  end

  def get_net_price
    price = self.net_price
    return price.round(2) if price
    return "N/A"
  end

  def get_delivered
    id = self.delivered
    return "Not Delivered" if id == 0 || !id
    return "Delivered"
  end

  def self.get_delivered_id(text)
    return 1 if text == "Delivered"
    return 0
  end


  def self.past_sales_filtering(orders, barista, fulfilment, loyalty_number , payment_method, delivery, payment_status, tracking_id, start_date, end_date)
    orders = Order.get_complete_orders
    orders = orders.where(barista: barista) unless barista.empty?
    orders = orders.where(order_fulfilment: fulfilment) unless fulfilment.empty?
    orders = orders.where(loyalty_number: loyalty_number) unless loyalty_number.empty?
    orders = orders.where(payment_method: PaymentMethod.get_id(payment_method)) unless payment_method.empty?
    unless delivery.empty?
      if delivery == "Not Delivered"
        orders = orders.where(delivered: [0, nil])
      else
        orders = orders.where(delivered: get_delivered_id(delivery))
      end
    end

    if payment_status == "Paid"
      orders = orders.where(status: "Paid")
    elsif payment_status == "Owed"
      orders = orders.exclude(status: "Paid")
    end

    if tracking_id == "Handled In-Store"
      orders = orders.where(tracking_id: nil)
    elsif tracking_id == "Has Tracking"
      orders = orders.where(Sequel[:tracking_id] > 0)
    end

    orders = Order.get_date_range(orders, start_date, end_date)
    orders
  end

  def get_reference_id
    id = self.reference_id
    return id if id
    "N/A"
  end

  def get_most_expensive_drink
    items = self.get_drinks
    return nil unless items
    max = -1
    redeemed = nil
    items.each do |item|
      if item.price_for_one > max
        max = item.price_for_one
        redeemed = item
      end
    end
    return redeemed
  end

  def set_net_price_barista
    items = self.get_all_items_in_order
    return 0 unless items
    total = 0
    items.each do |item|
      total += item.price_for_one * item.quantity
      total -= item.price_for_one if item.redemption_check(self.order_unique_id)
    end
    self.update(net_price: total)
    return total
  end

  def self.get_all_orders_by_customer(loyalty_number)
    Order.where(loyalty_number: loyalty_number)
  end

  def self.get_all_orders_details_by_customer(loyalty_number)
    orders = self.get_all_orders_by_customer(loyalty_number)
    orders_details = []
    orders.each do |order|
        id = order.order_unique_id
        no_items = order.get_all_items_in_order.nil? ? 0 : order.get_all_items_in_order.count
        price = order.price
        date = order.date_placed
        orders_details.append({
            "id" => id, 
            "no_items" => no_items, 
            "price" => price, 
            "date" => date
        })
    end

    return orders_details
  end

  # get the total price (before discounts) of all products of a given type in this order
  # type can be "beans" "drinks" or "both"
  def get_total_price_by_type(type)
    items = get_all_items_in_order
    return 0 unless items
    total_price = 0
    items.each do |item|
      product = item.get_product_entry
      if type == "both" || product.type == type
        total_price += (item.price_for_one * item.quantity)
      end
    end
    return total_price
  end

  def get_total_quantity_by_type(type)
    items = get_all_items_in_order
    total_quantity = 0
    items.each do |item|
      product = item.get_product_entry
      if type == "both" || product.type == type
        total_quantity += item.quantity
      end
    end
    return total_quantity
  end

  def get_total_quantity_by_id(product_id)
    items = get_all_items_in_order
    return 0 unless items
    total = 0
    items.each do |item|
      total += item.quantity if item.item_id == product_id
    end
    total
  end

  def self.total_in_daterange_by_type(type, from_date = nil, to_date = nil)
    orders = select_relevant_orders(all, from_date, to_date)
    orders.sum { |order| order.get_total_price_by_type(type) }
  end
  
  def get_all_items_in_order
    items = ItemInOrder.where(order_unique_id: order_unique_id)
    if items.any?
      return items
    end
    return nil
  end
  
  def get_cheapest_drink_entry
    cheapest = nil
    cheapest_price = 9999 # arbitrary large number - larger than any conceivable drink price
    get_all_items_in_order.each do |item|
      product = Product.get_product_by_id(item.item_id)
      if product.is_drink? && (cheapest.nil? || item.price_for_one < cheapest_price)
        cheapest = item
        cheapest_price = item.price_for_one
      end
    end

    return cheapest
  end

  # if the customer has enough stamps, claim the free drink
  def apply_free_drink(loyalty_number)
    customer = Customer.get_customer(loyalty_number)
    if FreeCoffeeRedemption.customer_is_eligible(loyalty_number)
      cheapest = get_cheapest_drink_entry
      if !cheapest.nil?
        to_deduct = cheapest.price_for_one <= 5 ? cheapest.price_for_one : 5
        self.price = (self.price - to_deduct).round(2)
        self.save_changes
        FreeCoffeeRedemption.redeem(cheapest, loyalty_number)
        customer.reset_stamps
      end
    end
  end

  # checks the provided discount code is valid, the applies it to the total price of this basket
  def apply_discount_code(loyalty_number, discount_code)
    if DiscountRedemption.customer_has_code_unredeemed?(loyalty_number, discount_code)
      self.price = (self.price * DiscountCode.get_code_object(discount_code).get_multiplier()).round(2)
      self.discount_code_used = discount_code
      self.save_changes
      DiscountRedemption.make_redeemed(loyalty_number, discount_code) # mark as redeemed (can't use again)
    end
  end
  
  #clicking cancel order with barista deletes all incomplete orders that they made
  def self.cleanup(barista)
    orders = self.where(order_fulfilment: "Incomplete", barista: barista)
    return "" unless orders
    orders.each do |order|
      FreeCoffeeRedemption.where(order_unique_id: order.order_unique_id).delete
      ItemInOrder.where(order_unique_id: order.order_unique_id).delete
    end
    orders.delete
  end
  
  def set_price
    items = self.get_all_items_in_order
    return 0 unless items
    total = 0
    items.each do |item|
      total += item.price_for_one * item.quantity
    end
    self.update(price: total)
  end

  def set_cost
    items = self.get_all_items_in_order
    return 0 unless items
    total = 0
    items.each do |item|
      total += ProductVariant.get_cost(item.item_id, item.size_id, item.milk_id) * item.quantity
    end
    self.update(cost: total)
  end

  def self.set_net_price(order_id)
    order = get_order(order_id)
    return unless order
    
    code = DiscountCode.get_code_object(order.discount_code_used)
    #discount code is used
    if code
      order.percentage_off = code.percentage_off
      order.net_price = order.price * code.get_multiplier
      #no discount code is used
    else
      order.net_price = order.price
    end
    order.save_changes
  end
  
  # used whena  customer purchases the beans in their online basket
  # used when a customer purchases the beans in their online basket
  # loyalty_number - loyalty number of customer placing the order
  # delivery - boolean to specify whether the customer has selected delivery (true) or pickup (false)
  # TODO - TRACKING NUMBER
  def self.create_online_order(loyalty_number, delivery)
    order = Order.new
    order.loyalty_number = loyalty_number
    order.reference_id = "AAA0000000" # a placeholder value
    order.order_fulfilment = "Incomplete"
    order.status = "Unpaid"
    
    order.delivered = delivery ? 0 : nil # TODO test this to see if generates null
    order.date_placed = Time.now.utc.to_s
    order.save_changes
    return order
  end

  # creates a new order, saves it in the orders table, then adds all items in the customer's basket to that order,
  # by creating new entries in the item_in_orders table. Applies a provided discount code.
  # delivery - boolean describing whether the customer wants delivery (true) or pickup (false)
  def self.order_full_basket(loyalty_number, delivery, discount_code)
    if BasketItem.basket_empty?(loyalty_number)
      # cannot order 0 items
      return -1
    else
      order = create_online_order(loyalty_number, delivery)
      
      basket_entries = BasketItem.get_all_entries_by_customer(loyalty_number)
      total_cost = 0
      total_price = 0
      basket_entries.each do |basket_entry|
        # extract item and quantity from basket_entry
        item = Product.get_product_by_id(basket_entry.product_id)
        quantity = basket_entry.quantity
        
        # return error code if not enough stock (stock control only works for beans)
        if item.is_bean? && quantity > item.stock_level
          # cancel whole order
          order.remove_all_items
          order.delete
          # return item so can give error
          raise RuntimeError.new("Only " + item.stock_level.to_s + " units of " + item.name + " available")
        end

        # add to order + adjust stock level
        if item.is_bean?
          ItemInOrder.add_bean_to_order(order.order_unique_id, item.product_id, quantity)
        else
          ItemInOrder.add_drink_to_order(order.order_unique_id, item.product_id, quantity, basket_entry.milk_id, basket_entry.size_id)
        end
        # keep track of price
        product_variant = ProductVariant.find_variant(item.product_id, basket_entry.size_id, basket_entry.milk_id)
        total_cost += product_variant.cost * quantity
        total_price += product_variant.price * quantity
      end

      order.price = total_price.round(2)
      order.net_price = total_price.round(2)
      order.cost = total_cost.round(2)
      order.save_changes

      order.apply_free_drink(loyalty_number)
      order.apply_discount_code(loyalty_number, discount_code)

      return order.order_unique_id
    end
  end

  def owed?
    return true if self.status == "Owed"
    return false
  end

  def remove_all_items()
    ItemInOrder.get_all_items_in_order(order_unique_id).each do |item|
      product = Product.get_product_by_id(item.item_id)
      product.increase_quantity(item.quantity) # not being ordered anymore, so adjust stock
      item.delete
    end
  end

  # add the amount of stamps this order earns to the customer's account. Should only be used if the customer's payment is successful, 
  # but may be used where necessary by employees without this check
  def give_stamps()
    order_items = get_all_items_in_order()

    order_items.each do |order_item|
      # extract item and quantity from basket_entry
      item = Product.get_product_by_id(order_item.item_id)
      quantity = order_item.quantity

      # beans earn 3 stamps, drinks earn 1
      if item.is_bean?
        Customer.add_subtract_stamps(loyalty_number, "+", 3 * quantity)
      else
        Customer.add_subtract_stamps(loyalty_number, "+", 1 * quantity)
      end
    end
  end

  def generate_order_id 
    id = -1
    while id == -1 or ItemInOrder.where(item_in_order_id: id).nil?
      #Cannot Start with 0 (ensures the number of integers)
      id = SecureRandom.random_number(9)
      for i in 0...9 do
        id *= 10
        id += SecureRandom.random_number(9)
      end
    end
    return id
  end

  def remove_all_discounts() 
    items = get_all_items_in_order
    total_price = 0
    items.each do |item|
      total_price += (item.price_for_one * item.quantity)
    end
  end

  def mark_order_as_paid
    self.update(status: "Paid")
  end

  def set_delivered
    self.update(delivered: 1)
  end

  def set_collected
    self.update(order_fulfilment: "Collected")
  end

  def validate_reference_id
    errors.clear

    if !valid_reference_id?(reference_id)
      errors.add("reference_id", "is not valid. Must be 8-12 characters long and be of the form ABC1234567.")
    end

    if reference_id && !reference_id.empty? && old_values && reference_id == old_values[:reference_id]
      errors.add("reference_id", "must not be the same as the current one.")
    end

    if reference_id && !reference_id.empty?
      existing_reference_id = Order.first(reference_id: reference_id)
      errors.add("reference_id", "already exists.") if existing_reference_id && existing_reference_id != self
    end

    errors.add("reference_id", "could not be verified.") if !verify_reference_id(reference_id) && errors.empty?

    errors.empty?
  end

  def validate_status
    errors.clear

    errors.add("status", "is not valid.") unless ["Paid", "Unpaid", "Owed", "Refunded"].include?(status)

    if status && !status.empty? && old_values && status == old_values[:status]
      errors.add("status", "must not be the same as the current one.")
    end

    errors.empty?
  end

  def load(params)
    self.reference_id = generate_unique_reference_id if reference_id.nil? || reference_id.empty?
    self.order_fulfilment = params.fetch("order_fulfilment", "").strip
    self.status = params.fetch("status", "").strip
  end

  def incomplete?
    return true if self.order_fulfilment == "Incomplete"
    return false
  end

  def refunded?
      return true if self.status == "Refunded"
    return false
  end

  #select and return an array of orders within a daterange from a collection of orders
  def self.select_relevant_orders(orders, from_date = nil, to_date = nil)
    orders.select do |order|
      next unless order.date_placed
      date = uk_date(parse_time(order.date_placed)) 
      
      if from_date && to_date
        (from_date..to_date).cover?(date)
      elsif from_date
        date >= from_date
      elsif to_date
        date <= to_date
      else
        true
      end
    end
  end

  def self.get_date_range(orders, start_date, end_date)
    unless start_date.empty?
      start_normalised = "#{start_date} 00:00:00 UTC"
      orders = orders.where { date_placed >= start_normalised }
    end
    unless end_date.empty?
      end_normalised = "#{end_date} 23:59:59 UTC"
      orders = orders.where { date_placed <= end_normalised }
    end
    orders
  end

  def checkout(barista, payment_method = nil)
    self.set_delivered
    self.set_collected
    if payment_method
      id = PaymentMethod.get_id(payment_method)
      self.update(reference_id: generate_unique_reference_id) if payment_method == "Card"
      self.update(payment_method: id)
      self.update(status: "Paid")
    end
    self.update(barista: barista)
  end

  def self.get_todays_orders(orders)
    today = Time.now.utc.strftime("%Y-%m-%d")
    orders.where(Sequel.like(:date_placed, "#{today}%"))
  end

  def refund
    self.update(status: "Refunded")
    FreeCoffeeRedemption.clear(self.order_unique_id)
    items = self.get_all_items_in_order
    items.each do |item|
      item.refund
    end
  end

  def submit(payment_method, reference_id)
    self.update(date_placed: Time.now.utc.to_s)
    redemption = FreeCoffeeRedemption.first(order_unique_id: order_unique_id)
    redemption.update(redeem_timestamp: Time.now.utc.to_s) if redemption
    self.set_net_price_barista
    self.set_price
    self.set_cost
    self.update(payment_method: payment_method)
    self.update(order_fulfilment: "Collected")
    self.set_delivered
    self.update(status: "Paid")
    self.update(reference_id: reference_id) if payment_method.to_i == 1
  end

end