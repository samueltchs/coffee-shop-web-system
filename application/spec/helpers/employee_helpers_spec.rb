RSpec.describe EmployeeHelpers do
  include described_class

  describe "#anonymize_employee" do
    before do
      @employee = add_test_barista_to_db
    end

    context "when the employee is successfully anonymized" do
      it "changes the employee's username" do
        new_username = anonymize_employee(@employee)
        expect(new_username).not_to eq(@employee.username)
        expect(new_username).not_to be_nil
      end

      it "anonymizes all columns of the employees table" do
        anonymize_employee(@employee)

        deleted_employee = Employee.first(role: 'Deleted')
        expect(deleted_employee).not_to be_nil
        expect(deleted_employee.first_name).to eq("Deleted")
        expect(deleted_employee.last_name).not_to eq(@employee.last_name)
        expect(deleted_employee.email).to be_nil
        expect(deleted_employee.pass_hash).to be_nil
        expect(deleted_employee.registered_time).to be_nil
        expect(deleted_employee.deleted_at).not_to be_nil
      end

      it "updates the employee's orders to match the new username" do
        old_username = @employee.username
        add_test_order_to_db(1, Time.now.utc, 7.3, 7.7, 1, "ABC12345", old_username)
        new_username = anonymize_employee(@employee)

        expect(Order.where(barista: old_username).count).to eq(0)
        expect(Order.where(barista: new_username).count).to eq(1)
      end
    end
  end

  describe "#unique_deleted_employee_username" do
    it "returns a string" do
      expect(unique_deleted_employee_username).to be_instance_of(String)
    end

    it "returns a valid username" do
      new_username = unique_deleted_employee_username
      expect(new_username).to start_with("deleted")
      number = new_username[7..].to_i
      expect(number).to be_between(1, 999_999).inclusive
    end

    it "returns a unique username" do
      expect(Employee.first(username: unique_deleted_employee_username)).to be_nil
    end
  end

  describe "#order_employees" do
    context "when an employee of each possible role exists" do
      it "returns an array of the employees in correct order" do
        admin = add_test_admin_to_db
        barista = add_test_barista_to_db
        manager = add_test_manager_to_db
        deleted_employee = add_deleted_employee_to_db

        non_deleted_employees = [barista, admin, manager]
        deleted_employees = [deleted_employee]

        result = order_employees(non_deleted_employees, deleted_employees)
        expect(result).to eq([admin, barista, manager, deleted_employee])
      end
    end

    context "when no admin is found" do
      it "does not include an admin entry" do
        barista = add_test_barista_to_db
        manager = add_test_manager_to_db
        expect(order_employees([barista, manager], [])).to eq([barista, manager])
      end
    end

    context "when no employees exist" do
      it "returns an empty array" do
        expect(order_employees([], [])).to eq([])
      end
    end
  end
end
