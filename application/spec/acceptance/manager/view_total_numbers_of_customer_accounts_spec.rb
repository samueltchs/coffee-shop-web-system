RSpec.describe "View total numbers of customer accounts" do
  context "given logged in as manager" do
    before do
      #login as manager
      manager = add_test_manager_to_db
      login_as_employee(manager)

      #add 2 account holders
      add_test_customer_to_db
      add_test_customer_to_db(2)
    end

    context "Enter the customer tab" do
      before do
        #enter the customers page
        click_link "Customers"
      end

      it "shows the total current numbers of account holders" do
        expect(page).to have_content "Total Accounts: 2"
      end

      context "when refreshed" do
        it "update the total current numbers of account holders" do
          expect(page).to have_content "Total Accounts: 2"
          
          #add two more accounts
          add_test_customer_to_db(3)
          add_test_customer_to_db(4)

          #refresh
          click_link "Customers"
          expect(page).to have_content "Total Accounts: 4"
        end
      end
    end
  end
end