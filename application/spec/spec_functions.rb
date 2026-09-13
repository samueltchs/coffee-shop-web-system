SECONDS_IN_DAY = 60 * 60 * 24
SECONDS_IN_MONTH = SECONDS_IN_DAY * 30

def spec_before
  DiscountRedemption.dataset.delete
  Employee.dataset.delete
  Customer.dataset.delete
  SuspensionReason.dataset.delete
  DeletionReason.dataset.delete
  Refund.dataset.delete
  ItemInOrder.dataset.delete
  Order.dataset.delete
  PaymentMethod.dataset.delete
  LoginTime.dataset.delete
  Favourite.dataset.delete
  RecentView.dataset.delete
  ProfileUpdate.dataset.delete
  FreeCoffeeRedemption.dataset.delete
  ProductVariant.dataset.delete
  Product.dataset.delete
  BasketItem.dataset.delete
  OrderStatusAudit.dataset.delete
  Size.dataset.delete
  MilkOption.dataset.delete
  DiscountCode.dataset.delete
  EligiblePurchaseType.dataset.delete
  EligibleRule.dataset.delete
  add_default_discount_options_to_db
  Country.dataset.delete
  RoastLevel.dataset.delete
  PromotionItem.dataset.delete
  Promotion.dataset.delete
  Complaint.dataset.delete
  add_default_reasons_to_db
end

def add_test_customer_to_db(loyalty_number = 1, first_name = "Mikel", last_name = "Merino",
                            address_line_1 = "address1", address_line_2 = "address2", city = "Sheffield",
                            postcode = "S1 1AA", phone_number = "7710002000", email = "email@gmail.com", 
                            stamps = 0, registered_time = Time.now.utc, status = "Active")
  customer = Customer.new

  customer.loyalty_number = loyalty_number
  customer.first_name = first_name
  customer.last_name = last_name
  customer.password = "validPass7!"
  customer.address_line_1 = address_line_1
  customer.address_line_2 = address_line_2
  customer.city = city
  customer.postcode = postcode
  customer.phone_number = phone_number
  customer.email = email
  customer.stamps = stamps
  customer.registered_time = registered_time
  customer.status = status
  customer.save_changes

  customer
end

def add_flagged_customer_to_db(loyalty_number = 2, flagged_at = Time.now.utc,
                               registered_time = Time.now.utc - SECONDS_IN_MONTH * 6)
  flagged_customer = add_test_customer_to_db(loyalty_number)

  flagged_customer.registered_time = registered_time
  flagged_customer.status = "Flagged"
  flagged_customer.flagged_at = flagged_at
  flagged_customer.save_changes

  flagged_customer
end

def add_suspended_customer_to_db(loyalty_number = 3, flagged_at = Time.now.utc - SECONDS_IN_DAY * 5,
                                 suspended_at = Time.now.utc, suspension_reason_id = 1)
  suspended_customer = add_flagged_customer_to_db(loyalty_number, flagged_at)

  suspended_customer.status = "Suspended"
  suspended_customer.suspended_at = suspended_at
  suspended_customer.suspension_reason_id = suspension_reason_id
  suspended_customer.save_changes

  suspended_customer
end

def add_deleted_customer_to_db(loyalty_number = 4, deletion_reason_id = 1)
  deleted_customer = add_suspended_customer_to_db(loyalty_number)

  deleted_customer.status = "Deleted"
  deleted_customer.flagged_at = nil
  deleted_customer.suspended_at = nil
  deleted_customer.deleted_at = Time.now.utc
  deleted_customer.deletion_reason_id = deletion_reason_id
  deleted_customer.save_changes

  deleted_customer
end

# logs into the customer testing account, unless it doesn't exist, in which case it creates it then logs in
def log_in_test_customer
  add_test_customer_to_db
end

def add_test_admin_to_db(username = "admin", first_name = "Craig", last_name = "Johnson", 
                         email = "admin@gmail.com", role = "Admin")
  add_test_employee_to_db(username, first_name, last_name, email, role)
end

def add_test_barista_to_db(username = "barista", first_name = "George", last_name = "Michael", 
                           email = "barista@gmail.com", role = "Barista")
  add_test_employee_to_db(username, first_name, last_name, email, role)
end

def add_test_manager_to_db(username = "manager", first_name = "Michael", last_name = "Carrick", 
                           email = "manager@gmail.com", role = "Manager")
  add_test_employee_to_db(username, first_name, last_name, email, role)
end

def add_deleted_employee_to_db(username = "deleted578684", first_name = "Deleted", 
                               last_name = "BlxZtT", email = "deleted@gmail.com", role = "Deleted")
  deleted_employee = Employee.new

  deleted_employee.username = username
  deleted_employee.first_name = first_name
  deleted_employee.last_name = last_name
  deleted_employee.email = email
  deleted_employee.pass = "validPass7!"
  deleted_employee.conf_pass = "validPass7!"
  deleted_employee.password = "validPass7!"
  deleted_employee.role = role
  deleted_employee.registered_time = nil
  deleted_employee.deleted_at = Time.now.utc
  deleted_employee.save_changes

  deleted_employee
end

def add_test_employee_to_db(username = "employee_test", first_name = "Alex", last_name = "Brady",
                            email = "employee@gmail.com", role = "Barista")
  employee = Employee.new

  employee.username = username
  employee.first_name = first_name
  employee.last_name = last_name
  employee.email = email
  employee.pass = "validPass7!"
  employee.conf_pass = "validPass7!"
  employee.password = "validPass7!"
  employee.role = role
  employee.registered_time = Time.now.utc
  employee.save_changes

  employee
end

def add_test_order_to_db(loyalty_number = 1, date_placed = Time.now.utc,
                         cost = 7.3, price = 7.7, tracking_id = 1, reference_id = "ABC12345", 
                         barista = "Online", delivered = 1, order_fulfilment = "Completed", 
                         status = "Paid", discount_code_used = "", net_price = 7.5, percentage_off = nil)
  order = Order.new

  order.loyalty_number = loyalty_number
  order.date_placed = date_placed
  order.cost = cost
  order.price = price
  order.net_price = net_price
  order.tracking_id = tracking_id
  order.reference_id = reference_id
  order.barista = barista
  order.delivered = delivered
  order.order_fulfilment = order_fulfilment
  order.status = status
  order.discount_code_used = discount_code_used
  order.percentage_off = percentage_off
  order.save_changes

  order
end

def add_test_orders_for_mngr_customers
  order1 = add_test_order_to_db(
    @customer.loyalty_number, "2026-04-20 21:37:56 +0000", "10", "20", "1",
    "ABC00001", "Online", "1", "Completed", "Paid",
    nil, "20", nil
  )
  
  order2 = add_test_order_to_db(
    @customer.loyalty_number, "2026-04-21 21:37:56 +0000", "10", "32", "1",
    "ABC00001", "Online", "1", "Completed", "Paid",
    nil, "32", nil
  )
  
  order3 = add_test_order_to_db(
    @customer.loyalty_number, "2026-04-21 21:37:56 +0000", "10", "64", "1",
    "ABC00001", "Online", "1", "Completed", "Paid",
    nil, "64", nil
  )

  return order1, order2, order3
end

def create_employee(username = "user", first_name = "Garry", last_name = "Evans", email = "email@gmail.com",
                    role = "Barista", password = "validPass7!", conf_password = "validPass7!")
  employee = Employee.new

  employee.username = username
  employee.first_name = first_name
  employee.last_name = last_name
  employee.email = email
  employee.role = role
  employee.pass = password
  employee.conf_pass = conf_password
  employee.registered_time = Time.now.utc

  employee
end

def get_as_employee(employee, path, params = {})
  get path, params, { "rack.session" => { username: employee.username, role: employee.role } }
end

def post_as_employee(employee, path, params = {})
  post path, params, { "rack.session" => { username: employee.username, role: employee.role } }
end

# get / post as customer
def get_as_customer_logged_in(path, params = {})
  cust = log_in_test_customer
  get path, params, { "rack.session" => { "logged_in": true, "current_customer": cust, "loyalty_number": cust.loyalty_number } }
end

def post_as_customer_logged_in(path, params = {})
  cust = log_in_test_customer
  post path, params, { "rack.session" => { "logged_in": true, "current_customer": cust } }
end

def get_as_customer_not_logged_in(path, params = {})
  get path, params, { "rack.session" => { "logged_in": false, "current_customer": nil } }
end

def post_as_customer_not_logged_in(path, params = {})
  post path, params, { "rack.session" => { "logged_in": false, "current_customer": nil } }
end

#To be used with capybara
def login_as_employee(employee)
  visit "/employee-login-page"
  fill_in "username", with: employee.username
  fill_in "password", with: "validPass7!"
  click_on "Log-in"
end

def login_as_customer(customer)
  visit "/login"
  fill_in "email", with: customer.email
  fill_in "password", with: "validPass7!"
  click_on "Submit"
end

def add_test_recent_view_to_db(loyalty_number = 1, item_id = 1, time_viewed = Time.now.utc, name = "Latte")
  recent_view = RecentView.new

  recent_view.loyalty_number = loyalty_number
  recent_view.item_id = item_id
  recent_view.time_viewed = time_viewed
  recent_view.name = name
  recent_view.save_changes

  recent_view
end

def add_test_profile_update_to_db(loyalty_number = 1, field_updated = "city", old_value = "Manchester",
                                  new_value = "Sheffield", time_updated = Time.now.utc)
  profile_update = ProfileUpdate.new

  profile_update.loyalty_number = loyalty_number
  profile_update.field_updated = field_updated
  profile_update.old_value = old_value
  profile_update.new_value = new_value
  profile_update.time_updated = time_updated
  profile_update.save_changes

  profile_update
end

def add_test_favourite_to_db(loyalty_number = 1, item_id = 1, name = "Latte", time_favourited = Time.now.utc)
  favourite = Favourite.new

  favourite.loyalty_number = loyalty_number
  favourite.item_id = item_id
  favourite.name = name
  favourite.time_favourited = time_favourited
  favourite.save_changes

  favourite
end

def add_test_login_time_to_db(loyalty_number = 1, login_time = Time.now.utc)
  login = LoginTime.new

  login.loyalty_number = loyalty_number
  login.login_time = login_time
  login.save_changes

  login
end

def add_test_item_in_order_to_db(item_id = 1, order_unique_id = 1, price_for_one = 3.7,
                                 quantity = 1, size_id = 1, milk_id = 1)
  item = ItemInOrder.new

  item.item_id = item_id
  item.order_unique_id = order_unique_id
  item.price_for_one = price_for_one
  item.quantity = quantity
  item.size_id = size_id
  item.milk_id = milk_id
  item.save_changes

  item
end

def add_test_product_to_db(type = "drinks", name = "Latte", stock_level = nil, availability = 1, 
                           origin = 1, roast_level = 1, description = "", image_path = "")
  product = Product.new

  product.type = type
  product.name = name
  product.stock_level = stock_level
  product.availability = availability
  product.origin = origin
  product.roast_level = roast_level
  product.description = description
  product.image_path = image_path
  product.save_changes

  product
end

def add_test_product_variant_to_db(product_id = 1, size_id = 1, milk_id = 1,
                                   price = 3.7, cost = 2.7)
  variant = ProductVariant.new

  variant.product_id = product_id
  variant.size_id = size_id
  variant.milk_id = milk_id
  variant.price = price
  variant.cost = cost
  variant.save_changes

  variant
end

def add_drink_with_multiple_sizes_to_db
  product = add_test_product_to_db
  variants = []
  price = 3.2
  cost = 2.5
  (2..4).each do |i| 
    variants << add_test_product_variant_to_db(product.product_id, i, 3, price, cost)
    price += 0.8
    cost += 0.5
  end
  return product, variants
end

def add_test_sort_drinks_to_db
  add_default_product_options_to_db

  product1 = add_test_product_to_db("drinks", "Latte", nil, 1)
  p1_variant1 = add_test_product_variant_to_db(
    product1.product_id, 2, 3, 3.8, 2.68
  )
  p1_variant2 = add_test_product_variant_to_db(
    product1.product_id, 3, 3, 4.2, 3.24
  )
  p1_size1 = Size.get_size(p1_variant1.size_id)
  p1_size2 = Size.get_size(p1_variant2.size_id)
  p1_size1_name = p1_size1 + " " + product1.name
  p1_size2_name = p1_size2 + " " + product1.name

  product2 = add_test_product_to_db("drinks", "Americano", nil, 1)
  p2_variant = add_test_product_variant_to_db(
    product2.product_id, 3, 2, 4, 3.14
  )
  p2_size = Size.get_size(p2_variant.size_id)
  p2_size_name = p2_size + " " + product2.name

  return p1_size1_name, p1_size2_name, p2_size_name
end

def add_test_search_drinks_to_db
  add_default_product_options_to_db

  product1 = add_test_product_to_db("drinks", "Latte", nil, 1)
  p1_variant1 = add_test_product_variant_to_db(
    product1.product_id, 2, 3, 3.8, 2.68
  )
  p1_variant2 = add_test_product_variant_to_db(
    product1.product_id, 3, 3, 4.2, 3.24
  )
  p1_size1 = Size.get_size(p1_variant1.size_id)
  p1_size2 = Size.get_size(p1_variant2.size_id)
  latte = {
    product: product1,
    small: p1_size1 + " " + product1.name,
    regular: p1_size2 + " " + product1.name
  }

  product2 = add_test_product_to_db("drinks", "Americano", nil, 1)
  p2_variant = add_test_product_variant_to_db(
    product2.product_id, 3, 2, 4, 3.14
  )
  p2_size = Size.get_size(p2_variant.size_id)
  americano = {
    product: product2,
    regular: p2_size + " " + product2.name
  }

  product3 = add_test_product_to_db("drinks", "Mocha", nil, 0)
  p3_variant = add_test_product_variant_to_db(
    product3.product_id, 3, 3, 4.2, 3.2
  )
  p3_size = Size.get_size(p3_variant.size_id)
  mocha = {
    product: product3,
    regular: p3_size + " " + product3.name
  }

  return latte, americano, mocha
end

def add_test_bean_to_db
  product = add_test_product_to_db("beans", "Test Beans", 50, 1, 2, 2)
  variant = add_test_product_variant_to_db(product.product_id, 1, 1, 22.99, 15.33)
  return product, variant
end

def add_test_sort_beans_to_db
  add_default_product_options_to_db

  bean_a = add_test_product_to_db("beans", "A Bean", 80, 1, 2, 2)
  variant_a = add_test_product_variant_to_db(bean_a.product_id, 1, 1, 40, 20)
  bean_z = add_test_product_to_db("beans", "Z Bean", 20, 1, 2, 2)
  variant_z = add_test_product_variant_to_db(bean_z.product_id, 1, 1, 35, 25)

  return [bean_a, variant_a], [bean_z, variant_z]
end

def add_test_search_beans_to_db
  add_default_product_options_to_db

  bean = add_test_product_to_db("beans", "Arabic Medium", 80, 1, 2, 3)
  arabic = {
    bean: bean,
    variant: add_test_product_variant_to_db(bean.product_id, 1, 1, 40, 20)
  }

  bean = add_test_product_to_db("beans", "Ethiopian Light", 20, 1, 4, 2)
  ethiopian = {
    bean: bean,
    variant: add_test_product_variant_to_db(bean.product_id, 1, 1, 35, 25)
  }
  
  bean = add_test_product_to_db("beans", "Brazilian Dark", 35, 0, 3, 4)
  brazilian = {
    bean: bean,
    variant: add_test_product_variant_to_db(bean.product_id, 1, 1, 38, 17)
  }

  return arabic, ethiopian, brazilian
end

def add_default_product_options_to_db
  add_default_sizes_to_db
  add_default_milk_options_to_db
  add_default_origins_to_db
  add_default_roast_levels_to_db
end

def add_default_sizes_to_db
  DB[:sizes].insert(size: "N/A")
  DB[:sizes].insert(size: "Small")
  DB[:sizes].insert(size: "Regular")
  DB[:sizes].insert(size: "Large")
end

def add_default_milk_options_to_db
  DB[:milk_options].insert(milk: "N/A")
  DB[:milk_options].insert(milk: "No Milk")
  DB[:milk_options].insert(milk: "Whole Milk")
  DB[:milk_options].insert(milk: "Soy Milk")
  DB[:milk_options].insert(milk: "Oat Milk")
end

def add_default_origins_to_db
  DB[:countries].insert(country: "N/A")
  DB[:countries].insert(country: "Arabic")
  DB[:countries].insert(country: "Brazilian")
  DB[:countries].insert(country: "Ethiopian")
end

def add_default_roast_levels_to_db
  DB[:roast_levels].insert(roast_level: "N/A")
  DB[:roast_levels].insert(roast_level: "Light")
  DB[:roast_levels].insert(roast_level: "Medium")
  DB[:roast_levels].insert(roast_level: "Dark")
end

def add_default_reasons_to_db
  add_test_suspension_reason_to_db(1, "Inactivity")
  add_test_suspension_reason_to_db(2, "Disciplinary")
  add_test_deletion_reason_to_db(1, "Inactivity")
  add_test_deletion_reason_to_db(2, "Disciplinary")
end

def test_drink_params(id: nil, pname: "Latte", type: "drinks", description: "Espresso with milk",
                      image: Rack::Test::UploadedFile.new("spec/test_images/latte.png", "image/png"),
                      price: ["4.2", "4.5", "4.8"], cost: ["1.0", "1.2", "1.4"],
                      availability: "1", size: ["2", "3", "4"], milk: ["3", "4", "5"])
  params = {
    id: id,
    pname: pname,
    type: type,
    description: description,
    image: image,
    price: price,
    cost: cost,
    availability: availability,
    size: size,
    milk: milk
  }
end

def test_bean_params(id: nil, pname: "Arabic Light", type: "beans", description: "Some beans",
                     origin: "2", roast: "2", stock: "50",
                     image: Rack::Test::UploadedFile.new("spec/test_images/arabic_light.png", "image/png"),
                     price: "40", cost: "20", availability: "1")
  params = {
    id: id,
    pname: pname,
    type: type,
    description: description,
    origin: origin,
    roast: roast,
    stock: stock,
    image: image,
    price: price,
    cost: cost,
    availability: availability
  }
end

def add_test_suspension_reason_to_db(id = 1, reason = "Inactivity")
  suspension_reason = SuspensionReason.new

  suspension_reason.id = id
  suspension_reason.reason = reason
  suspension_reason.save_changes

  suspension_reason
end

def add_test_deletion_reason_to_db(id = 1, reason = "Inactivity")
  deletion_reason = DeletionReason.new

  deletion_reason.id = id
  deletion_reason.reason = reason
  deletion_reason.save_changes

  deletion_reason
end

def add_test_basket_item_to_db(loyalty_number = 1, product_id = 1, quantity = 1, milk_id = 1, size_id = 1)
  basket_item = BasketItem.new

  basket_item.loyalty_number = loyalty_number
  basket_item.product_id = product_id
  basket_item.quantity = quantity
  basket_item.milk_id = milk_id
  basket_item.size_id = size_id
  basket_item.save_changes

  basket_item
end

def add_test_free_coffee_redemption_to_db(loyalty_number = 1, redeem_timestamp = "", product_id = 1,
                                          size_id = 1, milk_id = 1)
  coffee_redemption = FreeCoffeeRedemption.new

  coffee_redemption.loyalty_number = loyalty_number
  coffee_redemption.redeem_timestamp = redeem_timestamp
  coffee_redemption.product_id = product_id
  coffee_redemption.size_id = size_id
  coffee_redemption.milk_id = milk_id
  coffee_redemption.save_changes

  coffee_redemption
end

def add_test_refund_to_db(loyalty_number = 1, refund_reason = "", status = "", created_at = Time.now.utc)
  refund = Refund.new

  refund.loyalty_number = loyalty_number
  refund.refund_reason = refund_reason
  refund.status = status
  refund.created_at = created_at
  refund.save_changes

  refund
end

def add_test_discount_code_to_db(discount_code: "COFFEE20", campaign_name: "Coffee Lovers Deal", 
                                 percentage_off: "20", eligible_type: "2", eligible_rule: "2", 
                                 eligible_min: "5.00", valid_purchase_date_from: "2026-03-01", 
                                 valid_purchase_date_to: "2026-06-30", code_expiry_date: "2026-08-31", 
                                 is_active: "1")

  code = DiscountCode.new
  code.discount_code = discount_code
  code.campaign_name = campaign_name
  code.percentage_off = percentage_off
  code.eligible_type = eligible_type
  code.eligible_rule = eligible_rule
  code.eligible_min = eligible_min
  code.valid_purchase_date_from = valid_purchase_date_from
  code.valid_purchase_date_to = valid_purchase_date_to
  code.code_expiry_date = code_expiry_date
  code.is_active = is_active
  code.save

  code
end

def test_discount_params(code: "COFFEE20", name: "Coffee Lovers Deal", 
                         percentage: "20", pur_type: "2", elig_rule: "2", 
                         min_amount: "5.00", from: "2026-03-01", 
                         to: "2026-06-30", expiry: "2026-08-31", 
                         status: "1", action: "create", viewcode: nil)
  params = {
    code: code,
    name: name,
    percentage: percentage,
    pur_type: pur_type,
    elig_rule: elig_rule,
    min_amount: min_amount,
    from: from,
    to: to,
    expiry: expiry,
    status: status,
    action: action,
    viewcode: viewcode
  }
end

def add_default_discount_options_to_db
  DB[:eligible_purchase_types].insert(type: "Both")
  DB[:eligible_purchase_types].insert(type: "Drinks Only")
  DB[:eligible_purchase_types].insert(type: "Beans Only")

  DB[:eligible_rules].insert(rule: "Amount of Purchase")
  DB[:eligible_rules].insert(rule: "Quantity of Products")
end

def add_test_discount_eligible_customer_and_order
  add_test_customer_to_db
  #latte with all sizes, whole milk
  add_default_product_options_to_db
  add_drink_with_multiple_sizes_to_db
  add_test_order_to_db(1, "2026-04-10 10:00:00 +0100", "15", "19.2", "1", "ABC12345", 
                       "Online", "1", "Completed", "Paid", nil, "19.2")
  add_test_item_in_order_to_db("1", "1", "3.2", "6", "2", "3")
end

def add_test_update_discount_eligible_customer_and_order
  add_test_discount_eligible_customer_and_order
  add_test_customer_to_db(
    2, "Discount", "Tester", "address1", "address2", "Sheffield",
    "S1 1AA", "7710002012", "discount@gmail.com", 
    0, Time.now.utc, "Active"
  )
  add_test_order_to_db(
    2, "2026-04-11 10:00:00 +0100", "25", "32", "2", "ABC23435", 
    "Online", "1", "Completed", "Paid", nil, "32"
  )
  add_test_item_in_order_to_db("1", "2", "3.2", "10", "2", "3")
end

def add_test_discount_redemption_to_db(loyalty_number = 1, code = "COFFEE20", is_redeemed = 1)
  discount_redemption = DiscountRedemption.new

  discount_redemption.loyalty_number = loyalty_number
  discount_redemption.code = code
  discount_redemption.is_redeemed = is_redeemed
  discount_redemption.save_changes

  discount_redemption
end

def add_test_promotion_to_db(loyalty_number = 1, sent_at = Time.now.utc)
  promotion = Promotion.new

  promotion.loyalty_number = loyalty_number
  promotion.sent_at = sent_at
  promotion.save_changes

  promotion
end

def add_test_complaint_to_db(loyalty_number = 1, complaint_text = "", status = "", created_at = Time.now.utc)
  complaint = Complaint.new

  complaint.loyalty_number = loyalty_number
  complaint.complaint_text = complaint_text
  complaint.status = status
  complaint.created_at = created_at
  complaint.save_changes

  complaint
end

def add_test_size_to_db(size = "large")
  size_record = Size.new

  size_record.size = size
  size_record.save_changes

  size_record
end

def add_test_milk_option_to_db(milk = "Whole")
  milk_option = MilkOption.new

  milk_option.milk = milk
  milk_option.save_changes

  milk_option
end

def add_test_country_to_db(country = "N/A")
  country_record = Country.new

  country_record.country = country
  country_record.save_changes

  country_record
end

def add_test_roast_level_to_db(roast_level = "N/A")
  roast = RoastLevel.new

  roast.roast_level = roast_level
  roast.save_changes

  roast
end

# FOR SHOP TESTING
def setup_shop()
  add_default_product_options_to_db
  add_test_bean_to_db
  add_drink_with_multiple_sizes_to_db
end

def favourite_test_bean()
  Favourite.add_new_favourite(1, 1)
end

def unfavourite_all()
  Favourite.dataset.delete
end

def search_for_test_bean()
  visit("/shop/search")
  fill_in "search-term", with: "Test Beans"
  click_on "Search"
end

def add_test_beans_to_basket()
  visit("/shop/product?product_id=1")
  click_button "Add to Basket"
end