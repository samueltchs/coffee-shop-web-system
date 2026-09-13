RSpec.describe Customer do
    describe ".email_exists?" do
        context "when email does not exist in db" do
            it "is false" do
                expect(Customer.email_exists?("nonexistentemail@tester.com")).to be(false)
            end
        end

        context "when email does exist in db" do
            before do
                cust = Customer.new
                cust.email = "existing@email.com"
                cust.save_changes
            end

            it "is true" do
                expect(Customer.email_exists?("existing@email.com")).to be(true)
            end
        end
    end

    describe ".get_customer_by_email" do
        context "email doesn't exist" do
            it "returns nil" do
                expect(Customer.get_customer_by_email("nonexistent@email.com")).to be_nil
            end
        end

        context "email exists" do
            before do
                cust = Customer.new
                cust.email = "existing@email.com"
                cust.save_changes
            end

            it "returns correct customer" do
                cust = Customer.get_customer_by_email("existing@email.com")
                expect(cust.email).to eq("existing@email.com")
            end
        end
    end

    describe ".login" do
        context "account exists" do
            before do
                cust = Customer.new
                cust.email = "existing@email.com"
                cust.password = "validPassword1!"
                cust.save_changes
            end

            context "correct password" do
                it "logs in correctly - returns Customer object" do
                    customer = Customer.login("existing@email.com", "validPassword1!")
                    expect(customer.email).to eq("existing@email.com")
                end
            end

            context "incorrect password" do
                it "doesn't log in - returns nil" do
                    customer = Customer.login("existing@email.com", "incorrectPass1!")
                    expect(customer).to be_nil
                end
            end
        end

        context "account does not exist" do
            it "doesn't log in - returns nil" do
                expect(Customer.login("nonexistent@email.com", "Password123!")).to be_nil
            end
        end
    end

    describe ".create_account" do
        context "account with email already exists" do
            before do
                cust = Customer.new()
                cust.email = "existing@email.com"
                cust.save_changes
            end

            it "raises ArgumentError" do
                expect { Customer.create_account("John", "Smith", 12345678910, "existing@email.com", "password1!") }.to raise_error(ArgumentError)
            end
        end

        context "account with email doesn't yet exist" do
            it "returns customer object" do
                cust = Customer.create_account("John", "Smith", 12345678910, "existing@email.com", "password1!")
                expect(cust).to be_a Customer
            end

            it "adds new customer to database" do
                Customer.create_account("John", "Smith", 12345678910, "existing@email.com", "password1!")
                expect(Customer.first(email: "existing@email.com")).not_to be_nil
            end
        end
    end
end