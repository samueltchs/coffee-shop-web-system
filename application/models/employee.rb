require "bcrypt"

class Employee < Sequel::Model
  include Validation
  extend Validation
  attr_accessor :pass, :conf_pass, :old_values

  def name
    "#{first_name} #{last_name}"
  end

  def self.get_baristas
    baristas = Employee.where(role: "Barista")
    return baristas if baristas
    return nil
  end

  def load(params)
    self.username = params.fetch("username", "").strip
    self.first_name = params.fetch("first_name", "").strip
    self.last_name = params.fetch("last_name", "").strip
    self.email = params.fetch("email", "").strip
    self.role = params.fetch("role", "").strip
    self.pass = params.fetch("password", "").strip
    self.conf_pass = params.fetch("conf_password", "").strip
    self.password = pass unless pass.empty?
  end

  def validate
    super
    errors.add("username", "cannot be empty.") if !username || username.empty?
    errors.add("first_name", "cannot be empty.") if !first_name || first_name.empty?
    errors.add("last_name", "cannot be empty.") if !last_name || last_name.empty?
    errors.add("email", "cannot be empty.") if !email || email.empty?
    errors.add("role", "cannot be empty.") if !role || role.empty?

    if role && !role.empty?
      errors.add("role", "is not valid.") if !["Barista", "Manager", "Admin", "Deleted"].include?(role)
    end

    if username && !username.empty?
      errors.add("username", "cannot contain spaces.") if username.include?(" ")
      existing_username = Employee[username]
      errors.add("username", "already exists.") if existing_username && existing_username != self
    end

    if first_name && !first_name.empty?
      errors.add("first_name", "must start with a capital letter.") unless valid_name_capitalization?(first_name)
      errors.add("first_name", "must contain only letters, hyphens, apostrophes and spaces.") unless valid_name_format?(first_name)
    end

    if last_name && !last_name.empty?
      errors.add("last_name", "must start with a capital letter.") unless valid_name_capitalization?(last_name)
      errors.add("last_name", "must contain only letters, hyphens, apostrophes and spaces.") unless valid_name_format?(last_name)
    end

    if email && !email.empty?
      existing_email = Employee.first(email: email)
      errors.add("email", "already exists.") if existing_email && existing_email != self
      errors.add("email", "is not valid.") unless str_email_address?(email)
    end
    
    if new? || !pass.to_s.empty?
      errors.add("password", "is not valid. Must be 8+ characters with at least 1 uppercase, 1 digit and 1 special character.") unless valid_password?(pass)
      errors.add("conf_password", "do not match.") if !pass.empty? && pass != conf_pass
    end
  end

  #validation methods for specific fields only
  def validate_username
    errors.clear

    errors.add("username", "cannot be empty.") if !username || username.empty?

    if username && !username.empty?
      errors.add("username", "cannot contain spaces.") if username.include?(" ")
      errors.add("username", "must not be the same as the current one.") if old_values && username == old_values[:username]
    end

    if username && !username.empty?
      existing_username = Employee[username]
      errors.add("username", "already exists.") if existing_username && existing_username != self
    end

    errors.empty?
  end

  def validate_first_name
    errors.clear

    errors.add("first_name", "cannot be empty.") if !first_name || first_name.empty?

    if first_name && !first_name.empty?
      errors.add("first_name", "must not be the same as the current one.") if old_values && first_name == old_values[:first_name]
      errors.add("first_name", "must start with a capital letter.") unless valid_name_capitalization?(first_name)
      errors.add("first_name", "must contain only letters, hyphens, apostrophes and spaces.") unless valid_name_format?(first_name)
    end

    errors.empty?
  end

  def validate_last_name
    errors.clear

    errors.add("last_name", "cannot be empty.") if !last_name || last_name.empty?

    if last_name && !last_name.empty?
      errors.add("last_name", "must not be the same as the current one.") if old_values && last_name == old_values[:last_name]
      errors.add("last_name", "must start with a capital letter.") unless valid_name_capitalization?(last_name)
      errors.add("last_name", "must contain only letters, hyphens, apostrophes and spaces.") unless valid_name_format?(last_name)
    end

    errors.empty?
  end

  def validate_email
    errors.clear

    errors.add("email", "cannot be empty.") if !email || email.empty?

    if email && !email.empty? && old_values && email == old_values[:email]
      errors.add("email", "must not be the same as the current one.")
    end

    if email && !email.empty?
      existing_email = Employee.first(email: email)
      errors.add("email", "already exists.") if existing_email && existing_email != self
      errors.add("email", "is not valid.") unless str_email_address?(email)
    end

    errors.empty?
  end

  def validate_password
    errors.clear

    return true if !new? && pass.to_s.empty?

    errors.add("password", "is not valid. Must be 8+ characters with at least 1 uppercase, 1 digit and 1 special character.") unless valid_password?(pass)
    errors.add("conf_password", "do not match.") if !pass.empty? && pass != conf_pass
    password_not_reused

    errors.empty?
  end

  def password_not_reused
    if !new? && !pass.to_s.empty?
        errors.add("password", "must not be the same as the current one.") if authenticate(pass)
    end
  end

  def password=(plaintext_password)
    self.pass_hash = BCrypt::Password.create(plaintext_password)
  end

  def authenticate(password_attempt)
    BCrypt::Password.new(pass_hash) == password_attempt
  end

  def self.authenticate(username, pass)
    employee = Employee.first(username: username)

    return nil if employee.nil?
    
    return nil if employee.role == "Deleted"

    return employee if employee.authenticate(pass)

    nil
  end
end
