RSpec.describe "customer forgot password controller" do
  describe "GET /forgot-password" do
    context "when accessing the route" do
      before do
        get "/forgot-password"
      end

      it "has a status code of 200 (OK)" do
        expect(last_response).to be_ok
      end

      it "displays the correct title" do
        expect(last_response.body).to include("<title>Forgot password</title>")
      end

      it "displays the correct headline" do
        expect(last_response.body).to include("<h1>Forgot password</h1>")
      end

      it "displays the forgot password form" do
        expect(last_response.body).to include('action="/forgot-password"')
      end

      it "displays the label for the email input field" do
        expect(last_response.body).to include("Enter your email address:")
      end

      it "contains the email input field" do
        expect(last_response.body).to include('name="email"')
      end

      it "displays the label for the loyalty number input field" do
        expect(last_response.body).to include("Enter your loyalty card number:")
      end

      it "contains the loyalty number input field" do
        expect(last_response.body).to include('name="loyalty_number')
      end

      it "contains the continue button" do
        expect(last_response.body).to include("Continue")
      end

      it "contains a link back to the login page" do
        expect(last_response.body).to include("/login")
      end
    end
  end

  describe "POST /forgot-password" do
    context "when no account matching any of the details exists" do
      before do
        post "/forgot-password", "email" => "nonexistent@mail.com", "loyalty_number" => "1"
      end

      it "has a status code of 200 (OK)" do
        expect(last_response).to be_ok
      end

      it "displays an error message" do
        expect(last_response.body).to include("No account found with those details.")
      end
    end

    context "when only the email matches an account" do
      before do
        add_test_customer_to_db(2, "Mikel", "Merino", "addr1", "addr2", "Shef", "S1 1AA", "7710002000", "mail@mail.com")
        post "/forgot-password", "email" => "mail@mail.com", "loyalty_number" => "1"
      end

      it "has a status code of 200 (OK)" do
        expect(last_response).to be_ok
      end

      it "displays an error message" do
        expect(last_response.body).to include("No account found with those details.")
      end
    end

    context "when only the loyalty number matches an account" do
      before do
        add_test_customer_to_db(1, "Mikel", "Merino", "addr1", "addr2", "Shef", "S1 1AA", "7710002000", "mail@mail.com")
        post "/forgot-password", "email" => "gmail@gmail.com", "loyalty_number" => "1"
      end

      it "has a status code of 200 (OK)" do
        expect(last_response).to be_ok
      end

      it "displays an error message" do
        expect(last_response.body).to include("No account found with those details.")
      end
    end

    context "when both the email and loyalty number match an account" do
      it "redirects to the reset password page" do
        customer = add_test_customer_to_db(1)
        post "/forgot-password", "email" => customer.email, "loyalty_number" => "1"
        expect(last_response).to be_redirect
        expect(last_response.location).to end_with("/customer-reset-password")
      end
    end
  end

  describe "GET /customer-reset-password" do
    context "when no session is set" do
      it "redirects to the forgot password page" do
        get "/customer-reset-password"
        expect(last_response).to be_redirect
        expect(last_response.location).to end_with("/forgot-password")
      end
    end

    context "when the session is set" do
      before do
        add_test_customer_to_db(1)
        get "/customer-reset-password", {}, { "rack.session" => { reset_loyalty_number: 1 } }
      end

      it "has a status code of 200 (OK)" do
        expect(last_response).to be_ok
      end

      it "displays the correct title" do
        expect(last_response.body).to include("<title>Reset password</title>")
      end

      it "displays the correct headline" do
        expect(last_response.body).to include("<h1>Reset password</h1>")
      end

      it "contains the reset password form" do
        expect(last_response.body).to include('action="/customer-reset-password"')
      end

      it "displays the label for the password input field" do
        expect(last_response.body).to include("Enter new password:")
      end

      it "contains the password input field" do
        expect(last_response.body).to include('name="password"')
      end

      it "displays the label for the confirm password input field" do
        expect(last_response.body).to include("Confirm new password:")
      end

      it "contains the confirm password input field" do
        expect(last_response.body).to include('name="conf_password"')
      end

      it "masks the password fields" do
        expect(last_response.body).to include('type="password"')
      end

      it "displays the confirm button" do
        expect(last_response.body).to include("Confirm")
      end
    end
  end

  describe "POST /customer-reset-password" do
    context "when no session is set" do
      it "redirects to the forgot password page" do
        post "/customer-reset-password", "password" => "validPass7!", "conf_password" => "validPass7!"
        expect(last_response).to be_redirect
        expect(last_response.location).to end_with("/forgot-password")
      end
    end

    context "given the session is set" do
      context "when an empty password is submitted" do
        before do
          @customer = add_test_customer_to_db(1)
          post "/customer-reset-password", { "password" => "", "conf_password" => "" }, { "rack.session" => { reset_loyalty_number: 1 } }
        end

        it "has a status code of 200 (OK)" do
          expect(last_response).to be_ok
        end

        it "displays an error message" do
          expect(last_response.body).to include("Password cannot be empty.")
        end

        it "does not change the customer's password" do
          expect(@customer.correct_pass("validPass7!")).to be true
        end
      end

      context "when an invalid password is submitted" do
        before do
          @customer = add_test_customer_to_db(1)
          post "/customer-reset-password",
          { "password" => "invalid", "conf_password" => "invalid" },
          { "rack.session" => { reset_loyalty_number: 1 } }
        end

        it "has a status code of 200 (OK)" do
          expect(last_response).to be_ok
        end

        it "displays an error message" do
          expect(last_response.body).to include(
            "Password must be 8+ characters with at least 1 uppercase, 1 digit and 1 special character."
          )
        end

        it "does not change the customer's password" do
          expect(@customer.correct_pass("validPass7!")).to be true
        end
      end

      context "when different passwords are submitted" do
        before do
          @customer = add_test_customer_to_db(1)
          post "/customer-reset-password",
          { "password" => "validPass7!", "conf_password" => "validPass8!" },
          { "rack.session" => { reset_loyalty_number: 1 } }
        end

        it "has a status code of 200 (OK)" do
          expect(last_response).to be_ok
        end

        it "displays an error message" do
          expect(last_response.body).to include("The passwords do not match.")
        end

        it "does not change the customer's password" do
          expect(@customer.correct_pass("validPass7!")).to be true
        end
      end

      context "when the same password as current one is submitted" do
        before do
          @customer = add_test_customer_to_db
          post "/customer-reset-password",
          { "password" => "validPass7!", "conf_password" => "validPass7!" },
          { "rack.session" => { reset_loyalty_number: 1 } }
        end

        it "has a status code of 200 (OK)" do
          expect(last_response).to be_ok
        end

        it "displays an error message" do
          expect(last_response.body).to include("The new password must not be the same as the current one.")
        end

        it "does not change the customer's password" do
          expect(@customer.correct_pass("validPass7!")).to be true
        end
      end

      context "when a valid new password is submitted" do
        before do
          add_test_customer_to_db(1)
          post "/customer-reset-password",
          { "password" => "newPass7!", "conf_password" => "newPass7!" },
          { "rack.session" => { reset_loyalty_number: 1 } }
        end

        it "has a status code of 200 (OK)" do
          expect(last_response).to be_ok
        end

        it "displays a confirmation message" do
          expect(last_response.body).to include("Password has been reset successfully.")
        end

        it "contains a link to login page" do
          expect(last_response.body).to include("/login")
        end

        it "contains link to reset password confirmation email" do
          expect(last_response.body).to include("reset-pass-success-email?loyalty_number=1")
        end

        it "saves the new password and overrides the old one" do
          customer = Customer.first(loyalty_number: 1)
          expect(customer.correct_pass("newPass7!")).to be true
          expect(customer.correct_pass("validPass7!")).to be false
        end
      end
    end
  end
end
