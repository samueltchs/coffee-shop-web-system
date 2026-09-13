require "require_all"
require "sinatra"

require_all "controllers"
require_relative "helpers/helpers"
require_relative "db/db"
require_all "models"

enable :sessions

before do
  if viewing_employee? && !request.get?
    allowed_paths = ["/barista/main", "/manager/refunds/filter"]

    halt 403, 'You cannot perform actions while viewing an employee account.' unless allowed_paths.include?(request.path_info)
  end
  DiscountRedemption.distribute_to_eligible_customers
end

before "/admin-*" do
  require_login

  redirect_based_on_role unless session[:role] == "Admin"

  run_inactivity_checks_once_per_hour

  @no_of_admin_messages = admin_inbox_messages.length
end

before "/barista/*" do
  if session.empty? || !session[:username]
      require_login
  elsif session[:role] == "Barista" || (viewing_employee? && view_employee.role == "Barista")
    @barista_name = view_employee.username
  else
    redirect_based_on_role  
  end
end

before "/manager/*" do
  if session.empty? || !session[:username]
    require_login
  elsif session[:role] == "Manager" || (viewing_employee? && view_employee.role == "Manager")
    @manager_name = view_employee.username
  else
    redirect_based_on_role
  end
end

DB.run <<~SQL
  CREATE TABLE IF NOT EXISTS complaints (
    complaint_id INTEGER PRIMARY KEY,
    loyalty_number INTEGER,
    complaint_text TEXT NOT NULL,
    status TEXT,
    created_at TEXT
  );
SQL