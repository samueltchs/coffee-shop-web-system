RSpec.describe "general customer controller" do
    describe "GET /about" do
        before do
            get "/about"
        end

        it "response is 200 (ok)" do
            expect(last_response).to be_ok
        end
    end

    describe "GET /customer-landing page" do
        context "when logged in" do
            before do
                get_as_customer_logged_in("/customer-landing-page")
            end

            it "redirects to customer dashboard" do
                expect(last_response).to be_redirect
                expect(last_response.location).to end_with("/customer/dashboard")
            end
        end

        context "when not logged in" do
            before do
                get_as_customer_not_logged_in("/customer-landing-page")
            end

            it "contains a link to login" do
                expect(last_response.body).to include('href="/login"')
            end

            it "contains a link to sign up" do
                expect(last_response.body).to include('href="/sign-up"')
            end
        end
    end

    describe "GET /customer-error" do
        before do
            get "/customer-error"
        end

        it "response is 200 (ok)" do
            expect(last_response).to be_ok
        end

        it "page contains navbar" do
            expect(last_response.body).to include("nav")
        end

        it "page contains footer" do
            expect(last_response.body).to include("footer")
        end
    end

    describe "GET /faq" do
        before do
            get "/faq"
        end

        it "response is 200 (ok)" do
            expect(last_response).to be_ok
        end

        it "has link to refund form" do
            expect(last_response.body).to include('href="/customer/refund"')
        end

        it "has link to complaints form" do
            expect(last_response.body).to include('href="/customer/complaints"')
        end

        it "has link to customer account settings" do
            expect(last_response.body).to include('href="/customer/customer-account-settings')
        end
    end
end