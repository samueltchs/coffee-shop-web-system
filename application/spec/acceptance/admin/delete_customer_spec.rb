RSpec.describe "Deleting a customer account" do
  context "given the admin is logged in" do
    before do
      admin = add_test_admin_to_db
      login_as_employee(admin)
    end

    context "when deleting a suspended due to inactivity customer past 3 months" do
      it "then displays a confirmation message and the deleted customer page" do
        add_suspended_customer_to_db(1, Time.now.utc - SECONDS_IN_DAY * 95, Time.now.utc - SECONDS_IN_MONTH * 3, 1)
        visit "/admin-customer?loyalty_number=1"
        click_on "Delete Account"

        expect(page).to have_content "The customer has been deleted."
        expect(page).to have_content "View the account deletion email"
        expect(page).to have_content "Deleted Customer"
        expect(page).to have_content "Deleted at:"
        expect(page).not_to have_content "Suspended at:"
        expect(page).not_to have_content "Flagged at:"
        expect(page).not_to have_content "Reactivate Account"
        expect(page).not_to have_content "Suspend Account"
        expect(page).not_to have_content "Delete Account"
      end
    end

    context "when deleting a suspended due to disciplinary reasons customer" do
      it "then displays a confirmation message and the deleted customer page" do
        add_suspended_customer_to_db(1, nil, Time.now.utc - SECONDS_IN_MONTH * 3, 2)
        visit "/admin-customer?loyalty_number=1"
        click_on "Delete Account"

        expect(page).to have_content "The customer has been deleted."
        expect(page).to have_content "View the account deletion email"
        expect(page).to have_content "Deleted Customer"
        expect(page).to have_content "Deleted at:"
        expect(page).not_to have_content "Suspended at:"
        expect(page).not_to have_content "Flagged at:"
        expect(page).not_to have_content "Reactivate Account"
        expect(page).not_to have_content "Suspend Account"
        expect(page).not_to have_content "Delete Account"
      end
    end
  end
end
