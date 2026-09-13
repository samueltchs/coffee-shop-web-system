RSpec.describe "Updating admin email" do
  context "given the admin is logged in" do
    before do
      @admin = add_test_admin_to_db("admin", "Name", "Surname", "email@gmail.com")
      login_as_employee(@admin)
    end

    context "when no input is submitted" do
      it "then tells the admin the email cannot be empty" do
        visit "/admin-settings"
        fill_in "email", with: ""
        click_on "Update email"

        expect(page).to have_content "Email cannot be empty."
        expect(page).to have_content "email@gmail.com"
      end
    end

    context "when the same email is submitted" do
      it "then tells the admin the email cannot be the same" do
        visit "/admin-settings"
        fill_in "email", with: @admin.email
        click_on "Update email"

        expect(page).to have_content "Email must not be the same as the current one."
        expect(page).to have_content "email@gmail.com"
      end
    end

    context "when an already taken email is submitted" do
      it "then tells the admin the email already exists" do
        add_test_barista_to_db("barista", "Name", "Surname", "existing@gmail.com")

        visit "/admin-settings"
        fill_in "email", with: "existing@gmail.com"
        click_on "Update email"

        expect(page).to have_content "Email already exists."
        expect(page).to have_content "email@gmail.com"
      end
    end

    context "when an invalid email is submitted" do
      it "then tells the admin the email is not valid" do
        visit "/admin-settings"
        fill_in "email", with: "invalidgmail.com"
        click_on "Update email"

        expect(page).to have_content "Email is not valid."
        expect(page).to have_content "email@gmail.com"
      end
    end

    context "when a valid email is submitted" do
      it "then updates the email and displays a confirmation message" do
        visit "/admin-settings"
        fill_in "email", with: "admin@gmail.com"
        click_on "Update email"

        expect(page).to have_content "Email updated successfully."
        expect(page).to have_content "admin@gmail.com"
      end
    end
  end
end
