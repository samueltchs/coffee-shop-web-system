RSpec.describe "Updating admin last name" do
  context "given the admin is logged in" do
    before do
      @admin = add_test_admin_to_db("admin", "Craig", "Jones")
      login_as_employee(@admin)
    end

    context "when no input is submitted" do
      it "then tells the admin the last name cannot be empty" do
        visit "/admin-settings"
        fill_in "last", with: ""
        click_on "Update last name"

        expect(page).to have_content "Last name cannot be empty."
        expect(page).to have_content "Craig Jones"
      end
    end

    context "when the same last name is submitted" do
      it "then tells the admin the last name cannot be the same" do
        visit "/admin-settings"
        fill_in "last", with: @admin.last_name
        click_on "Update last name"

        expect(page).to have_content "Last name must not be the same as the current one."
        expect(page).to have_content "Craig Jones"
      end
    end

    context "when a last name that does not start with a capital letter is submitted" do
      it "then tells the admin the last name must start with a capital letter" do
        visit "/admin-settings"
        fill_in "last", with: "ioannou"
        click_on "Update last name"

        expect(page).to have_content "Last name must start with a capital letter."
        expect(page).to have_content "Craig Jones"
      end
    end

    context "when a last name with invalid characters is submitted" do
      it "then tells the admin the last name contains invalid characters" do
        visit "/admin-settings"
        fill_in "last", with: "Ioannou7"
        click_on "Update last name"

        expect(page).to have_content "Last name must contain only letters, hyphens, apostrophes and spaces."
        expect(page).to have_content "Craig Jones"
      end
    end

    context "when a valid last name is submitted" do
      it "then updates the last name and displays a confirmation message" do
        visit "/admin-settings"
        fill_in "last", with: "Carrick"
        click_on "Update last name"

        expect(page).to have_content "Last name updated successfully."
        expect(page).to have_content "Craig Carrick"
      end
    end
  end
end
