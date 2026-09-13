RSpec.describe Employee do
  describe "#name" do
    it "returns the employee's full name" do
      employee = add_test_employee_to_db("username", "Mike", "Jones")
      expect(employee.name).to eq("Mike Jones")
    end
  end

  describe "#load" do
    it "loads correctly the values from params" do
      employee = Employee.new

      params = { 
        "username" => "user",
        "first_name" => "Garry",
        "last_name" => "Evans",
        "email" => "garryevans@yahoo.com",
        "role" => "Barista",
        "password" => "validPass7!",
        "conf_password" => "validPass7!" 
      }

      employee.load(params)

      expect(employee.username).to eq("user")
      expect(employee.first_name).to eq("Garry")
      expect(employee.last_name).to eq("Evans")
      expect(employee.email).to eq("garryevans@yahoo.com")
      expect(employee.role).to eq("Barista")
      expect(employee.pass).to eq("validPass7!")
      expect(employee.conf_pass).to eq("validPass7!")
    end

    it "does not set the password if the password param is empty" do
      employee = Employee.new

      params = {
        "username" => "user",
        "first_name" => "Garry",
        "last_name" => "Evans",
        "email" => "garryevans@yahoo.com",
        "role" => "Barista",
        "password" => "",
        "conf_password" => "validPass7!"
      }

      employee.load(params)

      expect(employee.pass_hash).to be_nil
    end
  end

  describe "#validate" do
    it "is invalid if username is empty" do
      employee = create_employee("")
      expect(employee.valid?).to be false
      expect(employee.errors["username"]).to include("cannot be empty.")
    end

    it "is invalid if first name is empty" do
      employee = create_employee("user", "")
      expect(employee.valid?).to be false
      expect(employee.errors["first_name"]).to include("cannot be empty.")
    end

    it "is invalid if last name is empty" do
      employee = create_employee("user", "Garry", "")
      expect(employee.valid?).to be false
      expect(employee.errors["last_name"]).to include("cannot be empty.")
    end

    it "is invalid if email is empty" do
      employee = create_employee("user", "Garry", "Evans", "")
      expect(employee.valid?).to be false
      expect(employee.errors["email"]).to include("cannot be empty.")
    end

    it "is invalid if role is empty" do
      employee = create_employee("user", "Garry", "Evans", "email@gmail.com", "")
      expect(employee.valid?).to be false
      expect(employee.errors["role"]).to include("cannot be empty.")
    end

    it "is invalid if role is not valid" do
      employee = create_employee("user", "Garry", "Evans", "mail@gmail.com", "admin")
      expect(employee.valid?).to be false
      expect(employee.errors["role"]).to include("is not valid.")
    end

    it "is invalid if username contains spaces" do
      employee = create_employee("user name")
      expect(employee.valid?).to be false
      expect(employee.errors["username"]).to include("cannot contain spaces.")
    end

    it "is invalid if username already exists" do
      add_test_employee_to_db("username", "Garry", "Barry", "email@gmail.com", "Barista")
      employee = create_employee("username", "Larry", "Parry", "email@yahoo.com", "Manager", "validPass1!", "validPass1!")
      expect(employee.valid?).to be false
      expect(employee.errors["username"]).to include("already exists.")
    end

    it "is invalid if first name does not start with a capital letter" do
      employee = create_employee("user", "garry", "Evans")
      expect(employee.valid?).to be false
      expect(employee.errors["first_name"]).to include("must start with a capital letter.")
    end

    it "is invalid if first name contains invalid characters" do
      employee = create_employee("user", "Garry123", "Evans")
      expect(employee.valid?).to be false
      expect(employee.errors["first_name"]).to include("must contain only letters, hyphens, apostrophes and spaces.")
    end

    it "is invalid if last name does not start with a capital letter" do
      employee = create_employee("user", "Garry", "evans")
      expect(employee.valid?).to be false
      expect(employee.errors["last_name"]).to include("must start with a capital letter.")
    end

    it "is invalid if last name contains invalid characters" do
      employee = create_employee("user", "Garry", "Evans!")
      expect(employee.valid?).to be false
      expect(employee.errors["last_name"]).to include("must contain only letters, hyphens, apostrophes and spaces.")
    end

    it "is invalid if email already exists" do
      add_test_employee_to_db("username", "Garry", "Barry", "same@gmail.com", "Barista")
      employee = create_employee("nameuser", "Larry", "Parry", "same@gmail.com", "Manager", "validPass1!", "validPass1!")
      expect(employee.valid?).to be false
      expect(employee.errors["email"]).to include("already exists.")
    end

    it "is invalid if email is not a valid one" do
      employee = create_employee("username", "Garry", "Barry", "invalidgmail.com", "Manager", "validPass7!", "validPass7!")
      expect(employee.valid?).to be false
      expect(employee.errors["email"]).to include("is not valid.")
    end

    it "is invalid if a password is less than 8 characters long" do
      not_min_length = create_employee("username", "Garry", "Barry", "mail@gmail.com", "Manager", "12345A!", "12345A!")
      expect(not_min_length.valid?).to be false
      expect(not_min_length.errors["password"]).to include(
        "is not valid. Must be 8+ characters with at least 1 uppercase, 1 digit and 1 special character."
      )
    end

    it "is invalid if a password has no uppercase character" do
      no_uppercase = create_employee("username", "Garry", "Barry", "mail@gmail.com", "Manager", "!234567a", "!234567a")
      expect(no_uppercase.valid?).to be false
      expect(no_uppercase.errors["password"]).to include(
        "is not valid. Must be 8+ characters with at least 1 uppercase, 1 digit and 1 special character."
      )
    end

    it "is invalid if a password has no digit" do
      no_digit = create_employee("username", "Garry", "Barry", "mail@gmail.com", "Manager", "abcdeFG!", "abcdeFG!")
      expect(no_digit.valid?).to be false
      expect(no_digit.errors["password"]).to include(
        "is not valid. Must be 8+ characters with at least 1 uppercase, 1 digit and 1 special character."
      )
    end

    it "is invalid if a password has no special character" do
      no_special = create_employee("username", "Garry", "Barry", "mail@gmail.com", "Manager", "A234567a", "A234567a")
      expect(no_special.valid?).to be false
      expect(no_special.errors["password"]).to include(
        "is not valid. Must be 8+ characters with at least 1 uppercase, 1 digit and 1 special character."
      )
    end

    it "is invalid if the passwords do not match" do
      employee = create_employee("username", "Garry", "Barry", "mail@gmail.com", "Manager", "validPass7!", "validPass1!")
      expect(employee.valid?).to be false
      expect(employee.errors["conf_password"]).to include("do not match.")
    end
  
    it "is valid with no wrong data" do
      employee = create_employee("username", "Larry", "Fernandez", "mail@gmail.com", "Barista", "validPass1!", "validPass1!")
      expect(employee.valid?).to be true
      expect(employee.errors.empty?).to be true
    end
  end

  describe "#validate_username" do
    it "returns false if username is empty" do
      employee = create_employee("")
      expect(employee.validate_username).to be false
      expect(employee.errors["username"]).to include("cannot be empty.")
    end

    it "returns false if username contains spaces" do
      employee = create_employee("user name")
      expect(employee.validate_username).to be false
      expect(employee.errors["username"]).to include("cannot contain spaces.")
    end

    it "returns false if username is the same as current one" do
      employee = create_employee("cr7")
      employee.old_values = { username: "cr7" }
      expect(employee.validate_username).to be false
      expect(employee.errors["username"]).to include("must not be the same as the current one.")
    end

    it "returns false if username already exists" do
      add_test_employee_to_db("cr7")
      employee = create_employee("cr7")
      expect(employee.validate_username).to be false
      expect(employee.errors["username"]).to include("already exists.")
    end

    it "returns true if username is valid" do
      employee = add_test_employee_to_db("cristiano")
      expect(employee.validate_username).to be true
    end
  end

  describe "#validate_first_name" do
    it "returns false if first name is empty" do
      employee = create_employee("username", "")
      expect(employee.validate_first_name).to be false
      expect(employee.errors["first_name"]).to include("cannot be empty.")
    end

    it "returns false if first name is the same as current one" do
      employee = create_employee("cristiano", "Ronaldo")
      employee.old_values = { first_name: "Ronaldo" }
      expect(employee.validate_first_name).to be false
      expect(employee.errors["first_name"]).to include("must not be the same as the current one.")
    end
    
    it "returns false if first name does not start with a capital letter" do
      employee = create_employee("cristiano", "ronaldo")
      expect(employee.validate_first_name).to be false
      expect(employee.errors["first_name"]).to include("must start with a capital letter.")
    end

    it "returns false if first name contains invalid characters" do
      employee = create_employee("cristiano", "Ronaldo7")
      expect(employee.validate_first_name).to be false
      expect(employee.errors["first_name"]).to include("must contain only letters, hyphens, apostrophes and spaces.")
    end

    it "returns true if first name is valid" do
      employee = add_test_employee_to_db("cristiano", "Ronaldo")
      expect(employee.validate_first_name).to be true
    end
  end  

  describe "#validate_last_name" do
    it "returns false if last name is empty" do
      employee = create_employee("username", "Name", "")
      expect(employee.validate_last_name).to be false
      expect(employee.errors["last_name"]).to include("cannot be empty.")
    end

    it "returns false if last name is the same as current one" do
      employee = create_employee("cristiano", "Ronaldo", "Dos Santos Aveiro")
      employee.old_values = { last_name: "Dos Santos Aveiro" }
      expect(employee.validate_last_name).to be false
      expect(employee.errors["last_name"]).to include("must not be the same as the current one.")
    end

    it "returns false if last name does not start with a capital letter" do
      employee = create_employee("cristiano", "Ronaldo", "dos Santos Aveiro")
      expect(employee.validate_last_name).to be false
      expect(employee.errors["last_name"]).to include("must start with a capital letter.")
    end

    it "returns false if last name contains invalid characters" do
      employee = create_employee("cristiano", "Ronaldo", "Aveiro7")
      expect(employee.validate_last_name).to be false
      expect(employee.errors["last_name"]).to include("must contain only letters, hyphens, apostrophes and spaces.")
    end

    it "returns true if last name is valid" do
      employee = add_test_employee_to_db("cristiano", "Ronaldo", "Dos Santos Aveiro")
      expect(employee.validate_last_name).to be true
    end
  end  

  describe "#validate_email" do
    it "returns false if email is empty" do
      employee = create_employee("user", "als", "sox", "")
      expect(employee.validate_email).to be false
      expect(employee.errors["email"]).to include("cannot be empty.")
    end

    it "returns false if email is the same as current one" do
      employee = create_employee("user", "Papa", "Johns", "same@gmail.com")
      employee.old_values = { email: "same@gmail.com" }
      expect(employee.validate_email).to be false
      expect(employee.errors["email"]).to include("must not be the same as the current one.")
    end

    it "returns false if email already exists" do
      add_test_employee_to_db("user", "Papa", "Johns", "existing@gmail.com")
      employee = create_employee("username", "mama", "johns", "existing@gmail.com")
      expect(employee.validate_email).to be false
      expect(employee.errors["email"]).to include("already exists.")
    end

    it "returns false if email is not a valid one" do
      employee = create_employee("user", "son", "johns", "invalid")
      expect(employee.validate_email).to be false
      expect(employee.errors["email"]).to include("is not valid.")
    end

    it "returns true if email is valid" do
      employee = add_test_employee_to_db("user", "Unc", "Johns", "valid@gmail.com")
      expect(employee.validate_email).to be true
    end
  end

  describe "#validate_password" do
    it "skips validation if submitting empty password in existing account" do
      employee = add_test_employee_to_db
      employee.pass = ""
      expect(employee.validate_password).to be true
    end

    it "returns false if password does not follow the strength requirements" do
      employee = create_employee("user", "Ole", "Ragn", "ole@mail.com", "Manager", "validpass7!", "validpass7!")
      expect(employee.validate_password).to be false
      expect(employee.errors["password"]).to include(
        "is not valid. Must be 8+ characters with at least 1 uppercase, 1 digit and 1 special character."
      )
    end

    it "returns false if the passwords do not match" do
      employee = create_employee("user", "Ole", "Ragn", "ole@gmail.com", "Manager", "validPass7!", "validPass71")
      expect(employee.validate_password).to be false
      expect(employee.errors["conf_password"]).to include("do not match.")
    end

    it "returns false if password is the same as current one" do
      employee = add_test_employee_to_db
      employee.pass = "validPass7!"
      employee.conf_pass = "validPass7!"
      expect(employee.validate_password).to be false
      expect(employee.errors["password"]).to include("must not be the same as the current one.")
    end

    it "returns true if password is valid and both passwords match" do
      employee = create_employee("user", "Ole", "Ragn", "ole@gmail.com", "Manager", "validPass7!", "validPass7!")
      expect(employee.validate_password).to be true
    end
  end

  describe "#password=" do
    it "hashes a password correctly and stores it" do
      employee = Employee.new
      employee.password = "validPass7!"
      expect(BCrypt::Password.new(employee.pass_hash)).to eq("validPass7!")
    end
  end

  describe "#authenticate" do
    it "returns true for correct password" do
      employee = add_test_employee_to_db
      expect(employee.authenticate("validPass7!")).to be true
    end

    it "returns false for incorrect password" do
      employee = add_test_employee_to_db
      expect(employee.authenticate("validPass1!")).to be false
    end
  end

  describe ".authenticate" do
    it "returns nil if no user with specific credentials exists" do
      expect(Employee.authenticate("nobody", "Password7!")).to be_nil
    end

    it "returns nil if the employee is deleted" do
      add_deleted_employee_to_db("deleted17")
      expect(Employee.authenticate("deleted17", "validPass7!")).to be_nil
    end

    it "returns nil if incorrect password" do
      add_test_employee_to_db("user")
      expect(Employee.authenticate("user", "validPass1!")).to be_nil
    end

    it "returns nil if incorrect username" do
      add_test_employee_to_db("user")
      expect(Employee.authenticate("userr", "validPass7!")).to be_nil
    end

    it "returns employee if credentials are correct" do
      add_test_employee_to_db("user")
      result = Employee.authenticate("user", "validPass7!")
      expect(result).not_to be_nil
      expect(result.username).to eq("user")
    end
  end
end
