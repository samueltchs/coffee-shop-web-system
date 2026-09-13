RSpec.describe "Updating admin first name" do
  context "given the admin is logged in" do
    before do
      @admin = add_test_admin_to_db("admin", "Craig", "Jones")
      login_as_employee(@admin)
    end

    context "when no input is submitted" do
      it "then tells the admin the first name cannot be empty" do
        visit "/admin-settings"
        fill_in "first", with: ""
        click_on "Update first name"

        expect(page).to have_content "First name cannot be empty."
        expect(page).to have_content "Craig Jones"
      end
    end

    context "when the same first name is submitted" do
      it "then tells the admin the first name cannot be the same" do
        visit "/admin-settings"
        fill_in "first", with: @admin.first_name
        click_on "Update first name"

        expect(page).to have_content "First name must not be the same as the current one."
        expect(page).to have_content "Craig Jones"
      end
    end

    context "when a first name that does not start with a capital letter is submitted" do
      it "then tells the admin the first name must start with a capital letter" do
        visit "/admin-settings"
        fill_in "first", with: "alex"
        click_on "Update first name"

        expect(page).to have_content "First name must start with a capital letter."
        expect(page).to have_content "Craig Jones"
      end
    end

    context "when a first name with invalid characters is submitted" do
      it "then tells the admin the first name contains invalid characters" do
        visit "/admin-settings"
        fill_in "first", with: "Alex123"
        click_on "Update first name"

        expect(page).to have_content "First name must contain only letters, hyphens, apostrophes and spaces."
        expect(page).to have_content "Craig Jones"
      end
    end

    context "when a valid first name is submitted" do
      it "then updates the first name and displays a confirmation message" do
        visit "/admin-settings"
        fill_in "first", with: "Alex"
        click_on "Update first name"

        expect(page).to have_content "First name updated successfully."
        expect(page).to have_content "Alex Jones"
      end
    end
  end
end
