RSpec.describe "View monthly changes in account signup" do
  context "given logged in as manager" do
    before do
      #login as manager
      manager = add_test_manager_to_db
      login_as_employee(manager)
    end

    context "Enter the customer tab" do
      it "shows the number of new accounts signed up in the current month" do
        #add 2 customers that signs up this moment
        reg_now_customer1 = add_test_customer_to_db
        reg_now_customer2 = add_test_customer_to_db(
          2, "Tester", "Test", "address1", "address2", "Sheffield",
          "S1 1AA", "7710002000", "email@gmail.com", 0, Time.now.utc, "Active"
        )

        #enter the customers page
        click_link "Customers"

        #sees the sign up number
        expect(page).to have_content "Current Month Sign-up: 2"
      end

      context "when I press view" do
        it "shows a line graph of monthly signup in the past 12 months" do
          #enter the customers page
          click_link "Customers"

          #graph shows when #signup-graph hides when #
          expect(page).to have_link("View", href: "#signup-graph")
          #click view to pull up the graph
          click_link "View"

          expect(page.html).to include("Customer Account Registrations")
          expect(page.html).to include("signup-graph")
          within "#signup-graph" do
            expect(page).to have_css(".popup")
            expect(page).to have_link("close")
          end
        end
      end
    end
  end
end