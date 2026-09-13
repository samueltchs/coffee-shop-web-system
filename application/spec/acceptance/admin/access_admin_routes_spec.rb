RSpec.describe "Accessing admin routes" do
  context "given a user is not logged in as the admin" do
    context "when the user tries accessing an admin route" do
      it "then redirects them to the employee login page with an error" do
        visit "/admin-main"
        expect(page).to have_content("Access denied : Login required.")
      end
    end

    context "when the user is logged in as a barista" do
      it "then does not let them access an admin route" do
        barista = add_test_barista_to_db
        login_as_employee(barista)
        visit "/admin-main"

        expect(page).not_to have_content "Register an Employee"
      end
    end

    context "when the user is logged in as a manager" do
      it "then does not let them access an admin route" do
        manager = add_test_manager_to_db
        login_as_employee(manager)
        visit "/admin-main"

        expect(page).not_to have_content "Register an Employee"
      end
    end
  end
end
