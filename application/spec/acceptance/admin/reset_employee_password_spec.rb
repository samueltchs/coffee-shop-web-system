RSpec.describe "Resetting an employee's password" do
  context "given the admin is logged in" do
    before do
      admin = add_test_admin_to_db
      add_test_barista_to_db("user")
      login_as_employee(admin)
    end

    context "when an invalid password is submitted" do
      it "then displays error messages" do
        visit "/admin-employee?username=user"
        fill_in "password", with: "invalid"
        fill_in "conf_password", with: "invalid"
        click_on "Reset password"

        error_messages = [
          "Password is not valid. Must be 8+ characters with at least 1 uppercase, 1 digit and 1 special character.",
          "Password not updated. Requirements not met."
        ]

        error_messages.each do |error|
          expect(page).to have_content "#{error}"
        end
      end
    end

    context "when a valid password is submitted" do
      it "then displays a confirmation message" do
        visit "/admin-employee?username=user"
        fill_in "password", with: "Barista17!"
        fill_in "conf_password", with: "Barista17!"
        click_on "Reset password"

        expect(page).to have_content "Password has been updated successfully."
      end
    end
  end
end
