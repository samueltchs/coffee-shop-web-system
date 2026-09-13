RSpec.describe "Searching for a user or order that does not exist" do
  context "given the admin is logged in" do
    before do
      admin = add_test_admin_to_db
      login_as_employee(admin)
    end

    context "when the admin searches for a customer that does not exist" do
      it "then redirects to the admin search page with an error" do
        visit "/admin-customer?loyalty_number=1"
        expect(page).to have_content "User not found or deleted."
      end
    end

    context "when the admin searches for an employee that does not exist" do
      it "then redirects to the admin search page with an error" do
        visit "/admin-employee?username=nonexistent"
        expect(page).to have_content "User not found or deleted."
      end
    end

    context "when the admin searches for an order that does not exist" do
      it "then redirects to the admin search page with an error" do
        visit "/admin-order?order_id=1"
        expect(page).to have_content "Order not found."
      end
    end

    context "when the admin visits a customer route without a loyalty number param" do
      it "then redirects to the admin search page with an error" do
        visit "/admin-customer"
        expect(page).to have_content "User not found or deleted."
      end
    end

    context "when the admin visits an employee route without a username param" do
      it "then redirects to the admin search page with an error" do
        visit "/admin-employee"
        expect(page).to have_content "User not found or deleted."
      end
    end

    context "when the admin visits an order route without an order id param" do
      it "then redirects to the admin search page with an error" do
        visit "/admin-order"
        expect(page).to have_content "Order not found."
      end
    end
  end
end
