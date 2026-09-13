RSpec.describe "Verifying a payment reference id" do
  context "given the admin is logged in" do
    before do
      admin = add_test_admin_to_db
      add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC12345", "Online", 1, "Incomplete", "Unpaid")
      login_as_employee(admin)
    end

    context "when an invalid reference id is submitted" do
      it "then tells the admin the reference id is not valid" do
        visit "/admin-order?order_id=1"
        fill_in "reference_id", with: "invalid"
        click_on "Submit"

        expect(page).to have_content(
          "The Reference ID is not valid. Must be 8-12 characters long and be of the form ABC1234567."
        )
      end
    end

    context "when the same reference id as current one is submitted" do
      it "then tells the admin the reference id cannot be the same" do
        visit "/admin-order?order_id=1"
        fill_in "reference_id", with: "ABC12345"
        click_on "Submit"

        expect(page).to have_content "The Reference ID must not be the same as the current one."
      end
    end

    context "when an existing reference id is submitted" do
      it "then tells the admin the reference id already exists" do
        add_test_order_to_db(2, Time.now.utc, 7.3, 7.7, 1, "ABC123456")

        visit "/admin-order?order_id=1"
        fill_in "reference_id", with: "ABC123456"
        click_on "Submit"

        expect(page).to have_content "The Reference ID already exists."
      end
    end

    context "when a reference id that cannot be verified is submitted" do
      it "then tells the admin the reference id could not be verified" do
        visit "/admin-order?order_id=1"
        fill_in "reference_id", with: "ABC54321"
        click_on "Submit"

        expect(page).to have_content "The Reference ID could not be verified."
      end
    end

    context "when the reference id submitted is successfully verified" do
      it "then displays a confirmation message" do
        visit "/admin-order?order_id=1"
        fill_in "reference_id", with: "ABC123456"
        click_on "Submit"

        expect(page).to have_content(
          "The payment has been successfully verified. Please proceed with marking the order as paid."
        )
      end
    end
  end
end
