RSpec.describe "Changing an order's status" do
  context "given the admin is logged in" do
    before do
      admin = add_test_admin_to_db
      add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC12345", "Online", 1, "Incomplete", "Unpaid")
      login_as_employee(admin)
    end

    context "when no status is selected" do
      it "then tells the admin the status is not valid" do
        visit "/admin-order?order_id=1"
        select "-- Select --", from: "status"
        fill_in "reason_note", with: "proof"
        click_on "Change"

        expect(page).to have_content "The order's status is not valid."
      end
    end

    context "when the same status as the current one is selected" do
      it "then tells the admin the status must not be the same" do
        visit "/admin-order?order_id=1"
        select "Unpaid", from: "status"
        fill_in "reason_note", with: "proof"
        click_on "Change"

        expect(page).to have_content "The order's status must not be the same as the current one."
      end
    end

    context "when a valid status is selected but no reason note is submitted" do
      it "then tells the admin that a reason note is required" do
        visit "/admin-order?order_id=1"
        select "Paid", from: "status"
        click_on "Change"

        expect(page).to have_content "A reason note is required."
      end
    end

    context "when a valid status is selected and a reason note is submitted" do
      it "then displays a confirmation message" do
        visit "/admin-order?order_id=1"
        select "Paid", from: "status"
        fill_in "reason_note", with: "sufficient proof"
        click_on "Change"

        expect(page).to have_content "The order's status has been updated successfully."
      end
    end
  end
end
