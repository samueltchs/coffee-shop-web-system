RSpec.describe "Resetting a customer's password" do
  context "given a customer exists" do
    before do
      @customer = add_test_customer_to_db
    end

    context "when incorrect details are submitted" do
      it "then displays an error message" do
        visit "/forgot-password"
        fill_in "email", with: "wrong@gmail.com"
        fill_in "loyalty_number", with: @customer.loyalty_number.to_s
        click_on "Continue"

        expect(page).to have_content "No account found with those details."
      end
    end

    context "when correct details are submitted" do
      before do
        visit "/forgot-password"
        fill_in "email", with: @customer.email
        fill_in "loyalty_number", with: @customer.loyalty_number.to_s
        click_on "Continue"
      end

      it "then redirects to the reset password page" do
        expect(page).to have_content "Reset password"
      end

      it "then displays an error message if an invalid password is submitted" do
        fill_in "password", with: "invalid"
        fill_in "conf_password", with: "invalid"
        click_on "Confirm"

        expect(page).to have_content(
          "Password must be 8+ characters with at least 1 uppercase, 1 digit and 1 special character."
        )
      end

      it "then changes their password if a new valid one is submitted" do
        fill_in "password", with: "newPass7!"
        fill_in "conf_password", with: "newPass7!"
        click_on "Confirm"

        expect(page).to have_content "Password has been reset successfully."
        expect(page).to have_content "Go back to login page"
        expect(page).to have_content "Password reset confirmation email"
      end
    end
  end

  context "given the customer has not gone through the forgot password page first" do
    context "when trying to access the reset password page directly" do
      it "then redirects to the forgot password page" do
        visit "/customer-reset-password"

        expect(page).to have_content "Forgot password"
      end
    end
  end
end
