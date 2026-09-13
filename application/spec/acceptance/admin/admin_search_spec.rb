RSpec.describe "Searching as the admin" do
  context "given the admin is logged in" do
    before do
      admin = add_test_admin_to_db
      login_as_employee(admin)
    end

    context "when the admin makes a search" do
      it "then only displays the matching entries" do
        add_test_barista_to_db("barista", "John")
        add_test_order_to_db(1, Time.now.utc, 7.3)
        add_test_customer_to_db(1, "George")

        visit "/admin-main"
        fill_in "admin_search", with: "George"
        click_on "Search"

        expect(page).to have_content "George"
        expect(page).not_to have_content "John"
        expect(page).not_to have_content "7.3"
      end
    end

    context "when the admin searches for a customer by loyalty number" do
      it "then only displays the matching customer entry" do
        add_test_customer_to_db(3, "Mikel", "Merino")
        add_test_customer_to_db(4, "George", "Michael")

        visit "/admin-dashboard"
        fill_in "admin_search", with: "3"
        click_on "Search"

        expect(page).to have_content "Mikel"
        expect(page).not_to have_content "George"
      end
    end

    context "when the admin searches for a customer by email" do
      it "then only displays the matching customer entry" do
        add_test_customer_to_db(1, "Mikel", "Merino", "addr1", "addr2", "Shef", "S1 1AA", "77100002000", "mikel@gmail.com")
        add_test_customer_to_db(2, "George", "Michael", "addr1", "addr2", "Shef", "S1 1AA", "77100002001", "george@gmail.com")

        visit "/admin-settings"
        fill_in "admin_search", with: "mikel@gmail.com"
        click_on "Search"

        expect(page).to have_content "Mikel"
        expect(page).not_to have_content "George"
      end
    end

    context "when the admin searches for an employee by username" do
      it "then only displays the matching employee entry" do
        add_test_barista_to_db("barista1", "John", "Pork", "email1@gmail.com")
        add_test_barista_to_db("barista2", "George", "Michael", "email2@gmail.com")

        visit "/admin-inbox"
        fill_in "admin_search", with: "barista1"
        click_on "Search"

        expect(page).to have_content "John"
        expect(page).not_to have_content "George"
      end
    end

    context "when no matching entries are found" do
      it "then displays a no matching entries found message" do
        visit "/admin-main"
        fill_in "admin_search", with: "nonexistent"
        click_on "Search"

        expect(page).to have_content "No matching entries found."
      end
    end

    context "when the admin applies a filter" do
      it "then only displays the matching entries" do
        add_test_barista_to_db("barista", "John")
        add_test_customer_to_db(1, "Mikel")
        add_test_order_to_db(1, Time.now.utc, 7.3)

        visit "/admin-search"
        select "Customers", from: "filter"
        click_on "Apply Filter"

        expect(page).to have_content "Mikel"
        expect(page).not_to have_content "barista"
        expect(page).not_to have_content "7.3"
      end
    end

    context "when the admin applies a filter and then makes a search" do
      it "then only displays the matching entries" do
        add_test_barista_to_db("George", "George")
        add_test_customer_to_db(1, "George", "Black")
        add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC12345", "George")

        visit "/admin-search"
        select "Employees", from: "filter"
        click_on "Apply Filter"
        fill_in "admin_search", with: "George"
        click_on "Search"
        
        expect(page).to have_content "George"
        expect(page).not_to have_content "Black"
        expect(page).not_to have_content "ABC12345"
      end
    end

    context "when the admin clicks on the admin entry" do
      it "then navigates to the admin profile settings page" do
        visit "/admin-search"
        click_on "Admin"

        expect(page).to have_content "Admin profile"
      end
    end

    context "when the admin clicks on a customer entry" do
      it "then navigates to the customer's profile page" do
        add_test_customer_to_db(1, "Mikel", "Merino")

        visit "/admin-search"
        click_on "Mikel"

        expect(page).to have_content "Full Name: Mikel Merino"
      end
    end

    context "when the admin clicks on an employee entry" do
      it "then navigates to the employee's profile page" do
        add_test_barista_to_db("barista", "George", "Michael")

        visit "/admin-search"
        click_on "Michael"

        expect(page).to have_content "Full Name: George Michael"
      end
    end

    context "when the admin clicks on an order entry" do
      it "then navigates to the order's page" do
        order = add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC12345")

        visit "/admin-search"
        click_on "ABC12345"

        expect(page).to have_content "Order: #{order.order_unique_id}"
      end
    end
  end
end
