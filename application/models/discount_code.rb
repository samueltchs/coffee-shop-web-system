require "date"

class DiscountCode < Sequel::Model
  include Validation
  extend Validation

  def load(params)
    self.discount_code = params[:code]
    self.campaign_name = params[:name].strip
    self.percentage_off = params[:percentage]
    self.code_expiry_date = params[:expiry]
    self.is_active = params[:status]
    self.valid_purchase_date_from = params[:from]
    self.valid_purchase_date_to = params[:to]
    self.eligible_type = params[:pur_type]
    self.eligible_rule = params[:elig_rule]
    self.eligible_min = params[:min_amount]
  end
  
  def self.code_exist?(code_input)
    DiscountCode.where(discount_code: code_input).any?
  end

  def self.get_code_object(code)
    DiscountCode.first(discount_code: code)
  end

  def self.create_new_code(params)
    new_code = DiscountCode.new
    new_code.load(params)
    new_code.save_changes
  end
  
  def get_orders_used_code
    Order.where(discount_code_used: self.discount_code)
  end

  def total_used_code(mode)
    orders = get_orders_used_code
    if mode == :gross
      orders.sum(:price) || 0
    elsif mode == :net
      orders.sum(:net_price) || 0
    elsif mode == :cost
      orders.sum(:cost) || 0
    end
  end

  def profits_used_code
    total_used_code(:net) - total_used_code(:cost)
  end

  def discount_allowed_by_code
    total_used_code(:gross) - total_used_code(:net)
  end

  def get_purchase_type_name
    EligiblePurchaseType[self.eligible_type].type
  end

  def get_eligible_rule_name
    EligibleRule[self.eligible_rule].rule
  end

  def get_eligible_from_date
    Date.parse(self.valid_purchase_date_from)
  end

  def get_eligible_to_date
    Date.parse(self.valid_purchase_date_to)
  end

  def get_all_eligible_customers
    from_date = Date.parse(self.valid_purchase_date_from)
    to_date = Date.parse(self.valid_purchase_date_to)
    
    customers = Customer.all
    customers.select do |customer|
      rule_check(customer, from_date, to_date)
    end
  end

  def get_right_method
    method_name = 
      case [self.eligible_rule, self.eligible_type]
      when [1, 1]
        :total_purchase
      when [1, 2]
        :total_drinks_purchase_amount
      when [1, 3]
        :total_beans_purchase_amount
      when [2, 1]
        :total_purchase_quantity
      when [2, 2]
        :total_drinks_purchase_quantity
      when [2, 3]
        :total_beans_purchase_quantity
      end
    method_name
  end

  def rule_check(customer, from_date, to_date)
    method_name = get_right_method
    return false if method_name.nil?
    customer.send(method_name, from_date, to_date) >= self.eligible_min
  end

  def self.code_exist?(code_input)
    DiscountCode.where(discount_code: code_input).any?
  end

  def update_discount(params)
    self.load(params)
    self.save_changes
  end

  def self.get_all_active
    DiscountCode.where(is_active: 1)
  end
  
  def self.get_all_inactive
    DiscountCode.where(is_active: 0)
  end

  def self.get_all_codes
    select_map(:discount_code)
  end

  def self.normalize_params(params)
    params[:code] = params[:code].to_s.gsub(/\s+/,"").upcase
    params[:name] = params[:name].to_s.strip.split.map(&:capitalize).join(" ")
    params[:percentage] = params[:percentage].to_s.strip
    params[:expiry] = params[:expiry].to_s.strip
    params[:status] = params[:status].to_s.strip
    params[:from] = params[:from].to_s.strip
    params[:to] = params[:to].to_s.strip
    params[:pur_type] = params[:pur_type].to_s.strip
    params[:elig_rule] = params[:elig_rule].to_s.strip
    params[:min_amount] = params[:min_amount].to_s.strip
    params
  end

  def self.check_input_empty(params)
    errors = {}
    errors[:code] = "Discount code cannot be empty" if params[:code].empty?
    errors[:name] = "Campaign name cannot be empty" if params[:name].empty?
    errors[:percentage] = "Percentage off cannot be empty" if params[:percentage].empty?
    errors[:expiry] = "Expiry date cannot be empty" if params[:expiry].empty?
    errors[:status] = "Status cannot be empty" unless ["0", "1"].include?(params[:status])
    errors[:daterange] = "Daterange cannot be empty" if params[:from].empty? || params[:to].empty?
    errors[:pur_type] = "Purchase type cannot be empty" if params[:pur_type].empty?
    errors[:elig_rule] = "Eligible rule cannot be empty" if params[:elig_rule].empty?
    errors[:min_amount] = "Minimum amount cannot be empty" if params[:min_amount].empty?
    errors
  end

  def self.detect_input_errors(params)
    errors = check_input_empty(params)
    errors = validate_discount_code(params, errors) if params[:action] == "create"
    return errors unless errors.empty?
    if params[:viewcode] != params[:code] && params[:action] != "create"
      errors[:code] = "Discount Code cannot be changed"
    end
    errors[:name] = "Maximum 40 characters" unless str_max_length?(params[:name], 40)
    percent_valid = params[:percentage].to_i.between?(1, 100)
    errors[:percentage] = "Percentage must be between 1 and 100" unless percent_valid
    if params[:action] == "create" && Date.parse(params[:expiry]) < Date.today
      errors[:expiry] = "Expiry date must be in the future" 
    end   
    unless errors[:daterange]
      compare_date = Date.parse(params[:from]) > Date.parse(params[:to])
      errors[:daterange] = "Start date cannot be later than end date" if compare_date
    end
    errors[:min_amount] = "Minimum amount has to be at least 0" if params[:min_amount].to_f < 0
    errors
  end
  
  def self.validate_discount_code(params, errors)
    if code_exist?(params[:code])
      errors[:code] ||= "Discount code already exists"
    elsif params[:code] !~ /^[A-Z0-9]+$/
      errors[:code] ||= "Only letters and numbers allowed"
    elsif !str_min_length?(params[:code], 4) || !str_max_length?(params[:code], 12)
      errors[:code] ||= "Discount code must be between 4-12 characters"
    end
    errors
  end


  # get the multiplier for the price that this code provides. 
  # multiplier - real number to multiply total price by. eg 20% off => multiplier = 0.8
  def get_multiplier()
    return 1 - (percentage_off * 0.01)
  end

  def applies_to()
    EligiblePurchaseType.get_eligible_purchase_type(eligible_type)
  end

  def order_eligible?(order_id)
    order = Order.get_order(order_id)
    unless order.nil?
      rule = EligibleRule.get_rule_text(eligible_rule)
      type = applies_to
      value = 0
      if rule.start_with?("Amount")
        value = order.get_total_price_by_type(type)
      elsif rule.start_with?("Quantity")
        value = order.get_total_quantity_by_type(type)
      end

      EligibleRule.test(eligible_min, value)
    end
    # else will return nil (since order is nil)
  end

  # check order is eligible for this discount and apply it to the price 
  def apply_discount_to_order(order_id)
    order = Order.get_order(order_id)
    if !order.nil? && order_eligible?(order_id)
      type = applies_to
      original_price = order.get_total_price_by_type(type)
      unchanged_price = order.price - original_price # this is the amount that will not be affected by the discount code
      order.price = (original_price * get_multiplier) + unchanged_price
      order.save_changes
    end
  end    
  
  def basket_eligible?(loyalty_number)
    rule = EligibleRule.get_rule_text(eligible_rule)
    value = 0
    if rule.start_with?("Amount")
      value = BasketItem.get_total_basket_price(loyalty_number)
    elsif rule.start_with?("Quantity")
      value = BasketItem.get_total_basket_quantity(loyalty_number)
    end

    return EligibleRule.test(eligible_min, value)
  end

  # return the price the customer will have to pay after the discount code is applied to their basket
  def get_price_after_discount_applied_to_basket(loyalty_number)
    original_price = BasketItem.get_total_basket_price(loyalty_number)
    if basket_eligible?(loyalty_number)
      # apply the discount to find new price - return this
      return BasketItem.get_total_basket_price(loyalty_number) * get_multiplier()
    else
      return original_price # not eligible - return original price (no change)
    end
  end


end