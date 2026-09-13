RSpec.describe "Deleting an employee account" do
  context "given the admin is logged in" do
    context "when the admin deletes a barista account with orders" do
      it "then displays a confirmation message and the deleted employee page" do
        admin = add_test_admin_to_db
        add_test_barista_to_db("user")
        add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC12345", "user")
        login_as_employee(admin)

        visit "/admin-employee?username=user"
        click_on "Delete Account"

        expect(page).to have_content "The former employee's account has been deleted successfully."
        expect(page).to have_content "Deleted Employee"
        expect(page).to have_content "Deleted At:"
        expect(page).not_to have_content "Reset password"
        expect(page).not_to have_content "Delete Account"
        expect(page).not_to have_content "Access Employee Account View"
      end
    end

    context "when the admin deletes a barista account with no orders fulfilled" do
      it "then redirects to the search page with a success message" do
        admin = add_test_admin_to_db
        add_test_barista_to_db("user")
        login_as_employee(admin)

        visit "/admin-employee?username=user"
        click_on "Delete Account"

        expect(page).to have_content "The former employee's account has been deleted successfully."
        expect(page).not_to have_content "Deleted Employee"
      end
    end

    context "when the admin deletes a manager account" do
      it "then redirects to the search page with a success message" do
        admin = add_test_admin_to_db
        add_test_manager_to_db("user")
        login_as_employee(admin)

        visit "/admin-employee?username=user"
        click_on "Delete Account"

        expect(page).to have_content "The former employee's account has been deleted successfully."
        expect(page).not_to have_content "Deleted Employee"
      end
    end
  end
end
