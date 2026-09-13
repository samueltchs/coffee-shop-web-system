def address_string_validation(str)
    # maybe put in validation.rb?
    str_lower = str.downcase
    if str_lower == "" || str_lower == "not set" || str_lower == "n/a"
        return nil
    else
        return str
    end
end