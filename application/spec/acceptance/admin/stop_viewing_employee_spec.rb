RSpec.describe "Stopping viewing an employee account" do
  context "given the admin is viewing an employee account" do
    it "then redirects back to the employee's page" do
      admin = add_test_admin_to_db
      add_test_barista_to_db("barista", "George", "Michael")
      login_as_employee(admin)

      visit "/admin-employee?username=barista"
      click_on "Access Employee Account View"
      visit "/admin-stop-viewing"

      expect(page).to have_content "Full Name: George Michael"
    end
  end
end
