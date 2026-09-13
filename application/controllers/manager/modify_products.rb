get "/manager/products/add-drinks" do
  @action = "add"
  @type = "drinks"
  @backto = params[:lastpage]

  @sizes = Size.offset(1)
  @milk_options = MilkOption.offset(1)
  
  erb :"manager/products/mngr_product_form"
end

get "/manager/products/add-beans" do
  @action = "add"
  @type = "beans"
  @backto = params[:lastpage]

  @countries = Country.offset(1)
  @roast_levels = RoastLevel.offset(1)
  
  erb :"manager/products/mngr_product_form"
end

get "/manager/products/update-drinks" do
  @action = "update"
  @id = params[:id]
  redirect "/manager/products/drinks" if !Product[@id]
  
  get_product_info(@id)
  @sizes = Size.offset(1)
  @milk_options = MilkOption.offset(1)
  
  erb :"manager/products/mngr_product_form"
end

get "/manager/products/update-beans" do
  @action = "update"
  @id = params[:id]
  redirect "/manager/products/beans" if !Product[@id]

  get_product_info(@id)
  @countries = Country.offset(1)
  @roast_levels = RoastLevel.offset(1)
  
  erb :"manager/products/mngr_product_form"
end

post "/manager/products/add-drinks" do
  product = Product.new
  @type = "drinks"
  @action = "add"
  
  result = Product.validate_inputs(params, @type, @action)
  params = result[0]
  @errors = result[1]

  unless @errors.empty?
    @backto = params[:lastpage]
    @sizes = Size.offset(1)
    @milk_options = MilkOption.offset(1)
    erb :"manager/products/mngr_product_form"
  else
    process_drinks(product, @action, params)
  end
end

post "/manager/products/add-beans" do
  product = Product.new
  @type = "beans"
  @action = "add"

  result = Product.validate_inputs(params, @type, @action)
  params = result[0]
  @errors = result[1]

  unless @errors.empty?
    @backto = params[:lastpage]
    @countries = Country.offset(1)
    @roast_levels = RoastLevel.offset(1)
    erb :"manager/products/mngr_product_form"
  else
    process_beans(product, @action, params)
  end
end

post "/manager/products/update-drinks" do
  product = Product[params[:id]]
  redirect "/manager/products/drinks" if !product

  @type = "drinks"
  @action = "update"

  result = Product.validate_inputs(params, @type, @action)
  params = result[0]
  @errors = result[1]

  unless @errors.empty?
    @id = params[:id]
    get_product_info(@id)
    @sizes = Size.offset(1)
    @milk_options = MilkOption.offset(1)
    erb :"manager/products/mngr_product_form"
  else
    process_drinks(product, @action, params)
  end
end

post "/manager/products/update-beans" do
  product = Product[params[:id]]
  redirect "/manager/products/beans" if !product

  @type = "beans"
  @action = "update"

  result = Product.validate_inputs(params, @type, @action)
  params = result[0]
  @errors = result[1]
  
  unless @errors.empty?
    @id = params[:id]
    get_product_info(@id)
    @countries = Country.offset(1)
    @roast_levels = RoastLevel.offset(1)
    erb :"manager/products/mngr_product_form"
  else
    process_beans(product, @action, params)
  end
end

def process_drinks(product, action, params)
  params[:origin] = 1
  params[:roast] = 1
  product.load(params)
  save = action == "add" ? :save : :save_changes
  product.send(save)

  @id = product.product_id
  
  image = params["image"]
  product.save_image_path(image)

  delete_unselected_drink_variants(product, params) if action == "update"
  save_drink_variants(product, params)
  
  redirect "/manager/products/drinks"
end

def save_drink_variants(product, params)
  selected_sizes = params[:size]
  selected_milks = params[:milk]
  selected_sizes.each do |size_id|
    numbers = price_and_cost_by_size(size_id)

    selected_milks.each do |milk_id|
      variant = ProductVariant.find_variant(@id, size_id, milk_id)
      if variant
        save_method = :save_changes
      else
        variant = ProductVariant.new
        save_method = :save
      end
      variant.load(@id, size_id, milk_id, numbers[:price], numbers[:cost])
      variant.send(save_method)
    end
  end
end

def delete_unselected_drink_variants(product, params)
  selected_pairs = params[:size].product(params[:milk]).map do |size_id, milk_id|
    [size_id.to_i, milk_id.to_i]
  end

  ProductVariant.where(product_id: product.product_id).each do |variant|
    pair = [variant.size_id, variant.milk_id]
    variant.delete unless selected_pairs.include?(pair)
  end
end

def price_and_cost_by_size(size_id)
  size = Size.get_size(size_id)
  numbers = {}
  case size
  when "Small"
    numbers[:price] = params[:price][0]
    numbers[:cost] = params[:cost][0]

  when "Regular"
    numbers[:price] = params[:price][1]
    numbers[:cost] = params[:cost][1]

  when "Large"
    numbers[:price] = params[:price][2]
    numbers[:cost] = params[:cost][2]
  end
  numbers
end

def process_beans(product, action, params)
  save = action == "add" ? :save : :save_changes
  product.load(params)
  product.send(save)

  id = product.product_id
  
  image = params["image"]
  product.save_image_path(image)

  variant = ProductVariant.find_variant(id, 1, 1)
  variant = ProductVariant.new unless variant
  variant.load(product.product_id, 1, 1, params[:price], params[:cost])
  variant.send(save)

  redirect "/manager/products/beans"
end

get "/manager/products/details" do
  @title = + "Product Details"
  @page = :"manager/products/mngr_product_details"
  @page_css = "product_details"

  @id = params[:id]
  redirect "/manager/products/drinks" if !Product[@id]
  get_product_info(@id)

  erb :"manager/common/mngr_template"
end

def get_product_info(id)
  @product = Product[id]
  @type = @product.type
  @name = @product.name
  @description = @product.description
  @image_path = @product.image_path
  @availability = @product.availability
  @status = @availability == 1 ? "Available" : "Unavailable"

  @type == "drinks" ? drinks_only_info(id) : beans_only_info(id)
end

def drinks_only_info(id)
  variants = ProductVariant.where(product_id: id)
  @prices = variants.as_hash(:size_id, :price)
  @costs = variants.as_hash(:size_id, :cost)

  @available_sizes = variants.distinct.select_map(:size_id)
  @sizes_string = @available_sizes.map { |size| Size.get_size(size) }.join(", ")
  @available_milk = variants.distinct.select_map(:milk_id)
  @milk_string = @available_milk.map { |milk| MilkOption.get_milk_name(milk) }.join(", ")
end

def beans_only_info(id)
  @origin_id = @product.origin
  @origin = Country.get_country_name(@origin_id)
  @roast_id = @product.roast_level
  @roast_level = RoastLevel.get_roast_level_name(@roast_id)
  variant = ProductVariant[product_id: id, size_id: 1, milk_id: 1]
  @price = variant.price
  @cost = variant.cost
  @stock = @product.stock_level
end

post "/manager/products/new-origin" do
  error = Country.validate_new_origin(params)
  input = params[:new_origin]
  adding_beans = params[:action] == "add"

  if error && adding_beans
    url = mngr_add_products_url(params, "beans", params[:lastpage])
    url += "&error=#{error}&origin_input=#{input}#add_origin"
    redirect url
  elsif error
    url = mngr_update_products_url(params[:id], "beans", params)
    url += "&error=#{error}&origin_input=#{input}#add_origin"
    redirect url
  else
    Country.new_origin(params[:new_origin])
    if adding_beans
      redirect mngr_add_products_url(params, "beans", params[:lastpage])
    else
      redirect mngr_update_products_url(params[:id], "beans", params)
    end
  end
end