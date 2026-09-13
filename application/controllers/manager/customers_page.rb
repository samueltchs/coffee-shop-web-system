require 'date'
require "chartkick"
require_relative "../../helpers/analytics"

helpers Analytics

get "/manager/customers" do
  @title = "Customers"
  @page = :"manager/customers/mngr_customers"
  @page_css = "customers"
  @sortby = {
    loyalty_number: "Loyalty Number",
    name: "Name",
    amount: "Amount Spent",
    number: "No. of Orders",
    reg_time: "Register Time"
  }

  @signup_chart_data = signup_chart

  @customers = Customer.exclude(status: "Deleted").exclude(registered_time: nil).all
  @total = @customers.count
  @curr_month = @customers.count(&:curr_month_signup?)

  #date filter
  from = params[:from]
  to = params[:to]
  filter = params[:select_filter]
  @from_date = Date.parse(from) unless from.to_s.empty?
  @to_date = Date.parse(to) unless to.to_s.empty?
  
  if filter == "reg_date"
    @customers = @customers.select do |customer| 
      date = uk_date(customer.parse_regtime)
      next unless date
      if @from_date && @to_date
        (@from_date..@to_date).cover?(date)
      elsif @from_date
        date >= @from_date
      elsif @to_date
        date <= @to_date
      else
        true
      end
    end
  end

  #sort function
  whitelist_column = @sortby.keys.map(&:to_s)
  whitelist_order = ["desc","asc"]

  @sort = whitelist_column.include?(params[:sort]) ? params[:sort] : "reg_time"
  sort_order = whitelist_order.include?(params[:order]) ? params[:order] : "desc"
  
  if @sort == "loyalty_number"
    @customers = @customers.sort_by(&:loyalty_number)
  elsif @sort == "name"
    @customers = @customers.sort_by(&:name)
  elsif @sort == "amount"
    @customers = @customers.sort_by{|c| c.total_purchase(@from_date, @to_date)}
  elsif @sort == "number"
    @customers = @customers.sort_by{|c| c.num_purchase(@from_date, @to_date)}
  else @sort == "reg_time"
    @customers = @customers.sort_by(&:parse_regtime)
  end

  @customers = @customers.reverse if sort_order == "desc"
  @symbol = sort_order == "desc" ? " ▼" : " ▲" unless params[:sort].to_s.empty?
  @lastorder = sort_order
  
  erb :"manager/common/mngr_template"
end

get "/manager/customers/details" do
  @title = "Customer Details"
  @page = :"manager/customers/mngr_customer_details"
  @page_css = "customer_details"

  @loyal_num = params[:loyal_num]
  @customer = Customer[@loyal_num]
  @orders = Order.where(loyalty_number: @loyal_num)

  erb :"manager/common/mngr_template"
end