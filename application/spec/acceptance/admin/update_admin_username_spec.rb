RSpec.describe "Updating admin username" do
  context "given the admin is logged in" do
    before do
      @admin = add_test_admin_to_db("admin_username")
      login_as_employee(@admin)
    end

    context "when no input is submitted" do
      it "then tells the admin the username cannot be empty" do
        visit "/admin-settings"
        fill_in "username", with: ""
        click_on "Update username"

        expect(page).to have_content "Username cannot be empty."
        expect(page).to have_content "admin_username"
      end
    end

    context "when a username with spaces is submitted" do
      it "then tells the admin the username cannot contain spaces" do
        visit "/admin-settings"
        fill_in "username", with: "user name"
        click_on "Update username"

        expect(page).to have_content "Username cannot contain spaces."
        expect(page).to have_content "admin_username"
      end
    end

    context "when the same username is submitted" do
      it "then tells the admin the username cannot be the same" do
        visit "/admin-settings"
        fill_in "username", with: @admin.username
        click_on "Update username"

        expect(page).to have_content "Username must not be the same as the current one."
        expect(page).to have_content "admin_username"
      end
    end

    context "when an already taken username is submitted" do
      it "then tells the admin the username already exists" do
        add_test_barista_to_db("existing_username")

        visit "/admin-settings"
        fill_in "username", with: "existing_username"
        click_on "Update username"

        expect(page).to have_content "Username already exists."
        expect(page).to have_content "admin_username"
      end
    end

    context "when a valid username is submitted" do
      it "then updates the username and displays a confirmation message" do
        visit "/admin-settings"
        fill_in "username", with: "new_admin_username"
        click_on "Update username"

        expect(page).to have_content "Username updated successfully."
        expect(page).to have_content "new_admin_username"
      end
    end
  end
end
