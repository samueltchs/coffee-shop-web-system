class ProductVariant < Sequel::Model
  
  def load(product_id, size_id, milk_id, price, cost)
    self.product_id = product_id
    self.size_id = size_id
    self.milk_id = milk_id
    self.price = price
    self.cost = cost
  end

  def self.find_variant(product_id, size_id, milk_id)
    first(product_id: product_id, size_id: size_id, milk_id: milk_id)
  end

  def self.get_bean(product_id)
    first(product_id: product_id, size_id: 1, milk_id: 1)
  end

  def self.get_price(product_id, size_id, milk_id)
    product_variant = find_variant(product_id, size_id, milk_id)
    product_variant ? product_variant.price : "N/A"
  end

  def self.get_cost(product_id, size_id, milk_id)
    product_variant = find_variant(product_id, size_id, milk_id)
    product_variant ? product_variant.cost : "N/A"
  end

  # get the price of this product variant as a string, always to 2 decimal places
  def get_price_string
    price_float_to_string(self.price)
  end

  def get_distinct_size_variants
    select(:product_id, :name).distinct
  end
end
