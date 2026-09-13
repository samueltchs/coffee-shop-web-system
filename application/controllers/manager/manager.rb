#manil

get "/manager/sales" do
  @title = "Sales"
  @page = :"manager/sales/mngr_sales"
  erb :"manager/common/mngr_template"
end

get "/manager/sales/analytics" do
  @title = "Sales Analytics"  
  @page_css = "sales"
  @active_tab = "overview"
  #compute KPI from completed orders
  paid_orders = Order.where(status: "Paid").where(order_fulfilment: "Collected").all
  @total_revenue=paid_orders.sum {|o| o.price.to_f}
  @total_orders = paid_orders.length
  @avg_order = @total_orders > 0 ? @total_revenue / @total_orders : 0
  @total_items_sold=paid_orders.sum{|o| ItemInOrder.where(order_unique_id: o.order_unique_id).all.sum {|i| i.quantity.to_i}}
  @page = :"manager/sales/mngr_sales_analytics"
erb :"manager/common/mngr_template"
end

get "/manager/sales/drinks" do
  @title = "Drinks Sales"
  @page_css = "sales"
  @active_tab = "drinks"
  @from_date = params[:from_date] || (Date.today - 30).to_s
  @to_date = params[:to_date] || Date.today.to_s
  @page = :"manager/sales/mngr_sales_drinks"
  
all_orders = Order.all
  from = Date.parse(@from_date) rescue nil
to = Date.parse(@to_date) rescue nil
  relevant_orders = Order.select_relevant_orders(all_orders, from, to)
  relevant_order_ids = relevant_orders.map { |o| o.order_unique_id }

  drinks = Product.where(type: "drinks").all
  @drinks_data = drinks.map do |drink|
items = ItemInOrder.where(item_id: drink.product_id).where(order_unique_id: relevant_order_ids).all
qty = items.map { |it| it.quantity.to_i }.reduce(0, :+)
    rev = items.map { |it| it.price_for_one.to_f * it.quantity.to_i }.reduce(0, :+)
avg = qty > 0 ? rev / qty : 0
{ name: drink.name, avg_price: avg, quantity: qty, revenue: rev }
end

@drinks_data = @drinks_data.sort_by{|d| -d[:quantity]}
  @total_drinks_sold = @drinks_data.map { |d| d[:quantity] }.reduce(0, :+)
@total_drinks_revenue = @drinks_data.map{|d| d[:revenue]}.reduce(0,:+)
  erb :"manager/common/mngr_template"
end

get "/manager/sales/beans" do
  @title = "Beans Sales"
  @page_css = "sales"
  @active_tab = "beans"
  @from_date = params[:from_date] || (Date.today - 365).to_s
  @to_date = params[:to_date] || Date.today.to_s

  all_orders = Order.all
from = Date.parse(@from_date) rescue nil
  to = Date.parse(@to_date) rescue nil
relevant_orders = Order.select_relevant_orders(all_orders, from, to)
  relevant_order_ids = relevant_orders.map { |o| o.order_unique_id }

  beans = Product.where(type: "beans").all
  @beans_data = beans.map do |bean|
    items = ItemInOrder.where(item_id: bean.product_id).where(order_unique_id: relevant_order_ids).all
    
        qty = items.map { |it| it.quantity.to_i }.reduce(0, :+)
  rev = items.map { |it| it.price_for_one.to_f * it.quantity.to_i }.reduce(0, :+)
  avg = qty > 0 ? rev / qty : 0
    { name: bean.name, avg_price: avg, quantity: qty, revenue: rev }
  end
    @beans_data = @beans_data.sort_by { |b| -b[:quantity] }
    @total_beans_sold = @beans_data.map { |b| b[:quantity] }.reduce(0, :+)
  @total_beans_revenue = @beans_data.map { |b| b[:revenue] }.reduce(0, :+)
  @page = :"manager/sales/mngr_sales_beans"
  erb :"manager/common/mngr_template"
end

get "/manager/sales/top-products" do
  @title = "Top Products"
  @page_css = "sales"
  @active_tab = "top"
  @from_date = params[:from_date] || (Date.today - 30).to_s
  @to_date = params[:to_date] || Date.today.to_s

  all_orders = Order.all
from = Date.parse(@from_date) rescue nil
  to = Date.parse(@to_date) rescue nil
  relevant_orders = Order.select_relevant_orders(all_orders, from, to)
relevant_order_ids = relevant_orders.map { |o| o.order_unique_id }

  all_products = Product.all
  @top_data = all_products.map do |prod|
    items = ItemInOrder.where(item_id: prod.product_id).where(order_unique_id: relevant_order_ids).all
    qty = items.map { |it| it.quantity.to_i }.reduce(0, :+)
rev = items.map { |it| it.price_for_one.to_f * it.quantity.to_i }.reduce(0, :+)
avg = qty > 0 ? rev / qty : 0
    { name: prod.name, type: prod.type, avg_price: avg, quantity: qty, revenue: rev }
  end
@top_data = @top_data.select { |p| p[:quantity] > 0 }.sort_by { |p| -p[:quantity] }
  @page = :"manager/sales/mngr_sales_top_products"
  erb :"manager/common/mngr_template"
end

get "/manager/refunds" do
  @title = "Refunds"
  @page_css = "refunds"
  @from_date = params[:from_date] || ""
  @to_date = params[:to_date] || ""

  refunds_dataset = Refund.apply_filters(nil, nil, @from_date, @to_date)
  @refunds = refunds_dataset.all

  @total_count = @refunds.length
  @total_refund_amount = @refunds.map do |r|
    amt = r.get_amount
    amt.is_a?(Numeric) ? amt : 0
  end.reduce(0, :+)

  @page = :"manager/mngr_refunds"
  erb :"manager/common/mngr_template"
end

post "/manager/refunds/filter" do
  redirect "/manager/refunds?from_date=#{params[:from_date]}&to_date=#{params[:to_date]}&reason=#{params[:reason]}&item=#{params[:item]}"
end

get "/manager/complaints" do
  @title = "Complaints"
  @page_css = "complaints"
  @from_date = params[:from_date] || ""
  @to_date = params[:to_date] || ""

  complaints_dataset = Complaint.get_date_range(Complaint.dataset, @from_date, @to_date)
  @complaints = complaints_dataset.all
  @total_count = @complaints.length

  @page = :"manager/mngr_complaints"
  erb :"manager/common/mngr_template"
end


get "/manager/free-coffees" do
  @title = "Free Coffees"
  @page_css ="free_coffees"
  @from_date = params[:from_date] || ""
@to_date = params[:to_date] || ""
  redemptions_ds = DB[:free_coffee_redemptions].order(Sequel.desc(:redeem_timestamp))

  unless @from_date.nil? || @from_date.empty?
    start_normalised = "#{@from_date} 00:00:00 UTC"
    redemptions_ds = redemptions_ds.where { redeem_timestamp >= start_normalised }
  end
  unless @to_date.nil? || @to_date.empty?
    end_normalised = "#{@to_date} 23:59:59 UTC"
    redemptions_ds = redemptions_ds.where { redeem_timestamp <= end_normalised }
  end

  redemptions = redemptions_ds.all

  @free_coffees = redemptions.map do |r|
  cust = Customer.first(loyalty_number: r[:loyalty_number])
  prod = Product.first(product_id: r[:product_id])
  size = DB[:sizes].first(id: r[:size_id])
  milk = DB[:milk_options].first(id: r[:milk_id])
        {
    date: r[:redeem_timestamp],
    customer: cust ? "#{cust.first_name} #{cust.last_name}" : "Unknown",
    product: prod ? prod.name : "Unknown",
    size: size ? size[:size] : "-",
    milk: milk ? milk[:milk] : "-"
        }
  end
  @total_redeemed = @free_coffees.length
  @page = :"manager/mngr_free_coffees"
    erb :"manager/common/mngr_template"
end


get "/manager/sales/top-customers" do
  @title = "Top Customers"
  @page_css = "sales"
  @active_tab = "customers"
  @from_date = params[:from_date] || (Date.today - 365).to_s
  @to_date = params[:to_date] || Date.today.to_s
  from = Date.parse(@from_date) rescue nil
  to = Date.parse(@to_date) rescue nil
  all_customers = Customer.all
  @top_data = all_customers.map do |c|
  spent = c.total_purchase(from, to).to_f
  orders = c.num_purchase(from, to)
  {
    name: "#{c.first_name} #{c.last_name}",
    loyalty_number: c.loyalty_number,
    orders: orders,
    spent: spent,
    stamps: c.stamps.to_i
    }
  end
  @top_data = @top_data.select { |c| c[:orders] > 0 }.sort_by { |c| -c[:spent] }
  @total_top_spent = @top_data.first(3).map { |c| c[:spent] }.reduce(0, :+)
  @page = :"manager/sales/mngr_sales_top_customers"
    erb :"manager/common/mngr_template"
end