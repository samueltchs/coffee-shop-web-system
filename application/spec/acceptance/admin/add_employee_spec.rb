RSpec.describe "Registering an employee" do
  context "given the admin is logged in" do
    before do
      admin = add_test_admin_to_db
      login_as_employee(admin)
    end

    context "when no input is submitted" do
      it "then displays error messages" do
        visit "/admin-add-employee"
        click_on "Create account"

        error_messages = [
          "Failure in registering the employee. Please provide valid details.",
          "First name cannot be empty.",
          "Last name cannot be empty.",
          "Username cannot be empty.",
          "Email cannot be empty.",
          "Role cannot be empty.",
          "Password is not valid. Must be 8+ characters with at least 1 uppercase, 1 digit and 1 special character."
        ]

        error_messages.each do |error|
          expect(page).to have_content "#{error}"
        end
      end
    end

    context "when valid details are submitted" do
      it "then creates the employee account and displays a confirmation message" do
        visit "/admin-add-employee"
        fill_in "first_name", with: "George"
        fill_in "last_name", with: "Michael"
        fill_in "username", with: "username"
        fill_in "email", with: "email@gmail.com"
        select "Barista", from: "role"
        fill_in "password", with: "validPass7!"
        fill_in "conf_password", with: "validPass7!"
        click_on "Create account"

        expect(page).to have_content "Account has been successfully created!"
        expect(page).to have_content "George"
        expect(page).to have_content "Michael"
        expect(page).to have_content "username"
        expect(page).to have_content "email@gmail.com"
        expect(page).to have_content "Barista"
      end
    end
  end
end
