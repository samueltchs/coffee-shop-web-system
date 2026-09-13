class Product < Sequel::Model 
  include Validation
  extend Validation

  def load(params)
    self.type = params.fetch("type")
    self.name = params.fetch("pname")
    self.description = params.fetch("description")
    self.availability = params.fetch("availability")

    self.stock_level = params.fetch("stock", nil)
    self.origin = params.fetch("origin", 1)
    self.roast_level = params.fetch("roast", 1)
  end

  def self.validate_inputs(params, type, action)
    errors = {}
    #did not normalize number as "" will become 0
    params = normalize_non_numbers(params, type)
    errors = check_input_empty(errors, params, type)

    need_image = params[:image].to_s.strip.empty? && action == "add"
    errors[:image] = "Please upload an image" if need_image

    return [params, errors] unless errors.empty?

    params = normalize_numbers(params, type)
    errors = validate_common(errors, params)
    if type == "drinks"
      errors = validate_drinks_properties(errors, params)
    elsif type == "beans"
      errors = validate_beans_properties(errors, params)
    end
    [params, errors]
  end

  def self.validate_common(errors, params)
    msg = "Product Name cannot exceed 40 characters"
    errors[:pname] = msg unless str_max_length?(params[:pname], 40)
    msg = "Description cannot exceed 500 characters"
    errors[:description] = msg unless str_max_length?(params[:description], 500)
    
    image = params[:image]
    if image 
      correct_type = ["image/jpeg", "image/png", "image/webp"].include?(image[:type])
      errors[:image] = "Invalid image type" unless correct_type
    end
    errors
  end

  def self.validate_drinks_properties(errors, params)
    valid_prices = params[:price].all? { |p| p >= 0 && p <= 300 }
    errors[:price] = "Prices must be between 0 and 300" unless valid_prices
    valid_costs = params[:cost].all? { |c| c >= 0 && c <= 300 }
    errors[:cost] = "Costs must be between 0 and 300" unless valid_costs
    valid_milks = params[:milk].all? { |m| MilkOption.select_map(:id).include?(m) }
    errors[:milk] = "Invalid milk option input" unless valid_milks
    errors
  end

  def self.validate_beans_properties(errors, params)
    price = params[:price]
    valid_price = price >= 0 && price <= 300
    errors[:price] = "Price must be between 0 and 300" unless valid_price

    cost = params[:cost]
    valid_cost = cost >= 0 && cost <= 300
    errors[:cost] = "Cost must be between 0 and 300" unless valid_cost

    stock = params[:stock]
    valid_stock = stock >= 0 && stock <= 1000
    errors[:stock] = "Stock level must be between 0 and 1000" unless valid_stock

    valid_roast = RoastLevel.select_map(:id).include?(params[:roast])
    errors[:roast] = "Invalid roast level" unless valid_roast

    valid_origin = Country.select_map(:id).include?(params[:origin])
    errors[:origin] = "Invalid origin" unless valid_origin
    errors
  end

  def self.normalize_non_numbers(params, type)
    params = normalize_strings(params, type)
    params = normalize_checkboxes(params, type)
    params
  end

  def self.normalize_strings(params, type)
    params[:type] = type
    params[:pname] = params[:pname].to_s.strip
    params[:description] = params[:description].to_s.strip
    params
  end
  
  def self.normalize_numbers(params, type)
    if type == "drinks"
      params[:price] = Array(params[:price]).map(&:to_f)
      params[:cost] = Array(params[:cost]).map(&:to_f)
    elsif type == "beans"
      params[:price] = params[:price].to_f
      params[:cost] = params[:cost].to_f
      params[:stock] = params[:stock].to_i
      params[:roast] = params[:roast].to_i
      params[:origin] = params[:origin].to_i
    end
    params
  end

  def self.normalize_checkboxes(params, type)
    params[:availability] = params[:availability].to_s.to_i
    return params unless type == "drinks"

    params[:size] = Array(params[:size]).map(&:to_i)
    params[:milk] = Array(params[:milk]).map(&:to_i)
    params
  end

  def self.check_input_empty(errors, params, type)
    errors = check_strings_empty(errors, params)
    errors = check_numbers_empty(errors, params, type)
    errors
  end

  def self.check_strings_empty(errors, params)
    errors[:pname] = "Product Name cannot be empty" if params[:pname].empty?
    errors[:description] = "Description cannot be empty" if params[:description].empty?
    errors
  end

  def self.check_numbers_empty(errors, params, type)
    errors = check_drinks_numbers_empty(errors, params) if type == "drinks"
    errors = check_beans_numbers_empty(errors, params) if type == "beans"
    errors
  end

  def self.check_drinks_numbers_empty(errors, params)
    prices = Array(params[:price])
    costs = Array(params[:cost])
    sizes = Array(params[:size])
    milks = Array(params[:milk])

    valid_sizes = params[:size].all? { |s| Size.select_map(:id).include?(s) }
    errors[:size] = "Invalid size input" unless valid_sizes

    if sizes.empty?
      errors[:size] = "Please select at least one size"
    else
      sizes.each do |size|
        index = size.to_i - 2
        msg = "Please fill in price for all selected sizes"
        errors[:price] ||= msg if prices[index].to_s.strip.empty?
        msg = "Please fill in cost for all selected sizes"
        errors[:cost] ||= msg if costs[index].to_s.strip.empty?
      end
    end
    errors[:milk] = "Please select at least one milk option" if milks.empty?
    errors
  end

  def self.check_beans_numbers_empty(errors, params)
    errors[:price] = "Price cannot be empty" if params[:price].strip.empty?
    errors[:cost] = "Cost cannot be empty" if params[:cost].strip.empty?
    errors[:stock] = "Stock level cannot be empty" if params[:stock].strip.empty?
    errors[:roast] = "Please select a roast level" if params[:roast].strip.empty?
    errors[:origin] = "Please select an origin" if params[:origin].strip.empty?
    errors
  end

  def save_image_path(image)
    return unless image && image["tempfile"]
    imagefile = image["tempfile"]
    ext = File.extname(image["filename"])
    
    unless self.image_path.to_s.empty?
      old_path = "public" + self.image_path
      File.delete(old_path) if File.exist?(old_path)
    end

    save_path = "public/images/product_images/#{self.product_id}_#{Time.now.to_i}#{ext}"
    FileUtils.mv(imagefile.path, save_path)
    self.image_path = save_path.delete_prefix("public")
    self.save_changes
  end
  
  def self.get_product_by_id(product_id)
    return Product.first(product_id: product_id)
  end
  
  def self.get_available_product_by_id(product_id)
    return Product.first(product_id: product_id, availability: 1)
  end

  def self.get_type_by_id(product_id)
    product = get_product_by_id(product_id)
    product.type
  end

  def self.get_name_by_id(product_id)
    Product[product_id]&.name
  end
  
  def self.product_exists?(product_id)
    return !Product.get_product_by_id(product_id).nil?
  end
    
  def self.get_bean_by_id(product_id)
    prod = Product.get_product_by_id(product_id)
    if prod.type == "beans"
      return prod
    else
      return nil
    end
  end
  
  def self.get_all_products() 
    return Product.all
  end

  def self.get_all_id_by_type(type)
    Product.where(type: type).select_map(:product_id)
  end

  def reduce_quantity(amount)
    stock = self.stock_level
    unless self.stock_level.nil?
      stock -= amount
      stock = 0 if stock < 0 
      self.update(stock_level: stock)
    end
    stock
  end

  def increase_quantity(amount)
    unless self.stock_level.nil?
      stock = self.stock_level + amount
      self.update(stock_level: stock)
      stock
    end
  end  

  def in_stock?()
    # drinks don't have stock levels, assume they're in stock
    return self.stock_level.nil? ? true : self.stock_level > 0
  end
  
  def self.get_all_available_products()
    return Product.where(availability: 1)
  end
  
  def self.get_beans()
    return Product.where(type: "beans", availability: 1)
  end

  def self.search_beans(search_term)
    return Product.where(Sequel[{type: "beans", availability: 1}] & Sequel.ilike(:name, "%" + search_term + "%"))
  end

  def self.search_products(search_term, category)
    case category
    when "beans"
      return Product.where(Sequel[{availability: 1, type: "beans"}] & Sequel.ilike(:name, "%" + search_term + "%"))
    when "drinks"
      return Product.where(Sequel[{availability: 1, type: "drinks"}] & Sequel.ilike(:name, "%" + search_term + "%"))
    else
      return Product.where(Sequel[{availability: 1}] & Sequel.ilike(:name, "%" + search_term + "%"))
    end
  end

  def get_milk_options_with_id()
    options = Set[] 
    ProductVariant.where(product_id: product_id).each do |variant|
      options.add(MilkOption.first(id: variant.milk_id))
    end
    return options.to_a
  end

  def get_size_options_with_id()
    options = Set[] 
    ProductVariant.where(product_id: product_id).each do |variant|
      options.add(Size.first(id: variant.size_id))
    end
    return options.to_a
  end

  def self.get_drinks()
    return Product.where(type: "drinks")
  end

  def self.get_drinks()
    return Product.where(type: "drinks")
  end
  
  def is_bean?()
    return self.type == "beans"
  end
  
  def is_drink?()
    return self.type == "drinks"
  end
  
  def available?()
    return self.availability == 1
  end
  
  def get_image_path()
    default_path = "icons/coffee-bean.svg"
    return self.image_path == "" || self.image_path.nil? ? default_path : self.image_path
  end
  
  def self.add_to_cart(product_id, amount)
    product = Product.first(product_id: product_id)
    unless product.stock_level - amount < 0
      product.stock_level -= amount;
    end
    return product
  end
  
  def has_milk?
    variants = ProductVariant.where(product_id: self.product_id)
    variants.each do |variant|
      return true if variant.milk_id != 1
    end
    return false
  end

  def get_milk_options
    variants = ProductVariant.where(product_id: self.product_id)
    names = Array.new 0;
    variants.each do |variant|
      id = variant.milk_id
      name = MilkOption.get_milk_name(id)
      names << name unless names.include? name
    end
    return names unless names.size.zero?
    return nil
  end

  def get_size_options
    variants = ProductVariant.where(product_id: self.product_id)
    names = Array.new 0;
    variants.each do |variant|
      id = variant.size_id
      name = Size.get_size(id)
      names << name unless names.include? name
    end
    return names unless names.size.zero?
    return nil
  end

  def get_all_variants
    ProductVariant.where(product_id: self.product_id)
  end

  def self.product_name_column
    Sequel.case(
      { { Sequel[:sizes][:size] => nil } => Sequel[:products][:name] },
      Sequel.join([Sequel[:sizes][:size], Sequel[:products][:name]], ' ')
    )
  end
  
  def self.join_tables_products_and_variants
    ProductVariant
      .join(:products, product_id: :product_id)
      .left_join(:sizes, id: Sequel[:product_variants][:size_id])
      .select(
        Sequel[:products][:product_id],
        Sequel[:products][:type],
        product_name_column.as(:name),
        Sequel[:product_variants][:price],
        Sequel[:product_variants][:cost],
        Sequel[:products][:stock_level],
        Sequel[:products][:availability]
      ).distinct
  end
  #get a dataset for sorting in Manager Products
  def self.joined_table_by_type(type)
    join_tables_products_and_variants.where(Sequel[:products][:type] => type)
  end

  def get_size_variant(size)
    #ProductSizeVariant.first(product_id: self.product_id, size: size)
  end

  def bean_variant
    if is_bean?
      return ProductVariant.find_variant(product_id, 1, 1) 
    else
      return nil
    end
  end

  # get the price of a bean
  def get_bean_price()
    if is_bean?
      return bean_variant.price
    else
      # this is a drink, so may come in several sizes
      return nil
    end
  end

  # get the cost of a bean
  def get_bean_cost()
    if is_bean?
      return bean_variant.cost
    else
      # this is a drink, so may come in several sizes
      return nil
    end
  end


  # get the price of a bean as a formatted string (ie 2 decimal places)
  def get_bean_price_string()
    if is_bean?
      return bean_variant.get_price_string
    else
      return nil
    end
  end

  # get the origin (as a string) for this bean
  def get_origin
    if is_bean?
      return Country.get_country_name(origin)
    else
      return nil  # drinks don't list origin 
    end
  end

  # get the roast level (as a string) for this bean
  def get_roast_level
    if is_bean?
      return RoastLevel.get_roast_level_name(roast_level)
    else
      return nil  # drinks don't list roast level
    end
  end
end