class LoginTime < Sequel::Model
  # returns a customer's last 10 login times
  def self.get_customer_login_times(loyalty_number)
    LoginTime.where(loyalty_number: loyalty_number).reverse_order(:login_time).limit(10)
  end

  def self.record_new_login(loyalty_number, time)
    # DO VALIDATION?
    login = LoginTime.new
    login.loyalty_number = loyalty_number
    login.login_time = time
    login.save_changes
  end
end
