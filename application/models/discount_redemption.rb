class DiscountRedemption < Sequel::Model
  
  def is_redeemed?
    self.is_redeemed == 1
  end
  
  def self.customer_has_code?(loyalty_number, code)
    where(loyalty_number: loyalty_number, code: code).any?
  end

  def self.customer_has_code_unredeemed?(loyalty_number, code)
    where(loyalty_number: loyalty_number, code: code, is_redeemed: 0).any?
  end

  def self.make_redeemed(loyalty_number, code)
    record = get_by_loyalty_and_code(loyalty_number, code)
    if record
      record.is_redeemed = 1
      record.save_changes
    end
  end

  def self.get_by_loyalty_and_code(loyalty_number, code)
    first(loyalty_number: loyalty_number, code: code)
  end

  def self.new_record(loyalty_number, code)
    record = DiscountRedemption.new
    record.loyalty_number = loyalty_number
    record.code = code
    record.is_redeemed = 0
    record.save
  end

  def self.distribute_to_eligible_customers
    discount_codes = DiscountCode.get_all_active
    discount_codes.each do |discount|
      customers = discount.get_all_eligible_customers
      customers.each do |customer|
        loyalty_number = customer.loyalty_number
        code = discount.discount_code
        unless customer_has_code?(loyalty_number, code)
          new_record(loyalty_number, code)
        end
      end
    end
  end

  # get unredeemed entries for a given customer in this table
  def self.get_all_unredeemed_codes_by_customer(loyalty_number)
    DiscountRedemption.where(loyalty_number: loyalty_number, is_redeemed: 0)
  end

  # get the actual code object for all unredeemed codes for a given customer
  def self.get_all_unredeemed_code_objects_by_customer(loyalty_number)
    codes = []
    get_all_unredeemed_codes_by_customer(loyalty_number).each do |entry|
      codes.append(DiscountCode.first(discount_code: entry.code))
    end
    return codes
  end
end