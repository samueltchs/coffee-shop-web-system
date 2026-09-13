RSpec.describe "Viewing refunds" do
  context "given the manager is logged in" do
    before do
      manager = add_test_manager_to_db
      login_as_employee(manager)
    end

    context "when there are no refunds" do
      it "shows the empty refunds page" do
        visit "/manager/refunds"

        expect(page).to have_content "Total refunds: 0"
      end
    end

    context "when refunds exist in the db" do
      it "shows the refunds in the table" do
        add_test_customer_to_db(1, "Manny", "Belkacem")
        add_test_refund_to_db(1, "wrong drink", "Pending")
        add_test_refund_to_db(1, "cold coffee", "Resolved")

        visit "/manager/refunds"

        expect(page).to have_content "Total refunds: 2"
        expect(page).to have_content "Manny Belkacem"
        expect(page).to have_content "wrong drink"
        expect(page).to have_content "cold coffee"
        expect(page).to have_content "Pending"
        expect(page).to have_content "Resolved"
      end

      it "shows the table headers" do
        visit "/manager/refunds"

        expect(page).to have_content "Refund ID"
        expect(page).to have_content "Customer"
        expect(page).to have_content "Reason"
        expect(page).to have_content "Status"
        expect(page).to have_content "Date"
      end
    end
  end

  context "given the user is not logged in" do
    it "redirects to the login page" do
      visit "/manager/refunds"

      expect(page).to have_content "Login required"
    end
  end
end