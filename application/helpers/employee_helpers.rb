require 'time'
require 'securerandom'

# Provide various functions for employee-related operations 
module EmployeeHelpers
  def anonymize_employee(employee)
    DB.transaction do
      old_username = employee.username
      new_username = unique_deleted_employee_username

      updated_rows = DB[:employees].where(username: old_username).update(
        username: new_username,
        first_name: 'Deleted',
        last_name: SecureRandom.alphanumeric(6),
        email: nil,
        pass_hash: nil,
        role: 'Deleted',
        registered_time: nil,
        deleted_at: Time.now.utc
      )

      raise Sequel::Rollback if updated_rows.zero?

      Order.where(barista: old_username).update(barista: new_username)

      new_username
    end
  end

  def unique_deleted_employee_username
    loop do
      new_username = "deleted#{SecureRandom.random_number(999_999) + 1}"

      return new_username if Employee.first(username: new_username).nil?
    end
  end

  def view_employee
    if session[:view_employee]
      Employee[session[:view_employee]]
    else
      Employee[session[:username]]
    end
  end

  def viewing_employee?
    !session[:view_employee].nil?
  end

  def order_employees(non_deleted_employees, deleted_employees)
    admin_employee = nil
    other_employees = []

    non_deleted_employees.each do |employee|
      if employee.role == 'Admin'
        admin_employee = employee
      else
        other_employees << employee
      end
    end

    employees = []
    employees << admin_employee if admin_employee
    employees += other_employees
    employees += deleted_employees

    employees
  end
end
