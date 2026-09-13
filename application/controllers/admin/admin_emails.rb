get "/admin-reset-pass-email" do
  setup_admin_email("Customer reset password email", "Reset your password")

  erb :"emails/customer_reset_pass_email"
end

get "/reset-pass-success-email" do
  loyalty_number = params["loyalty_number"]

  if session[:username] && session[:role] == "Admin"
    setup_admin_email("Customer reset password confirmation email", "Password Reset Successful")
  else
    redirect "/login" unless loyalty_number

    @customer = Customer[loyalty_number]

    redirect "/login" if @customer.nil?

    setup_automated_email(
      "Customer reset password confirmation email", "Password Reset Successful", @customer.email, @customer.name
    )
  end

  erb :"emails/reset_pass_success_email"
end

get "/admin-inactivity-warning-email" do
  setup_automated_email("Customer inactivity warning email", "Account Inactivity Warning")

  erb :"emails/customer_inactivity_warning_email"
end

get "/admin-suspension-warning-email" do
  setup_automated_email("Customer suspension warning email", "Account Suspension Warning")

  erb :"emails/customer_suspension_warning_email"
end

get "/admin-inactivity-suspension-email" do
  @customer = get_customer

  redirect "/" unless @customer.status == "Suspended"

  setup_automated_email("Customer account suspension email", "Account Suspension")

  erb :"emails/customer_inactivity_suspension_email"
end

get "/admin-disciplinary-suspension-email" do
  @customer = get_customer

  redirect "/" unless @customer.status == "Suspended"

  setup_automated_email("Customer account suspension email", "Account Suspension")

  erb :"emails/customer_disciplinary_suspension_email"
end

get "/admin-inactivity-deletion-email" do
  setup_automated_email(
    "Customer account deletion email", "Account Deletion", "deletedForPrivacyReasons77@gmail.com", "[REDACTED]"
  )

  erb :"emails/customer_inactivity_deletion_email"
end

get "/admin-disciplinary-deletion-email" do
  setup_automated_email(
    "Customer account deletion email", "Account Deletion", "deletedForPrivacyReasons77@gmail.com", "[REDACTED]"
  )

  erb :"emails/customer_disciplinary_deletion_email"
end

get "/admin-account-reactivated-email" do
  setup_automated_email("Customer account reactivation email", "Account Reactivated")

  erb :"emails/customer_account_reactivated_email"
end
