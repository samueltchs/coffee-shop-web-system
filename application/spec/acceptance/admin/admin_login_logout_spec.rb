RSpec.describe "Accessing the admin account" do
  context "given the admin attempts to log in and log out" do
    context "when the admin enters the wrong credentials" do
      it "then displays an error message" do
        visit "/employee-login-page"
        fill_in "username", with: "admin"
        fill_in "password", with: "wrongPass7!"
        click_on "Log-in"

        expect(page).to have_content "Username and password combination does not match"
      end
    end

    context "when the admin enters the correct credentials" do
      before do
        admin = add_test_admin_to_db
        
        visit "/employee-login-page"
        fill_in "username", with: admin.username
        fill_in "password", with: "validPass7!"
        click_on "Log-in"
      end

      it "then logs in successfully and displays the admin main page" do
        expect(page).to have_content "Register an Employee"
        expect(page).to have_content "Log out"
      end

      it "then logs them out if they click the Log out button and displays the employeelogin page" do
        click_on "Log out"

        expect(page).to have_content "Employee Log-in"
      end
    end
  end
end
