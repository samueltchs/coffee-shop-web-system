require "time"
require "date"
require_relative "conversions"

# Provide various functions for analytics
module Analytics
  include Conversions

  def get_monthly_orders
    seconds_in_seven_months = 60 * 60 * 24 * 30 * 7
    time_seven_months_ago = (Time.now.utc - seconds_in_seven_months).strftime("%Y-%m-%d %H:%M:%S")

    orders = Order.where { date_placed >= time_seven_months_ago }

    counts = compute_orders_per_month(orders)

    compute_monthly_changes(counts)
  end

  def get_monthly_signups
    seconds_in_seven_months = 60 * 60 * 24 * 30 * 7
    time_seven_months_ago = (Time.now.utc - seconds_in_seven_months).strftime("%Y-%m-%d %H:%M:%S")

    customers = Customer.where { registered_time >= time_seven_months_ago }

    counts = compute_signups_per_month(customers)

    compute_monthly_changes(counts)
  end

  def compute_orders_per_month(orders)
    counts = {}

    orders.each do |order|
      month = order.date_placed[0, 7]

      if counts[month]
        counts[month] += 1
      else
        counts[month] = 1
      end
    end

    counts
  end

  def compute_signups_per_month(customers)
    counts = {}

    customers.each do |cust|
      month = cust.registered_time[0, 7]

      if counts[month]
        counts[month] += 1
      else
        counts[month] = 1
      end
    end

    counts
  end

  def compute_monthly_changes(counts)
    counts_array_sorted = counts.to_a.sort_by do |element|
      element[0]
    end

    results = []

    1.upto(counts_array_sorted.length - 1) do |i|
      current_month = counts_array_sorted[i][0]
      current_count = counts_array_sorted[i][1]
      previous_count = counts_array_sorted[i - 1][1]

      change = current_count - previous_count

      results << [current_month, current_count, change]
    end

    results.last(6).reverse
  end

  def time_spent_per_week(customer)
    times_recorded = customer_times_recorded(customer)

    return [] if times_recorded.length < 2 || !customer.registered_time

    times = []
    times_recorded.each do |time|
      times << Time.parse(time)
    end

    times_sorted = times.sort
    current_time = Time.now.utc
    seconds_in_week = 60 * 60 * 24 * 7
    time_ten_weeks_ago = current_time - 10 * seconds_in_week

    registration_time = Time.parse(customer.registered_time)

    start_time = time_ten_weeks_ago

    # only show ten weeks if customer has been registered for that long
    start_time = registration_time if registration_time > time_ten_weeks_ago

    compute_time_spent_weekly(times_sorted, start_time, current_time, seconds_in_week)
  end

  def compute_time_spent_weekly(times_sorted, start_time, current_time, seconds_in_week)
    results = []
    week_index = 0

    loop do
      end_of_week = current_time - week_index * seconds_in_week

      break if end_of_week <= start_time

      start_of_week = end_of_week - seconds_in_week
      start_of_week = start_time if start_of_week < start_time

      total_seconds = compute_seconds_spent(times_sorted, start_of_week, end_of_week)

      timeframe = "#{start_of_week.strftime('%Y-%m-%d')} - #{end_of_week.strftime('%Y-%m-%d')}"
      hours = (total_seconds / 3600).floor
      minutes = ((total_seconds % 3600) / 60).floor

      results << [timeframe, "#{hours}h #{minutes}m"]

      week_index += 1
    end

    results
  end

  def compute_seconds_spent(times_sorted, start_of_week, end_of_week)
    total_seconds = 0

    0.upto(times_sorted.length - 1) do |time_index|
      time = times_sorted[time_index]

      # only include if inside the week
      next if time < start_of_week || time > end_of_week

      next_time = times_sorted[time_index + 1]

      if !next_time || next_time > end_of_week
        # assume 5 minutes for the last event recorded
        total_seconds += 300

        next
      end

      time_gap = next_time - time

      if time_gap <= 900
        # only valid if customer has been inactive for no more than 15 minutes
        total_seconds += time_gap
      else
        # add 5 minutes to total time otherwise
        total_seconds += 300
      end
    end

    total_seconds
  end

  def top_items_for_habits(customer)
    top_items = ItemInOrder.get_most_frequently_bought_items(customer.loyalty_number)
    top_items_for_habits = []

    top_items.each do |(item_id, size_id, milk_id), count|
      product = Product[item_id]

      if product
        name = product.name
      else
        name = "Unknown"
      end

      size = Size.get_size(size_id)
      milk = MilkOption.get_milk_name(milk_id)

      top_items_for_habits << [name, item_id, size, milk, count]
    end

    top_items_for_habits
  end

  def top_items_for_ad(customer)
    top_items = ItemInOrder.get_most_frequently_bought_items(customer.loyalty_number)
    top_items_for_ad = []

    top_items.each do |(item_id, size_id, milk_id), _count|
      product = Product[item_id]

      if product
        name = product.name
        description = product.description
        image_path = product.image_path
        price = ProductVariant.get_price(item_id, size_id, milk_id)
      else
        name = "Unknown"
        description = "No description and no image as you know how delicious it is.."
        image_path = "images/no-image.png"
        price = "N/A"
      end

      top_items_for_ad << [name, description, image_path, price, item_id]
    end

    top_items_for_ad
  end

  def top_baristas_by_orders
    orders_by_baristas = Order.exclude(barista: 'Online')
    order_counts = {}

    orders_by_baristas.each do |order|
      if order_counts[order.barista]
        order_counts[order.barista] += 1
      else
        order_counts[order.barista] = 1
      end
    end

    order_counts_sorted = order_counts.to_a.sort_by do |element|
      element[1]
    end

    order_counts_sorted.last(3).reverse
  end

  #Manager Dashboard Charts
  #Combo Chart data for type sales
  def combo_chart_stats(from_date = nil, to_date = nil)
    table = []
    table << ['Month','Drinks','Beans','Total']

    from_date, to_date = parse_date_range_filter(from_date, to_date)
    month_intervals(from_date, to_date).each do |from, to|
      table << [
        from.strftime("%b %y"),
        Order.total_in_daterange_by_type("drinks", from, to),
        Order.total_in_daterange_by_type("beans", from, to),
        Order.total_in_daterange_by_type("both", from, to)
      ]
    end
    table
  end

  #Bar Chart Data for top products
  def top_product_chart(type, from_date = nil, to_date = nil)
    data = {}
    from_date, to_date = parse_date_range_filter(from_date, to_date)
    orders = Order.select_relevant_orders(Order.all, from_date, to_date)

    ids = Product.get_all_id_by_type(type)
    ids.each do |id|
      total = 0
      orders.each do |order|
        total += order.get_total_quantity_by_id(id)
      end
      name = Product.get_name_by_id(id)
      
      data[name] = total unless total == 0
    end
    data.sort_by { |name, quantity| -quantity }.first(5).to_h
  end

  #Bar Chart Data for Top 5 Discount Campaigns
  def top_discounts_chart(from_date = nil, to_date = nil)
    data = {}
    from_date, to_date = parse_date_range_filter(from_date, to_date)

    codes = DiscountCode.get_all_codes
    codes.each do |code|
      orders = Order.where(discount_code_used: code).all
      orders = Order.select_relevant_orders(orders, from_date, to_date)
      sales = orders.sum(&:net_price)
      data[code] = sales if sales > 0
    end
    data.sort_by { |code, amount| -amount }.first(5).to_h
  end

  #Pie Chart Data for Discounted Sales in Manager Dashboard
  def discounted_chart(from_date = nil, to_date = nil)
    from_date, to_date = parse_date_range_filter(from_date, to_date)
    orders = Order.select_relevant_orders(Order.all, from_date, to_date)
    codes = DiscountCode.get_all_codes

    total_net_sales = orders.sum { |o| o.net_price }
    total_discounted = orders.sum do |order|
      codes.include?(order.discount_code_used) ? order.net_price : 0
    end
    data = {
      "Full Price Sales" => total_net_sales - total_discounted,
      "Discounted Sales" => total_discounted
    }
  end

  #Monthly Sign-up Line Graph Data in Manager Customers Page
  def signup_chart
    data = {}

    today = Date.today
    year_ago = today << 12

    months = month_intervals(year_ago, today)
    customers = Customer.all

    months.each do |from, to|
      month = from.month
      year = from.year
      count = customers.count do |c|
        reg_time = c.parse_regtime
        reg_time.year == year && reg_time.month == month
      end
      data[from.strftime("%b %y")] = count
    end
    data
  end
end
