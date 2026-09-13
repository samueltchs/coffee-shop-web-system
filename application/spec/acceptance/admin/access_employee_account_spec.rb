RSpec.describe "Accessing the view of an employee account" do
  context "given the admin is logged in" do
    before do
      admin = add_test_admin_to_db
      login_as_employee(admin)
    end

    context "when the admin accesses a barista's account view" do
      it "then redirects to the barista main page" do
        add_test_barista_to_db("barista")
        visit "/admin-employee?username=barista"
        click_on "Access Employee Account View"
        
        expect(page).to have_content "barista"
      end
    end

    context "when the admin accesses a manager's account view" do
      it "then redirects to the manager dashboard" do
        add_test_manager_to_db
        visit "/admin-employee?username=manager"
        click_on "Access Employee Account View"

        expect(page).to have_content "Dashboard"
      end
    end
  end
end