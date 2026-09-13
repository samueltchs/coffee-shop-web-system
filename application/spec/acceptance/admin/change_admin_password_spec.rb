RSpec.describe "Updating admin password" do
  context "given the admin is logged in" do
    before do
      @admin = add_test_admin_to_db
      login_as_employee(@admin)
    end

    context "when no input is submitted" do
      it "then does not display any message" do
        visit "/admin-settings"
        fill_in "password", with: ""
        fill_in "conf_password", with: ""
        click_on "Submit"

        possible_message_prefixes = [
          "Password has", "Password not", "Password is", "The passwords", "Password must"
        ]

        possible_message_prefixes.each do |message|
          expect(page).not_to have_content "#{message}"
        end
      end
    end

    context "when an invalid password is submitted" do
      it "then displays error messages" do
        visit "/admin-settings"
        fill_in "password", with: "invalid"
        fill_in "conf_password", with: "invalid"
        click_on "Submit"

        error_messages = [
          "Password is not valid. Must be 8+ characters with at least 1 uppercase, 1 digit and 1 special character.",
          "Password not updated. Requirements not met."
        ]

        error_messages.each do |error|
          expect(page).to have_content "#{error}"
        end
      end
    end

    context "when different passwords are submitted" do
      it "then displays error messages" do
        visit "/admin-settings"
        fill_in "password", with: "Admin17!"
        fill_in "conf_password", with: "Admin18!"
        click_on "Submit"

        expect(page).to have_content "The passwords do not match."
        expect(page).to have_content "Password not updated. Requirements not met."
      end
    end 

    context "when the same password is submitted" do
      it "then displays error messages" do
        visit "/admin-settings"
        fill_in "password", with: "validPass7!"
        fill_in "conf_password", with: "validPass7!"
        click_on "Submit"

        expect(page).to have_content "Password must not be the same as the current one."
        expect(page).to have_content "Password not updated. Requirements not met."
      end
    end

    context "when only the Update password field is submitted" do
      it "then displays error messages" do
        visit "/admin-settings"
        fill_in "password", with: "Admin17!"
        fill_in "conf_password", with: ""
        click_on "Submit"

        expect(page).to have_content "The passwords do not match."
        expect(page).to have_content "Password not updated. Requirements not met."
      end
    end

    context "when only the Confirm new password field is submitted" do
      it "then does not display any message" do
        visit "/admin-settings"
        fill_in "password", with: ""
        fill_in "conf_password", with: "Admin17!"
        click_on "Submit"

        possible_message_prefixes = [
          "Password has", "Password not", "Password is", "The passwords", "Password must"
        ]

        possible_message_prefixes.each do |message|
          expect(page).not_to have_content "#{message}"
        end
      end
    end
        
    context "when a valid password is submitted" do
      it "then displays a confirmation message" do
        visit "/admin-settings"
        fill_in "password", with: "Admin17!"
        fill_in "conf_password", with: "Admin17!"
        click_on "Submit"

        expect(page).to have_content "Password has been updated successfully."
      end
    end
  end
end
