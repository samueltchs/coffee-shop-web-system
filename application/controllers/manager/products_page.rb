get "/manager/products/drinks" do
  @type = "drinks"
  product_template_properties(@type)

  whitelist_column = @sortby
  whitelist_order = ["desc","asc"]

  product_sort(params, whitelist_column, @type)
  product_search(params)

  erb :"manager/common/mngr_template"
end

get "/manager/products/beans" do
  @type = "beans"
  product_template_properties(@type)

  whitelist_column = @sortby
  whitelist_order = ["desc","asc"]

  product_sort(params, whitelist_column, @type)
  product_search(params)
  
  erb :"manager/common/mngr_template"
end

def product_template_properties(type)
  @title = "Products - " + type.capitalize
  @page = :"manager/products/mngr_products"
  @page_css = "products"
  
  @sortby = {
    "ID" => "product_id",
    "Name" => "name",
    "Price" => "price",
    "Cost" => "cost"
  }

  @column = {
    "product_id" => Sequel[:products][:product_id],
    "price" => Sequel[:product_variants][:price],
    "cost" => Sequel[:product_variants][:cost],
  }

  if type == "beans"
    @column["name"] = Sequel[:products][:name]
    @sortby["Stock"] = "stock_level"
    @column["stock_level"] = Sequel[:products][:stock_level]
  else
    @column["name"] = Product.product_name_column
  end

  @sortby["Available"] = "availability"
  @column["availability"] = Sequel[:products][:availability]
end

def product_sort(params, whitelist_column, type)
  whitelist_order = ["desc","asc"]

  @sort = whitelist_column.value?(params["sort"]) ? params["sort"] : "product_id"
  sort_order = whitelist_order.include?(params["order"]) ? params["order"] : "asc"
  sort_column = @column[@sort]

  @products = Product.joined_table_by_type(type).order(sort_column)
  @products = @products.reverse if sort_order == "desc"
  @symbol = sort_order == "desc" ? " ▼" : " ▲" unless params["sort"].to_s.empty?
  
  @lastorder = sort_order
end

def product_search(params)
  search_whitelist = {
    "ID" => "product_id",
    "Name" => "name",
    "Available" => "availability"
  }

  search_column = params["column_to_search"].to_s
  search_input = params["search_input"].to_s.strip
  search_column = nil unless search_whitelist.value?(search_column)

  search_input = parse_availability_input(search_input, search_column)
  search_pattern(search_input, search_column)
end

def parse_availability_input(input, column)
  return input unless !input.empty? && column == "availability"
    
  input = input.downcase
  return "1" if "yes".include?(input)
  return "0" if "no".include?(input)
  "-1"
end

def search_pattern(input, search_column)
  return unless !input.empty? && search_column
  column = @column[search_column]

  if search_column == "product_id"
    @products = @products.where(column => input.to_i)
  else
    pattern = "%#{input.downcase}%"
    @products = @products.where{
      Sequel
        .function(:lower, Sequel.cast(column, String))
        .like(pattern)
    }
  end
end