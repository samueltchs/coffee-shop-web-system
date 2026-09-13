class ItemInOrder < Sequel::Model

  def self.add_drink_to_order(order_id, item_id, amount, milk_id, size_id)
    product = Product.first(product_id: item_id)
    item_in_order = self.first(order_unique_id: order_id, item_id: item_id, milk_id: milk_id, size_id: size_id)
    if item_in_order.nil? unless product.nil?
      price = ProductVariant.get_price(item_id, size_id, milk_id)
      self.create(
        item_id: item_id,
        order_unique_id: order_id,
        milk_id: milk_id,
        size_id: size_id,
        quantity: amount,
        price_for_one: price,
        refunded: 0
      )
    else
      item_in_order.update(quantity: item_in_order.quantity + amount)
    end
    product.reduce_quantity(amount) unless product.nil?
  end

  def get_cost_for_one
    ProductVariant.get_cost(item_id, size_id, milk_id)
  end

  def self.add_beans_to_order(order_id, item_id, amount)
    product = Product.first(product_id: item_id)
    item_in_order = self.first(order_unique_id: order_id, item_id: item_id,)
    if item_in_order.nil? unless product.nil?
      price = product.get_bean_price
      self.create(
        item_id: item_id,
        order_unique_id: order_id,
        milk_id: 1,
        size_id: 1,
        quantity: amount,
        price_for_one: price,
        refunded: 0
      )
    else
      item_in_order.update(quantity: item_in_order.quantity + amount)
    end
    product.reduce_quantity(amount) unless product.nil?
  end

  def self.get_all_items_in_order(order_unique_id)
    return ItemInOrder.where(order_unique_id: order_unique_id)
  end

  # add a specified bean (product) to the given order, with a given quantity.
  # TODO - improve validationa
  def self.add_bean_to_order(order_unique_id, product_id,  quantity)
    entry = ItemInOrder.new
    entry.order_unique_id = order_unique_id
    entry.item_id = product_id
    entry.quantity = quantity
    entry.size_id = 1
    entry.milk_id = 1   

    # get price for one 
    entry.price_for_one = Product.get_bean_by_id(product_id).get_bean_price
    entry.refunded = 0
    entry.save
  end


  def self.remove(item_in_order_id, amount)
    item = get_item(item_in_order_id)
    return false if amount <= 0
    unless item.nil?
      quantity = item.quantity
      quantity -= amount
      if quantity < 1
        item.delete
        return true
      else
        item.update(quantity: quantity)
      end
      product = Product.first(product_id: item.item_id)
      product.increase_quantity(amount) 
    end
    return false
  end

  def get_name
    Product.first(product_id: item_id).name
  end

  def get_product_id
    return self.item_id
  end
    
  def self.get_item(item_in_order_id)
    self.first(item_in_order_id: item_in_order_id)
  end

  def self.all_refunded?(order_id)
    where(order_unique_id: order_id, refunded: 0).empty?
  end

  def get_roast_level
    Product.first(product_id: self.item_id).get_roast_level
  end

  def get_milk_name
    milk =  MilkOption.get_milk_name(self.milk_id)
    return milk if milk
    return "N/A"
  end
  
  def get_size_id
    return self.size_id  
  end
  
  def get_size_text
    return Size.get_size(self.size_id)
  end
  
  def get_origin
    product = Product.first(product_id: self.item_id)
    product.get_origin
  end

  def get_refund_status
    return "N/A" if self.refunded.nil?
    return "Refunded" if self.refunded == 1
    return "Not Refunded"
  end

  def refund
    refunded_entry = ItemInOrder.first(
      order_unique_id: self.order_unique_id,
      item_id: self.item_id,
      milk_id: self.milk_id,
      size_id: self.size_id,
      refunded: 1
    )
    if self.quantity > 1
      if refunded_entry
        refunded_entry.update(quantity: refunded_entry.quantity + 1)
      else
        ItemInOrder.create(
          item_id: self.item_id,
          order_unique_id: self.order_unique_id,
          milk_id: self.milk_id,
          size_id: self.size_id,
          price_for_one: self.price_for_one,
          quantity: 1,
          refunded: 1
        )
      end
      self.update(quantity: self.quantity - 1)
    elsif refunded_entry
      self.update(quantity: refunded_entry.quantity + 1)
      refunded_entry.delete
      self.update(refunded: 1)
    else 
      self.update(refunded: 1)
    end
  end

  def redemption_check(order_id)
    redemption = FreeCoffeeRedemption.first(order_unique_id: order_id)
    if redemption && self.item_in_order_id == redemption.item_in_order_id
        return true 
    end
    return false
  end
  
  def get_product_entry
    Product.first(product_id: item_id)
  end

  def self.get_most_frequently_bought_items(loyalty_number)
    orders = Order.where(loyalty_number: loyalty_number).all
    
    counts = Hash.new(0)
    
    orders.each do |order|
      items = ItemInOrder.where(order_unique_id: order.order_unique_id)
      
      # counts how many times an item was ordered by customer
      items.each do |item|
        item_key = [item.item_id, item.size_id, item.milk_id]
        
        counts[item_key] += item.quantity
      end
    end
    
    # sorts the array by the no. of times an item was ordered
    counts_array_sorted = counts.to_a.sort_by do |element|
      element[1]
    end
    
    # returns the top 5 items with the highest count in descending order
    counts_array_sorted.last(5).reverse
  end
  
  def is_bean?
    Product.first(product_id: self.item_id).is_bean?
  end

  def is_drink?
    Product.first(product_id: self.item_id).is_drink?
  end

  def has_milk?
    Product.first(product_id: item_id).has_milk?
  end


end
