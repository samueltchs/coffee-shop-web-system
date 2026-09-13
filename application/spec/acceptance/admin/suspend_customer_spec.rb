RSpec.describe "Suspending a customer account" do
  context "given the admin is logged in" do
    before do
      admin = add_test_admin_to_db
      login_as_employee(admin)
    end

    context "when suspending a flagged customer" do
      it "then displays a confirmation message and the suspended customer page" do
        add_flagged_customer_to_db(1)
        visit "/admin-customer?loyalty_number=1"
        click_on "Suspend Account"

        expect(page).to have_content "The user has been suspended."
        expect(page).to have_content "View the account suspension email"
        expect(page).to have_content "Flagged at:"
        expect(page).to have_content "Suspended at:"
        expect(page).to have_content "Reactivate Account"
        expect(page).not_to have_content "Suspend Account"
        expect(page).not_to have_content "Delete Account"
      end
    end

    context "when suspending an active customer" do
      it "then displays a confirmation message and the suspended customer page" do
        add_test_customer_to_db(1)
        visit "/admin-customer?loyalty_number=1"
        click_on "Suspend Account"

        expect(page).to have_content "The user has been suspended."
        expect(page).to have_content "View the account suspension email"
        expect(page).to have_content "Suspended at:"
        expect(page).not_to have_content "Flagged at:"
        expect(page).to have_content "Reactivate Account"
        expect(page).to have_content "Delete Account"
        expect(page).not_to have_content "Suspend Account"
      end
    end
  end
end
