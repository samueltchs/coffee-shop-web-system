RSpec.describe "customer login controller" do
    describe "GET /" do
        context "when logged in" do 
            before do
                get_as_customer_logged_in("/")
            end

            it "redirects to /customer/dashboard" do
                expect(last_response).to be_redirect
                expect(last_response.location).to end_with("/customer/dashboard")
            end
        end

        context "when not logged in" do
            before do
                get_as_customer_not_logged_in("/")
            end
            
            it "redirects to /customer-landing-page" do
                expect(last_response).to be_redirect
                expect(last_response.location).to end_with("/customer-landing-page")
            end
        end
    end

    describe "GET /login" do
        context "when logged in" do
            before do
                get_as_customer_logged_in("/login")
            end

            it "redirects to /customer/dashboard" do
                expect(last_response).to be_redirect
                expect(last_response.location).to end_with("/customer/dashboard")
            end
        end
        
        context "when not logged in" do
            before do 
                get_as_customer_not_logged_in("/login")
            end

            it "response is 200 (ok)" do
                expect(last_response).to be_ok
            end

            # check for correct inputs
            it "has input for email" do
                expect(last_response.body).to include('name="email"')
            end

            it "has password-style input for password" do
                expect(last_response.body).to include('type="password" name="password"')
            end

            it "has submit button" do
                expect(last_response.body).to include('type="submit"')
            end

            # can navigate around
            it "has link to sign-up page" do
                expect(last_response.body).to include('href="/sign-up')
            end

            it "has link to forgot password page" do
                expect(last_response.body).to include('href="/forgot-password')
            end
        end
    end

    describe "GET /sign-up" do
        context "when logged in" do
            before do
                get_as_customer_logged_in("/sign-up")
            end

            it "redirects to /customer/dashboard" do
                expect(last_response).to be_redirect
                expect(last_response.location).to end_with("/customer/dashboard")
            end
        end

        context "when not logged in" do
            before do
                get_as_customer_not_logged_in("/sign-up")
            end

            it "response is 200 (ok)" do
                expect(last_response).to be_ok
            end

            # check page has correct inputs
            it "has input for first name" do
                expect(last_response.body).to include('name="first"')
            end

            it "has input for last name" do
                expect(last_response.body).to include('name="last"')
            end

            it "has input for email" do
                expect(last_response.body).to include('name="email"')
            end

            it "has input for phone number" do
                expect(last_response.body).to include('name="phone"')
            end

            it "has password-style input for password" do
                expect(last_response.body).to include('type="password" name="password"')
            end

            it "has password-style input for confirm password" do
                expect(last_response.body).to include('type="password" name="conf_password"')
            end

            it "has submit button" do
                expect(last_response.body).to include('type="submit"')
            end

            # can navigate around
            it "has link back to login page" do
                expect(last_response.body).to include('href="/login')
            end
        end 
    end

    describe "GET /logout" do
        context "when logged in" do
            before do
                get_as_customer_logged_in("/logout")
            end

            it "redirects to /customer-landing-page" do
                expect(last_response).to be_redirect
                expect(last_response.location).to end_with("/customer-landing-page")
            end
        end

        context "when logged out" do
            before do
                get_as_customer_not_logged_in("/logout")
            end

            it "redirects to /customer-landing-page" do
                expect(last_response).to be_redirect
                expect(last_response.location).to end_with("/customer-landing-page")
            end
        end
    end
end
