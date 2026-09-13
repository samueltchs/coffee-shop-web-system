RSpec.describe "Trying to login as a suspended customer" do
  context "given a customer is suspended" do
    context "when the customer tries logging in" do
      it "then does not let them in their account and informs them of their suspension" do
        suspended_cust = add_suspended_customer_to_db
        login_as_customer(suspended_cust)

        expect(page).to have_content "Your account has been suspended due to inactivity. Please check your emails."
      end
    end
  end
end
