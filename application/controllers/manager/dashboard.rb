require "chartkick"
require_relative "../../helpers/analytics"

helpers Analytics

get "/manager/dashboard" do
  @title = "Dashboard"
  @page = :"manager/mngr_dashboard"
  @page_css = "dashboard"

  from_date = params[:start_date]
  to_date = params[:end_date]

  @combo_data = combo_chart_stats(from_date, to_date)
  @top_drinks_data = top_product_chart("drinks", from_date, to_date)
  @top_beans_data = top_product_chart("beans", from_date, to_date)
  @top_discounts_data = top_discounts_chart(from_date, to_date)
  @discounted_data = discounted_chart(from_date, to_date)
  
  erb :"manager/common/mngr_template"
end