class Refund < Sequel::Model

def self.get_all_refunds
return Refund.all
end

  def self.get_resolved(refunds)
    refunds.where(status: "Resolved")
  end

  def self.get_pending(refunds)
    refunds.where(status: "Pending")
  end

  def self.get_denied(refunds)
    refunds.where(status: "Denied")
  end

  
  def self.get_refund_by_id(refund_id)
    return Refund.first(refund_id: refund_id)
  end
  
  def self.get_refunds_by_customer(loyalty_no)
    return Refund.where(loyalty_number: loyalty_no).all
  end
  
  def get_order_id
    id = self.order_id
    return id if id
    return "N/A"
  end

  def get_item_id
    id = self.item_id
    return id if id
    return "N/A"
  end

  def self.apply_filters(loyalty_number, refund_status, start_date, end_date)
    refunds = Refund.dataset
    refunds = refunds.where(loyalty_number: loyalty_number) if !loyalty_number.nil? && !loyalty_number.strip.empty?
    refunds = refunds.where(status: refund_status) if !refund_status.nil? && !refund_status.strip.empty?
    refunds = Refund.get_date_range(refunds, start_date, end_date)
    refunds
  end

  def self.get_date_range(refunds, start_date, end_date)
    unless start_date.nil? || start_date.empty?
      start_normalised = "#{start_date} 00:00:00 UTC"
      refunds = refunds.where { created_at >= start_normalised }
    end
    unless end_date.nil? || end_date.empty?
      end_normalised = "#{end_date} 23:59:59 UTC"
      refunds = refunds.where { created_at <= end_normalised }
    end
    refunds
  end
  
  def self.total_count
  return Refund.count
  end

    # check if refund was approved 
  def resolved?
    return self.status == "Resolved"
  end

  def pending?
    return self.status == "Pending"
  end

  def get_order
    return Order.first(order_unique_id: self.order_id)
  end
    
  def get_amount
    if self.order_id
      order = Order.first(order_unique_id: self.order_id)
      return order.get_net_price if order
    elsif self.item_id
      item = ItemInOrder.get_item(self.item_id)
      return item.price_for_one.round(2) if item
    end
    return "N/A"
  end

  def get_product
  return Product.first(product_id: self.item_id)
  end

  def get_customer
    return Customer.first(loyalty_number: self.loyalty_number)
  end

  def get_customer_name
    cust = self.get_customer
    if cust.nil?
      return "Unknown"
    else
      return "#{cust.first_name} #{cust.last_name}"
    end
  end

  # Returns the barista who handled the order
  def get_processed_by
    order = self.get_order
    if order.nil?
      return "Unknown"
    else
      return order.barista
    end
  end

  def self.create_refund (loyalty_number, refund_reason, status, order_id, item_id)
    refund = Refund.new
    refund.loyalty_number = loyalty_number
    refund.refund_reason = refund_reason
    refund.status = status
    refund.created_at = Time.now.utc.to_s
    refund.order_id = order_id
    refund.item_id = item_id
    refund.save
    refund.refund_id
  end

  def approve
    self.update(status: "Resolved")
    if self.order_id
      order = Order.first(order_unique_id: self.order_id)
      order.refund unless order.nil?
    elsif self.item_id
      item = ItemInOrder.get_item(self.item_id)
      item.refund unless item.nil?
    end
  end

  def deny
    self.update(status: "Denied")
  end

end