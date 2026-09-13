get "/about" do
    erb :customer_about
end

get "/customer-landing-page" do
    if logged_in?
        redirect "/customer/dashboard"
    else
        erb :customer_landing_page
    end
end

get "/customer-error" do
    erb :customer_misc_error
end

get "/faq" do
  @title = "Frequently Asked Questions"
  erb :faq
end