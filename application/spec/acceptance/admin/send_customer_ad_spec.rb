RSpec.describe "Sending and viewing a customer ad" do
  context "given the customer has bought at least 3 items" do
    context "when the admin sends the customer an ad" do
      it "then displays ad the preview to the admin and the ad to the customer" do
        admin = add_test_admin_to_db
        customer = add_test_customer_to_db(1)
        add_test_size_to_db
        add_test_milk_option_to_db
        add_test_country_to_db
        add_test_roast_level_to_db
        add_test_product_to_db("Coffee", "Latte", 1, 1, 1, 1, "classic")
        add_test_product_to_db("Coffee", "Cappuccino", 1, 1, 1, 1, "refreshment")
        add_test_product_to_db("Coffee", "Mocha", 1, 1, 1, 1, "sweet")
        add_test_product_variant_to_db(1, 1, 1, 3.7)
        add_test_product_variant_to_db(2, 1, 1, 4.7)
        add_test_product_variant_to_db(3, 1, 1, 5.7)
        add_test_order_to_db(1)
        add_test_item_in_order_to_db(1, 1, 3.7, 1, 1, 1)
        add_test_item_in_order_to_db(2, 1, 4.7, 1, 1, 1)
        add_test_item_in_order_to_db(3, 1, 5.7, 1, 1, 1)

        login_as_employee(admin)
        visit "/admin-customer?loyalty_number=1"
        click_on "Send ad"

        expect(page).to have_content "Latte"
        expect(page).to have_content "Cappuccino"
        expect(page).to have_content "Mocha"
        expect(page).to have_content "Back to customer's profile"

        visit "/employee-logout"
        login_as_customer(customer)
        visit "/customer/dashboard"

        expect(page).to have_content "View your latest promotion"

        click_link "View your latest promotion"

        expect(page).to have_content "Latte"
        expect(page).to have_content "Cappuccino"
        expect(page).to have_content "Mocha"
        expect(page).to have_content "Back to dashboard"
      end
    end
  end
end
