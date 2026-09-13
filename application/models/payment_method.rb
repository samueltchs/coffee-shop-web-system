class PaymentMethod < Sequel::Model
  
  def self.get_name(id)
    method = self.first(id: id)
    return method.payment_method if method
    return nil
  end

  def self.get_id(name)
    method = self.first(payment_method: name)
    return method.id if method
    return nil
  end

end