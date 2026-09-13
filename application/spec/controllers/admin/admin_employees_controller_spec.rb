RSpec.describe "admin employees controller" do
  include Conversions
  include EmployeeHelpers
  include LocalHelpers

  describe "GET /admin-employee" do
    context "when viewing a non-deleted barista account" do
      before do
        @admin = add_test_admin_to_db
        @barista = add_test_barista_to_db("barista", "George", "Michael", "barista@gmail.com", "Barista")
        get_as_employee(@admin, "/admin-employee?username=barista")
      end

      it "has a status code of 200 (OK)" do
        expect(last_response).to be_ok
      end

      it "displays the correct title" do
        expect(last_response.body).to include("<title>George Michael - Employee Admin View</title>")
      end

      it "displays the employee's full name as headline" do
        expect(last_response.body).to include("<h1>Full Name: George Michael</h1>")
      end

      it "displays the employee's username" do
        expect(last_response.body).to include("Username:")
        expect(last_response.body).to include("barista")
      end

      it "displays the employee's email" do
        expect(last_response.body).to include("Email:")
        expect(last_response.body).to include("barista@gmail.com")
      end

      it "displays the employee's role" do
        expect(last_response.body).to include("Role:")
        expect(last_response.body).to include("Barista")
      end

      it "displays when the employee registered their account" do
        expect(last_response.body).to include("Registered At:")
        formatted_registered_time = uk_time(Time.parse(@barista.registered_time)).strftime("%d/%m/%Y %H:%M")
        expect(last_response.body).to include(formatted_registered_time)
      end

      it "displays the reset password form" do
        expect(last_response.body).to include('action="/admin-employee-reset-password"')
      end

      it "displays the label for the password input field" do
        expect(last_response.body).to include("Update password:")
      end

      it "contains password input field" do
        expect(last_response.body).to include('name="password"')
      end

      it "displays the label for the confirm password input field" do
        expect(last_response.body).to include("Confirm new password:")
      end

      it "contains confirm password input field" do
        expect(last_response.body).to include('name="conf_password"')
      end

      it "contains the reset password button" do
        expect(last_response.body).to include("Reset password")
      end

      it "masks the password fields in the reset password form" do
        expect(last_response.body).to include('type="password"')
      end

      it "contains the delete employee form" do
        expect(last_response.body).to include('action="/admin-employee-delete"')
      end

      it "contains the delete account button" do
        expect(last_response.body).to include("Delete Account")
      end

      it "does not contain link to the barista's orders page if they have not fulfilled any orders" do
        expect(last_response.body).not_to include("/admin-employee-orders?username=barista")
      end

      it "contains link to the barista's orders page if barista has fulfilled orders" do
        add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC12345", "barista")
        get_as_employee(@admin, "/admin-employee?username=barista")
        expect(last_response.body).to include("/admin-employee-orders?username=barista")
      end

      it "contains the access employee account form" do
        expect(last_response.body).to include('action="/admin-access-employee-account"')
      end

      it "contains the access employee account view button" do
        expect(last_response.body).to include("Access Employee Account View")
      end
    end

    context "when viewing a non-deleted manager account" do
      it "does not contain a link to an orders page" do
        admin = add_test_admin_to_db
        add_test_manager_to_db("manager")
        get_as_employee(admin, "/admin-employee?username=manager")
        expect(last_response.body).not_to include("/admin-employee-orders?username=manager")
      end
    end

    context "when viewing a deleted barista account" do
      before do
        admin = add_test_admin_to_db
        deleted_barista = add_deleted_employee_to_db
        @deleted_barista = Employee.first(username: deleted_barista.username)
        get_as_employee(admin, "/admin-employee?username=#{@deleted_barista.username}")
      end

      it "displays the correct title" do
        expect(last_response.body).to include("<title>Deleted #{@deleted_barista.last_name} - Employee Admin View</title>")
      end

      it "displays the correct headline" do
        expect(last_response.body).to include("<h1>Deleted Employee</h1>")
      end

      it "displays when the employee account got deleted" do
        expect(last_response.body).to include("Deleted At:")
        formatted_deletion_time = uk_time(Time.parse(@deleted_barista.deleted_at)).strftime("%d/%m/%Y %H:%M")
        expect(last_response.body).to include(formatted_deletion_time)
      end

      it "does not display the reset password form" do
        expect(last_response.body).not_to include('action="/admin-employee-reset-password"')
      end

      it "does not display the label for the password input field" do
        expect(last_response.body).not_to include("Update password:")
      end

      it "does not contain the password input field" do
        expect(last_response.body).not_to include('name="password"')
      end

      it "does not display the label for the confirm password input field" do
        expect(last_response.body).not_to include("Confirm new password:")
      end

      it "does not contain the confirm password input field" do
        expect(last_response.body).not_to include('name="conf_password"')
      end

      it "does not contain the reset password button" do
        expect(last_response.body).not_to include("Reset password")
      end

      it "does not contain the delete employee form" do
        expect(last_response.body).not_to include('action="/admin-employee-delete"')
      end

      it "does not contain the delete account button" do
        expect(last_response.body).not_to include("Delete Account")
      end

      it "does not contain the access employee account form" do
        expect(last_response.body).not_to include('action="/admin-access-employee-account"')
      end

      it "does not contain the access employee account view button" do
        expect(last_response.body).not_to include("Access Employee Account View")
      end
    end

    context "when viewing a barista account after deleting it" do
      before do
        admin = add_test_admin_to_db
        @barista = add_test_barista_to_db
        add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC12345", @barista.username)
        new_username = anonymize_employee(@barista)
        @deleted_barista = Employee.first(username: new_username)
        get_as_employee(admin, "/admin-employee?username=#{new_username}")
      end

      it "displays a new anonymized username" do
        expect(last_response.body).to include("Username:")
        expect(last_response.body).not_to include(@barista.username)
        expect(last_response.body).to include(@deleted_barista.username)
      end

      it "displays their role as deleted" do
        expect(last_response.body).to include("Role:")
        expect(last_response.body).not_to include("Barista")
        expect(last_response.body).to include("Deleted")
      end

      it "does not display their old email" do
        expect(last_response.body).to include("Email:")
        expect(last_response.body).not_to include(@barista.email)
      end

      it "still contains link to the barista's orders page if barista has fulfilled orders" do
        expect(last_response.body).to include("/admin-employee-orders?username=#{@deleted_barista.username}")
      end
    end

    context "when viewing a manager account after deleting it" do
      it "still does not contain any link to an orders page" do
        admin = add_test_admin_to_db
        manager = add_test_manager_to_db
        new_username = anonymize_employee(manager)
        get_as_employee(admin, "/admin-employee?username=#{new_username}")
        expect(last_response.body).not_to include("/admin-employee-orders?username=#{new_username}")
      end
    end

    context "when an employee is not found" do
      it "redirects to the admin search page" do
        admin = add_test_admin_to_db
        get_as_employee(admin, "/admin-employee?username=barista")
        expect(last_response).to be_redirect
        expect(last_response.location).to include("/admin-search?error")
      end
    end
  end

  describe "GET /admin-add-employee" do
    context "when logged in as admin" do
      before do
        admin = add_test_admin_to_db
        get_as_employee(admin, "/admin-add-employee")
      end

      it "has a status code of 200 (OK)" do
        expect(last_response).to be_ok
      end

      it "displays the correct title" do
        expect(last_response.body).to include("<title>Register Employee</title>")
      end

      it "displays the correct headline" do
        expect(last_response.body).to include('<h1 class="add">Register Employee</h1>')
      end

      it "contains the add employee form" do
        expect(last_response.body).to include('action="/admin-add-employee"')
      end

      it "displays the label for the first name input field" do
        expect(last_response.body).to include("Enter first name:")
      end

      it "contains the first name input field" do
        expect(last_response.body).to include('name="first_name"')
      end

      it "displays the label for the last name input field" do
        expect(last_response.body).to include("Enter last name:")
      end

      it "contains the last name input field" do
        expect(last_response.body).to include('name="last_name"')
      end

      it "displays the label for the username input field" do
        expect(last_response.body).to include("Enter username:")
      end

      it "contains the username input field" do
        expect(last_response.body).to include('name="username"')
      end

      it "displays the label for the email input field" do
        expect(last_response.body).to include("Enter email:")
      end

      it "contains the email input field" do
        expect(last_response.body).to include('name="email"')
      end

      it "displays the label for the role dropdown" do
        expect(last_response.body).to include("Choose role:")
      end

      it "contains the role dropdown" do
        expect(last_response.body).to include('name="role"')
      end

      it "contains the default option value in the role dropdown" do
        expect(last_response.body).to include('value=""')
      end

      it "displays the default option text in the role dropdown" do
        expect(last_response.body).to include(">-- Select --<")
      end

      it "contains the barista option value in the role dropdown" do
        expect(last_response.body).to include('value="Barista"')
      end

      it "displays the barista option text in the role dropdown" do
        expect(last_response.body).to include(">Barista<")
      end

      it "contains the manager option value in the role dropdown" do
        expect(last_response.body).to include('value="Manager"')
      end

      it "displays the manager option text in the role dropdown" do
        expect(last_response.body).to include(">Manager<")
      end

      it "displays the label for the password input field" do
        expect(last_response.body).to include("Password:")
      end

      it "contains password input field" do
        expect(last_response.body).to include('name="password"')
      end

      it "displays the label for the confirm password input field" do
        expect(last_response.body).to include("Confirm password:")
      end

      it "contains the confirm password input field" do
        expect(last_response.body).to include('name="conf_password"')
      end

      it "masks the password fields in the reset password form" do
        expect(last_response.body).to include('type="password"')
      end

      it "contains the create account submit button" do
        expect(last_response.body).to include('value="Create account"')
      end

      it "does not display the warning message" do
        expect(last_response.body).not_to include(
                                            "Failure in registering the employee. Please provide valid details."
                                          )
      end
    end
  end

  describe "POST /admin-add-employee" do
    context "when admin submits form with no input" do
      before do
        admin = add_test_admin_to_db
        post_as_employee(admin, "/admin-add-employee", {})
      end

      it "has a status code of 200 (OK)" do
        expect(last_response).to be_ok
      end

      it "displays the warning message" do
        expect(last_response.body).to include(
                                        "Failure in registering the employee. Please provide valid details."
                                      )
      end

      it "tells the admin the first name cannot be empty" do
        expect(last_response.body).to include("First name cannot be empty.")
      end

      it "tells the admin the last name cannot be empty" do
        expect(last_response.body).to include("Last name cannot be empty.")
      end

      it "tells the admin the username cannot be empty" do
        expect(last_response.body).to include("Username cannot be empty.")
      end

      it "tells the admin the email cannot be empty" do
        expect(last_response.body).to include("Email cannot be empty.")
      end

      it "tells the admin the role cannot be empty" do
        expect(last_response.body).to include("Role cannot be empty.")
      end

      it "tells the admin the password is invalid" do
        expect(last_response.body).to include(
                                        "Password is not valid. Must be 8+ characters with at least 1 uppercase, 1 digit and 1 special character."
                                      )
      end

      it "does not save the employee in the database" do
        expect(Employee.count).to eq(1)
      end
    end

    context "when admin submits a username with spaces" do
      before do
        admin = add_test_admin_to_db
        post_as_employee(admin, "/admin-add-employee", {
          "first_name" => "George", "last_name" => "Michael", "username" => "user name",
          "email" => "email@gmail.com", "role" => "Barista",
          "password" => "validPass7!", "conf_password" => "validPass7!"
        })
      end

      it "displays error messages" do
        expect(last_response.body).to include(
                                        "Failure in registering the employee. Please provide valid details."
                                      )
        expect(last_response.body).to include("Username cannot contain spaces.")
      end

      it "does not save the employee in the database" do
        expect(Employee.count).to eq(1)
      end
    end

    context "when admin submits an existing username" do
      before do
        admin = add_test_admin_to_db("username")
        post_as_employee(admin, "/admin-add-employee", {
          "first_name" => "George", "last_name" => "Michael", "username" => "username",
          "email" => "email@gmail.com", "role" => "Barista",
          "password" => "validPass7!", "conf_password" => "validPass7!"
        })
      end

      it "displays error messages" do
        expect(last_response.body).to include(
                                        "Failure in registering the employee. Please provide valid details."
                                      )
        expect(last_response.body).to include("Username already exists.")
      end

      it "does not save the employee in the database" do
        expect(Employee.count).to eq(1)
      end
    end

    context "when admin submits a first name that does not start with a capital letter" do
      before do
        admin = add_test_admin_to_db
        post_as_employee(admin, "/admin-add-employee", {
          "first_name" => "george", "last_name" => "Michael", "username" => "username",
          "email" => "email@gmail.com", "role" => "Barista",
          "password" => "validPass7!", "conf_password" => "validPass7!"
        })
      end

      it "displays error messages" do
        expect(last_response.body).to include(
                                        "Failure in registering the employee. Please provide valid details."
                                      )
        expect(last_response.body).to include("First name must start with a capital letter.")
      end

      it "does not save the employee in the database" do
        expect(Employee.count).to eq(1)
      end
    end

    context "when admin submits a first name with invalid characters" do
      before do
        admin = add_test_admin_to_db
        post_as_employee(admin, "/admin-add-employee", {
          "first_name" => "George7", "last_name" => "Michael", "username" => "username",
          "email" => "email@gmail.com", "role" => "Barista",
          "password" => "validPass7!", "conf_password" => "validPass7!"
        })
      end

      it "displays error messages" do
        expect(last_response.body).to include(
                                        "Failure in registering the employee. Please provide valid details."
                                      )
        expect(last_response.body).to include("First name must contain only letters, hyphens, apostrophes and spaces.")
      end

      it "does not save the employee in the database" do
        expect(Employee.count).to eq(1)
      end
    end

    context "when admin submits a last name that does not start with a capital letter" do
      before do
        admin = add_test_admin_to_db
        post_as_employee(admin, "/admin-add-employee", {
          "first_name" => "George", "last_name" => "michael", "username" => "username",
          "email" => "email@gmail.com", "role" => "Barista",
          "password" => "validPass7!", "conf_password" => "validPass7!"
        })
      end

      it "displays error messages" do
        expect(last_response.body).to include(
                                        "Failure in registering the employee. Please provide valid details."
                                      )
        expect(last_response.body).to include("Last name must start with a capital letter.")
      end

      it "does not save the employee in the database" do
        expect(Employee.count).to eq(1)
      end
    end

    context "when admin submits a last name with invalid characters" do
      before do
        admin = add_test_admin_to_db
        post_as_employee(admin, "/admin-add-employee", {
          "first_name" => "George", "last_name" => "Michael7", "username" => "username",
          "email" => "email@gmail.com", "role" => "Barista",
          "password" => "validPass7!", "conf_password" => "validPass7!"
        })
      end

      it "displays error messages" do
        expect(last_response.body).to include(
                                        "Failure in registering the employee. Please provide valid details."
                                      )
        expect(last_response.body).to include("Last name must contain only letters, hyphens, apostrophes and spaces.")
      end

      it "does not save the employee in the database" do
        expect(Employee.count).to eq(1)
      end
    end

    context "when admin submits an existing email" do
      before do
        admin = add_test_admin_to_db("admin", "Craig", "Johnson", "email@gmail.com")
        post_as_employee(admin, "/admin-add-employee", {
          "first_name" => "George", "last_name" => "Michael", "username" => "username",
          "email" => "email@gmail.com", "role" => "Barista",
          "password" => "validPass7!", "conf_password" => "validPass7!"
        })
      end

      it "displays error messages" do
        expect(last_response.body).to include(
                                        "Failure in registering the employee. Please provide valid details."
                                      )
        expect(last_response.body).to include("Email already exists.")
      end

      it "does not save the employee in the database" do
        expect(Employee.count).to eq(1)
      end
    end

    context "when admin submits an invalid email" do
      before do
        admin = add_test_admin_to_db
        post_as_employee(admin, "/admin-add-employee", {
          "first_name" => "George", "last_name" => "Michael", "username" => "username",
          "email" => "invalidgmail.com", "role" => "Barista",
          "password" => "validPass7!", "conf_password" => "validPass7!"
        })
      end

      it "displays error messages" do
        expect(last_response.body).to include(
                                        "Failure in registering the employee. Please provide valid details."
                                      )
        expect(last_response.body).to include("Email is not valid.")
      end

      it "does not save the employee in the database" do
        expect(Employee.count).to eq(1)
      end
    end

    context "when admin submits an invalid password" do
      before do
        admin = add_test_admin_to_db
        post_as_employee(admin, "/admin-add-employee", {
          "first_name" => "George", "last_name" => "Michael", "username" => "username",
          "email" => "email@gmail.com", "role" => "Barista",
          "password" => "invalid", "conf_password" => "invalid"
        })
      end

      it "displays error messages" do
        expect(last_response.body).to include(
                                        "Failure in registering the employee. Please provide valid details."
                                      )
        expect(last_response.body).to include(
                                        "Password is not valid. Must be 8+ characters with at least 1 uppercase, 1 digit and 1 special character."
                                      )
      end

      it "does not save the employee in the database" do
        expect(Employee.count).to eq(1)
      end
    end

    context "when admin submits different passwords" do
      before do
        admin = add_test_admin_to_db
        post_as_employee(admin, "/admin-add-employee", {
          "first_name" => "George", "last_name" => "Michael", "username" => "username",
          "email" => "email@gmail.com", "role" => "Barista",
          "password" => "validPass7!", "conf_password" => "validPass8!"
        })
      end

      it "displays error messages" do
        expect(last_response.body).to include(
                                        "Failure in registering the employee. Please provide valid details."
                                      )
        expect(last_response.body).to include("The passwords do not match.")
      end

      it "does not save the employee in the database" do
        expect(Employee.count).to eq(1)
      end
    end

    context "when admin submits valid employee details" do
      before do
        admin = add_test_admin_to_db
        post_as_employee(admin, "/admin-add-employee", {
          "first_name" => "George", "last_name" => "Michael", "username" => "username",
          "email" => "email@gmail.com", "role" => "Barista",
          "password" => "validPass7!", "conf_password" => "validPass7!"
        })
      end

      it "displays a confirmation message" do
        expect(last_response.body).to include("Account has been successfully created!")
      end

      it "saves the employee in the database" do
        expect(Employee.count).to eq(2)
      end

      it "displays the new employee's details" do
        expect(last_response.body).to include("First name:")
        expect(last_response.body).to include("George")
        expect(last_response.body).to include("Last name:")
        expect(last_response.body).to include("Michael")
        expect(last_response.body).to include("Username:")
        expect(last_response.body).to include("username")
        expect(last_response.body).to include("Email address:")
        expect(last_response.body).to include("email@gmail.com")
        expect(last_response.body).to include("Role:")
        expect(last_response.body).to include("Barista")
      end

      it "contains a link back to the employee account creation page" do
        expect(last_response.body).to include('href="/admin-add-employee"')
      end

      it "does not display the headline" do
        expect(last_response.body).not_to include('<h1 class="add">Register Employee</h1>')
      end

      it "does not display the add employee form" do
        expect(last_response.body).not_to include('action="/admin-add-employee"')
      end
    end
  end

  describe "POST /admin-employee-reset-password" do
    context "when admin submits form with no input" do
      before do
        admin = add_test_admin_to_db
        @barista = add_test_barista_to_db("user")
        post_as_employee(admin, "/admin-employee-reset-password", {
          "username" => "user", "password" => "", "conf_password" => ""
        })
      end

      it "has a status code of 200 (OK)" do
        expect(last_response).to be_ok
      end

      it "does not display any message" do
        possible_message_prefixes = [
          "Password has", "Password not", "Password is", "The passwords", "Password must"
        ]

        possible_message_prefixes.each do |message|
          expect(last_response.body).not_to include(message)
        end
      end

      it "does not save the empty password" do
        @barista.refresh
        expect(@barista.authenticate("validPass7!")).to be true
      end
    end

    context "when admin submits an invalid password" do
      before do
        admin = add_test_admin_to_db
        @barista = add_test_barista_to_db("user")
        post_as_employee(admin, "/admin-employee-reset-password", {
          "username" => "user", "password" => "invalid", "conf_password" => "invalid"
        })
      end

      it "displays error messages" do
        expect(last_response.body).to include(
                                        "Password is not valid. Must be 8+ characters with at least 1 uppercase, 1 digit and 1 special character."
                                      )
        expect(last_response.body).to include("Password not updated. Requirements not met.")
      end

      it "does not save the invalid password" do
        @barista.refresh
        expect(@barista.authenticate("validPass7!")).to be true
      end
    end

    context "when admin submits different passwords" do
      before do
        admin = add_test_admin_to_db
        @barista = add_test_barista_to_db("user")
        post_as_employee(admin, "/admin-employee-reset-password", {
          "username" => "user", "password" => "validPass7!", "conf_password" => "validPass8!"
        })
      end

      it "displays error messages" do
        expect(last_response.body).to include("The passwords do not match.")
        expect(last_response.body).to include("Password not updated. Requirements not met.")
      end

      it "does not change the employee's password" do
        @barista.refresh
        expect(@barista.authenticate("validPass7!")).to be true
      end
    end

    context "when admin submits same password as current one" do
      before do
        admin = add_test_admin_to_db
        @barista = add_test_barista_to_db("user")
        post_as_employee(admin, "/admin-employee-reset-password", {
          "username" => "user", "password" => "validPass7!", "conf_password" => "validPass7!"
        })
      end

      it "displays error messages" do
        expect(last_response.body).to include("Password must not be the same as the current one.")
        expect(last_response.body).to include("Password not updated. Requirements not met.")
      end

      it "does not change the employee's password" do
        @barista.refresh
        expect(@barista.authenticate("validPass7!")).to be true
      end
    end

    context "when admin submits a valid password" do
      before do
        admin = add_test_admin_to_db
        add_test_barista_to_db("user")
        post_as_employee(admin, "/admin-employee-reset-password", {
          "username" => "user", "password" => "Barista17!", "conf_password" => "Barista17!"
        })
      end

      it "displays a confirmation message" do
        expect(last_response.body).to include("Password has been updated successfully.")
      end

      it "saves the password in the database" do
        barista = Employee.first(username: 'user')
        expect(barista.authenticate("Barista17!")).to be true
        expect(barista.authenticate("validPass7!")).to be false
      end
    end
  end

  describe "POST /admin-employee-delete" do
    context "when admin deletes a barista account with orders" do
      before do
        admin = add_test_admin_to_db
        add_test_barista_to_db("user")
        add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC12345", "user")
        post_as_employee(admin, "/admin-employee-delete", { "username" => "user" })
      end

      it "displays a confirmation message" do
        expect(last_response.body).to include("The former employee")
        expect(last_response.body).to include("account has been deleted successfully.")
      end

      it "anonymizes the employee in the database" do
        expect(Employee.first(username: 'user')).to be_nil
        expect(Employee.where(role: 'Deleted').count).to eq(1)
      end
    end

    context "when admin deletes a barista account with no orders" do
      before do
        admin = add_test_admin_to_db
        add_test_barista_to_db("user")
        post_as_employee(admin, "/admin-employee-delete", { "username" => "user" })
      end

      it "redirects to the admin search page" do
        expect(last_response).to be_redirect
        expect(last_response.location).to include("/admin-search?success")
      end

      it "completely removes the barista account record from the database" do
        expect(Employee.first(username: 'user')).to be_nil
        expect(Employee.where(role: 'Deleted').count).to eq(0)
      end
    end

    context "when admin deletes a manager account" do
      before do
        admin = add_test_admin_to_db
        add_test_manager_to_db("user")
        post_as_employee(admin, "/admin-employee-delete", { "username" => "user" })
      end

      it "redirects to the admin search page" do
        expect(last_response).to be_redirect
        expect(last_response.location).to include("/admin-search?success")
      end

      it "completely removes the manager account record from the database" do
        expect(Employee.first(username: 'user')).to be_nil
        expect(Employee.where(role: 'Deleted').count).to eq(0)
      end
    end
  end

  describe "GET /admin-employee-orders" do
    context "when a barista has fulfilled orders" do
      before do
        admin = add_test_admin_to_db
        add_test_barista_to_db("barista", "George", "Michael")
        @order = add_test_order_to_db(
          1, Time.now.utc, 7.3, 7.7, 1, "ABC12345", "barista"
        )
        get_as_employee(admin, "/admin-employee-orders?username=barista")
      end

      it "has a status code of 200 (OK)" do
        expect(last_response).to be_ok
      end

      it "displays the correct title" do
        expect(last_response.body).to include("<title>George Michael - Orders Fulfilled</title>")
      end

      it "displays the correct headline with order count" do
        expect(last_response.body).to include("George Michael - Orders Fulfilled (1)")
      end

      it "contains a link back to the employee's profile" do
        expect(last_response.body).to include("/admin-employee?username=barista")
      end

      it "contains a link to each order's page" do
        expect(last_response.body).to include("/admin-order?order_id=#{@order.order_unique_id}")
      end

      it "contains each order's id" do
        expect(last_response.body).to include("<th>ID</th>")
        expect(last_response.body).to include(@order.order_unique_id.to_s)
      end

      it "contains each order's date placed and displays it formatted" do
        expect(last_response.body).to include("<th>Date Placed</th>")
        expect(last_response.body).to include(format_date(@order.date_placed))
      end

      it "contains each order's price and displays it formatted" do
        expect(last_response.body).to include("<th>Price</th>")
        expect(last_response.body).to include(format_price(7.7))
      end

      it "contains each order's reference id" do
        expect(last_response.body).to include("<th>Reference ID</th>")
        expect(last_response.body).to include("ABC12345")
      end

      it "does not display the no order message" do
        expect(last_response.body).not_to include("The barista has not fulfilled any orders yet.")
      end
    end

    context "when a barista has not fulfilled any orders" do
      before do
        admin = add_test_admin_to_db
        add_test_barista_to_db("barista", "George", "Michael")
        get_as_employee(admin, "/admin-employee-orders?username=barista")
      end

      it "displays the correct headline with zero order count" do
        expect(last_response.body).to include("George Michael - Orders Fulfilled (0)")
      end

      it "displays the no orders message" do
        expect(last_response.body).to include("The barista has not fulfilled any orders yet.")
      end

      it "does not display the orders table" do
        expect(last_response.body).not_to include('<table class="admin_table">')
      end
    end

    context "when viewing a manager's orders page" do
      before do
        admin = add_test_admin_to_db
        add_test_manager_to_db("manager", "Michael", "Carrick")
        get_as_employee(admin, "/admin-employee-orders?username=manager")
      end

      it "displays the managers do not fulfil orders message" do
        expect(last_response.body).to include("Managers do not fulfil orders.")
      end

      it "does not display the barista no orders message" do
        expect(last_response.body).not_to include("The barista has not fulfilled any orders yet.")
      end

      it "does not display the orders table" do
        expect(last_response.body).not_to include('<table class="admin_table">')
      end
    end
  end

  describe "POST /admin-access-employee-account" do
    context "when the employee is a barista" do
      it "redirects to the barista main page" do
        admin = add_test_admin_to_db
        add_test_barista_to_db("barista")
        post_as_employee(admin, "/admin-access-employee-account", { "username" => "barista" })

        expect(last_response).to be_redirect
        expect(last_response.location).to end_with("/barista/main")
      end
    end

    context "when the employee is a manager" do
      it "redirects to the manager dashboard" do
        admin = add_test_admin_to_db
        add_test_manager_to_db("manager")
        post_as_employee(admin, "/admin-access-employee-account", { "username" => "manager" })

        expect(last_response).to be_redirect
        expect(last_response.location).to end_with("/manager/dashboard")
      end
    end

    context "when the employee's role is neither manager nor barista" do
      it "redirects to the admin main page" do
        admin = add_test_admin_to_db
        deleted_employee = add_deleted_employee_to_db
        post_as_employee(admin, "/admin-access-employee-account", {
          "username" => deleted_employee.username
        })

        expect(last_response).to be_redirect
        expect(last_response.location).to end_with("/admin-main")
      end
    end

    context "when the admin is viewing an employee account" do
      before do
        @admin = add_test_admin_to_db
        add_test_barista_to_db("barista")
      end

      it "displays the viewed employee's username" do
        get "/barista/main", {}, { "rack.session" =>
                                     { username: @admin.username, role: 'Admin', view_employee: 'barista' }
        }
        expect(last_response.body).to include("barista")
      end

      it "does not allow non-GET requests" do
        post "/barista/add-stamps", {}, { "rack.session" =>
                                            { username: @admin.username, role: 'Admin', view_employee: 'barista' }
        }
        expect(last_response.status).to eq(403)
        expect(last_response.body).to include("You cannot perform actions while viewing an employee account.")
      end

      it "allows non-GET requests to paths that are allowed" do
        post "/barista/main", {}, { "rack.session" =>
                                      { username: @admin.username, role: 'Admin', view_employee: 'barista' }
        }
        expect(last_response.status).not_to eq(403)
      end
    end

    context "when the admin is not viewing an employee account" do
      it "allows non-GET requests" do
        admin = add_test_admin_to_db
        add_test_barista_to_db("barista")
        post "/admin-employee-reset-password",
             { "username" => "barista", "password" => "", "conf_password" => "" },
             { "rack.session" => { username: admin.username, role: 'Admin', view_employee: nil } }

        expect(last_response.status).not_to eq(403)
      end
    end
  end

  describe "GET /admin-stop-viewing" do
    context "while viewing an employee account" do
      it "redirects to the employee's page" do
        admin = add_test_admin_to_db
        add_test_barista_to_db("barista")
        get "/admin-stop-viewing", {}, { "rack.session" =>
                                           { username: admin.username, role: 'Admin', view_employee: 'barista' }
        }

        expect(last_response).to be_redirect
        expect(last_response.location).to end_with("/admin-employee?username=barista")
      end
    end

    context "while not viewing an employee account" do
      it "redirects to the admin main page" do
        add_test_admin_to_db("admin")
        get "/admin-stop-viewing", {}, { "rack.session" =>
                                           { username: 'admin', role: 'Admin' }
        }

        expect(last_response).to be_redirect
        expect(last_response.location).to end_with("/admin-main")
      end
    end
  end
end
