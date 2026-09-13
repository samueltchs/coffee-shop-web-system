RSpec.describe "Reactivating a customer account" do
  context "given the admin is logged in" do
    before do
      admin = add_test_admin_to_db
      login_as_employee(admin)
    end

    context "when reactivating a suspended due to inactivity for less than 3 months customer" do
      it "then displays a confirmation message and the now active customer page" do
        add_suspended_customer_to_db(1, Time.now.utc - SECONDS_IN_DAY * 5, Time.now.utc, 1)
        visit "/admin-customer?loyalty_number=1"
        click_on "Reactivate Account"

        expect(page).to have_content "The user's account has successfully been reactivated as per their request."
        expect(page).to have_content "View the account reactivation email"
        expect(page).to have_content "Suspend Account"
        expect(page).not_to have_content "Flagged at:"
        expect(page).not_to have_content "Suspended at:"
        expect(page).not_to have_content "Reactivate Account"
        expect(page).not_to have_content "Delete Account"
      end
    end

    context "when reactivating a suspended due to disciplinary reasons customer" do
      it "then displays a confirmation message and the now active customer page" do
        add_suspended_customer_to_db(1, nil, Time.now.utc, 2)
        visit "/admin-customer?loyalty_number=1"
        click_on "Reactivate Account"

        expect(page).to have_content "The user's account has successfully been reactivated as per their request."
        expect(page).to have_content "View the account reactivation email"
        expect(page).to have_content "Suspend Account"
        expect(page).not_to have_content "Flagged at:"
        expect(page).not_to have_content "Suspended at:"
        expect(page).not_to have_content "Reactivate Account"
        expect(page).not_to have_content "Delete Account"
      end
    end
  end
end
