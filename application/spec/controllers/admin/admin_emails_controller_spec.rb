RSpec.describe "admin emails controller" do
  describe "GET /admin-reset-pass-email" do
    context "when logged in as admin" do
      before do
        @admin = add_test_admin_to_db
        @customer = add_test_customer_to_db
        get_as_employee(@admin, "/admin-reset-pass-email?loyalty_number=#{@customer.loyalty_number}")
      end

      it "has a status code of 200 (OK)" do
        expect(last_response).to be_ok
      end

      it "displays the correct title" do
        expect(last_response.body).to include("<title>Customer reset password email</title>")
      end

      it "displays the sender's email" do
        expect(last_response.body).to include("From:")
        expect(last_response.body).to include(@admin.email)
      end

      it "displays the receiver's email" do
        expect(last_response.body).to include("To:")
        expect(last_response.body).to include(@customer.email)
      end

      it "displays the email's subject" do
        expect(last_response.body).to include("Subject:")
        expect(last_response.body).to include("Reset your password")
      end

      it "displays the cafe's name" do
        expect(last_response.body).to include("BADLY BREWED COFFEE")
      end

      it "displays the customer's full name" do
        expect(last_response.body).to include("Hi #{@customer.name},")
      end

      it "displays the admin's full name" do
        expect(last_response.body).to include(@admin.name)
      end

      it "contains a link to the forgot password page" do
        expect(last_response.body).to include("/forgot-password")
        expect(last_response.body).to include("Reset password")
      end

      it "does not display the automated email message" do
        expect(last_response.body).not_to include("This is an automated message - please do not reply.")
      end

      it "displays the correct footer" do
        expect(last_response.body).to include("© #{Time.now.year} Badly Brewed Coffee. All rights reserved.")
      end

      it "displays the correct content" do
        expect(last_response.body).to include("Per your request, you may reset your password using the link below:")
      end
    end
  end

  describe "GET /reset-pass-success-email" do
    context "when logged in as admin" do
      before do
        admin = add_test_admin_to_db
        customer = add_test_customer_to_db
        get_as_employee(admin, "/reset-pass-success-email?loyalty_number=#{customer.loyalty_number}")
      end
    
      it "has a status code of 200 (OK)" do
        expect(last_response).to be_ok
      end

      it "displays the correct title" do
        expect(last_response.body).to include("<title>Customer reset password confirmation email</title>")
      end

      it "displays the email's subject" do
        expect(last_response.body).to include("Password Reset Successful")
      end

      it "displays the correct content" do
        expect(last_response.body).to include("Your password has been successfully reset.")
        expect(last_response.body).to include("If you did not make this change, please contact us immediately.")
        expect(last_response.body).to include("Thank you for using our service.")        
      end
    end

    context "when no loyalty number is provided" do
      it "redirects to the login page" do
        get "/reset-pass-success-email"
        expect(last_response).to be_redirect
        expect(last_response.location).to end_with("/login")
      end
    end

    context "when an invalid loyalty number is provided" do
      it "redirects to the login page" do
        get "/reset-pass-success-email", { "loyalty_number" => "1" }
        expect(last_response).to be_redirect
        expect(last_response.location).to end_with("/login")
      end
    end

    context "when a valid loyalty number is provided" do
      before do
        add_test_customer_to_db(1)
        get "/reset-pass-success-email", { "loyalty_number" => "1" }
      end

      it "has a status code of 200 (OK)" do
        expect(last_response).to be_ok
      end

      it "displays the correct title" do
        expect(last_response.body).to include("<title>Customer reset password confirmation email</title>")
      end

      it "displays the email's subject" do
        expect(last_response.body).to include("Password Reset Successful")
      end

      it "displays the automated sender's email" do
        expect(last_response.body).to include("noreply@badlybrewedcoffee.com")
      end

      it "displays the automated message" do
        expect(last_response.body).to include("This is an automated message - please do not reply.")
      end
    end
  end

  describe "GET /admin-inactivity-warning-email" do
    context "when logged in as admin" do
      before do
        admin = add_test_admin_to_db
        customer = add_test_customer_to_db
        get_as_employee(admin, "/admin-inactivity-warning-email?loyalty_number=#{customer.loyalty_number}")
      end

      it "has a status code of 200 (OK)" do
        expect(last_response).to be_ok
      end

      it "displays the correct title" do
        expect(last_response.body).to include("<title>Customer inactivity warning email</title>")
      end

      it "displays the email's subject" do
        expect(last_response.body).to include("Account Inactivity Warning")
      end

      it "displays the correct sender's email" do
        expect(last_response.body).to include("noreply@badlybrewedcoffee.com")
      end

      it "displays the automated email message" do
        expect(last_response.body).to include("This is an automated message - please do not reply.")
      end

      it "displays the automated sender name" do
        expect(last_response.body).to include("The Badly Brewed Coffee Team")
      end

      it "displays the correct content" do
        expect(last_response.body).to include("We noticed that your account has been inactive for a while.")
        expect(last_response.body).to include("To continue using our services, please log in within the next month.")
        expect(last_response.body).to include("Accounts that remain inactive for 6 months will be suspended.")
        expect(last_response.body).to include("Thank you for your understanding.")      
      end
    end
  end

  describe "GET /admin-suspension-warning-email" do
    context "when logged in as admin" do
      before do
        admin = add_test_admin_to_db
        customer = add_test_customer_to_db
        get_as_employee(admin, "/admin-suspension-warning-email?loyalty_number=#{customer.loyalty_number}")
      end
    
      it "has a status code of 200 (OK)" do
        expect(last_response).to be_ok
      end

      it "displays the correct title" do
        expect(last_response.body).to include("<title>Customer suspension warning email</title>")
      end

      it "displays the email's subject" do
        expect(last_response.body).to include("Account Suspension Warning")
      end

      it "displays the correct content" do
        expect(last_response.body).to include("We noticed that your account has been inactive for 6 months.")
        expect(last_response.body).to include("To continue using our services, please log in within the next 24 hours.")
        expect(last_response.body).to include("If you do not, your account will be automatically suspended")
        expect(last_response.body).to include("as part of our policy to maintain active accounts.")
        expect(last_response.body).to include("Thank you for your understanding.")   
      end
    end
  end

  describe "GET /admin-inactivity-suspension-email" do
    context "when logged in as admin" do
      before do
        admin = add_test_admin_to_db
        customer = add_suspended_customer_to_db
        get_as_employee(admin, "/admin-inactivity-suspension-email?loyalty_number=#{customer.loyalty_number}")
      end
    
      it "has a status code of 200 (OK)" do
        expect(last_response).to be_ok
      end

      it "displays the correct title" do
        expect(last_response.body).to include("<title>Customer account suspension email</title>")
      end

      it "displays the email's subject" do
        expect(last_response.body).to include("Account Suspension")
      end

      it "displays the correct content" do
        expect(last_response.body).to include("We would like to inform you that your account has been suspended.")
        expect(last_response.body).to include("Accounts are automatically suspended following a prolonged period")
        expect(last_response.body).to include("of inactivity as part of our policy to maintain active accounts.")
        expect(last_response.body).to include("If you wish to regain access to your account, please contact us.")
        expect(last_response.body).to include("Failing to do so will result in the deletion of your account in 3 months time.")   
        expect(last_response.body).to include("Thank you for your understanding.")   
      end
    end

    context "when customer is not suspended" do
      it "redirects to default page" do
        admin = add_test_admin_to_db
        customer = add_test_customer_to_db
        get_as_employee(admin, "/admin-inactivity-suspension-email?loyalty_number=#{customer.loyalty_number}")
        expect(last_response).to be_redirect
        expect(last_response.location).to end_with("/")
      end
    end
  end

  describe "GET /admin-disciplinary-suspension-email" do
    context "when logged in as admin" do
      before do
        admin = add_test_admin_to_db
        customer = add_suspended_customer_to_db(1, Time.now.utc - SECONDS_IN_DAY * 5, Time.now.utc, 2)
        get_as_employee(admin, "/admin-disciplinary-suspension-email?loyalty_number=#{customer.loyalty_number}")
      end
    
      it "has a status code of 200 (OK)" do
        expect(last_response).to be_ok
      end

      it "displays the correct title" do
        expect(last_response.body).to include("<title>Customer account suspension email</title>")
      end

      it "displays the email's subject" do
        expect(last_response.body).to include("Account Suspension")
      end

      it "displays the correct content" do
        expect(last_response.body).to include("We would like to inform you that your account has been suspended.")
        expect(last_response.body).to include("This action was taken following a review of your account activity.")
        expect(last_response.body).to include("If you wish to appeal this decision, please contact us.")
        expect(last_response.body).to include("Thank you for your understanding.")
      end
    end

    context "when customer is not suspended" do
      it "redirects to default page" do
        admin = add_test_admin_to_db
        customer = add_test_customer_to_db
        get_as_employee(admin, "/admin-disciplinary-suspension-email?loyalty_number=#{customer.loyalty_number}")
        expect(last_response).to be_redirect
        expect(last_response.location).to end_with("/")
      end
    end
  end

  describe "GET /admin-inactivity-deletion-email" do
    context "when logged in as admin" do
      before do
        admin = add_test_admin_to_db
        get_as_employee(admin, "/admin-inactivity-deletion-email?loyalty_number=1")
      end
    
      it "has a status code of 200 (OK)" do
        expect(last_response).to be_ok
      end

      it "displays the correct title" do
        expect(last_response.body).to include("<title>Customer account deletion email</title>")
      end

      it "displays the email's subject" do
        expect(last_response.body).to include("Account Deletion")
      end

      it "contains a link to the customer sign up page" do
        expect(last_response.body).to include("/sign-up")
        expect(last_response.body).to include("Sign up here")
      end

      it "displays a default email for deleted customers" do
        expect(last_response.body).to include("deletedForPrivacyReasons77@gmail.com")
      end

      it "displays a default name for deleted customers" do
        expect(last_response.body).to include("[REDACTED]")
      end

      it "displays the correct content" do
        expect(last_response.body).to include("We would like to inform you that your account has been deleted.")
        expect(last_response.body).to include("Accounts are deleted 3 months after their suspension date")
        expect(last_response.body).to include("as part of our policy to maintain active accounts.")
        expect(last_response.body).to include("If you wish to use our services again in the future,")
        expect(last_response.body).to include("you are welcome to create an account using the link below.")
        expect(last_response.body).to include("Thank you for your understanding.")
      end
    end
  end

  describe "GET /admin-disciplinary-deletion-email" do
    context "when logged in as admin" do
      before do
        admin = add_test_admin_to_db
        get_as_employee(admin, "/admin-disciplinary-deletion-email?loyalty_number=1")
      end
    
      it "has a status code of 200 (OK)" do
        expect(last_response).to be_ok
      end

      it "displays the correct title" do
        expect(last_response.body).to include("<title>Customer account deletion email</title>")
      end

      it "displays the email's subject" do
        expect(last_response.body).to include("Account Deletion")
      end

      it "contains a link to the customer sign up page" do
        expect(last_response.body).to include("/sign-up")
        expect(last_response.body).to include("Sign up here")
      end

      it "displays the correct content" do
        expect(last_response.body).to include("We would like to inform you that your account has been deleted.")
        expect(last_response.body).to include("This action was deemed necessary after a review of your account activity.")
        expect(last_response.body).to include("If you wish to use our services again in the future,")
        expect(last_response.body).to include("you are welcome to create an account using the link below.")
        expect(last_response.body).to include("Thank you for your understanding.")
      end
    end
  end

  describe "GET /admin-account-reactivated-email" do
    context "when logged in as admin" do
      before do
        admin = add_test_admin_to_db
        customer = add_test_customer_to_db
        get_as_employee(admin, "/admin-account-reactivated-email?loyalty_number=#{customer.loyalty_number}")
      end
    
      it "has a status code of 200 (OK)" do
        expect(last_response).to be_ok
      end

      it "displays the correct title" do
        expect(last_response.body).to include("<title>Customer account reactivation email</title>")
      end

      it "displays the email's subject" do
        expect(last_response.body).to include("Account Reactivated")
      end

      it "contains a link to the customer sign up page" do
        expect(last_response.body).to include("/login")
        expect(last_response.body).to include("Log into account")
      end

      it "displays the correct content" do
        expect(last_response.body).to include("Per your request, your account has been reactivated.")
        expect(last_response.body).to include("You may now use our services again by logging in using the link below.")
        expect(last_response.body).to include("We are very glad to have you back")
      end
    end
  end
end
