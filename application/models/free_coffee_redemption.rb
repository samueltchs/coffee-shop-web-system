class FreeCoffeeRedemption < Sequel::Model
  include Conversions

  def self.redeem(drink, customer_id)
    self.create(
      order_unique_id: drink.order_unique_id,
      loyalty_number: customer_id,
      product_id: drink.get_product_id,
      item_in_order_id:  drink.item_in_order_id,
      size_id: drink.get_size_id,
      milk_id: drink.milk_id,
    )    
  end

  def self.customer_is_eligible(loyalty_number)
    Customer.get_customer(loyalty_number).stamps == 9
  end

  def self.clear(order_id)
    redemption = self.first(order_unique_id: order_id)
    return unless redemption
    Customer.add_subtract_stamps(redemption.loyalty_number, '+', 9)
    redemption.delete
  end

  #refactor the ones in order model and customers page controller later
  def self.get_all_redemption_in_daterange(redemptions, from_date = nil, to_date = nil)
    redemptions.select do |redemption|
      date = redemption.uk_date(redemption.parse_time(redemption.redeem_timestamp))
      next unless date
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

  def self.sum(redemptions, field)
    sum = 0
    redemptions.each do |r|
      variant = ProductVariant.find_variant(r.product_id ,r.size_id ,r.milk_id)
      sum += variant.send(field) if variant
    end
    sum
  end

end