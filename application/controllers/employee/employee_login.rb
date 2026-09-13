get "/employee-login-page" do
    if session[:username]
        case session[:role]
        when "Barista"
            redirect "/barista/main"
        when "Admin"
            redirect "/admin-main"
        when "Manager"
            redirect "/manager/dashboard"
        end
    elsif session["logged_in"]
      redirect "/customer/dashboard"
    else
        erb :employee_login
    end
end

post "/employee-login-page" do
    user = params.fetch("username", nil)
    pass = params.fetch("password", nil)
    @error = nil
    user_validation = Employee.authenticate(user, pass)
    if(user_validation.nil?)
        @error = "Username and password combination does not match"
        erb :employee_login
    else
        session[:username] = user
        session[:role] = user_validation.role
        case session[:role]
        when "Barista"
            redirect "/barista/main"
        when "Admin"
            redirect "/admin-main"
        when "Manager"
            redirect "/manager/dashboard"
        end
    end
end

get "/employee-logout" do
    session.clear
    redirect "/employee-login-page"
end
