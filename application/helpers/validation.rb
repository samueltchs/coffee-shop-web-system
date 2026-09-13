# Provide various functions for validating data
module Validation
  def str_email_address?(str)
    return false if str.nil?

    str.match?(/\A\S+@\S+\Z/)
  end

  def str_digits?(str)
    return false if str.nil?

    str.match?(/^(\d)+$/)
  end

  def str_length?(str, len)
    return false if str.nil?

    str.length == len
  end

  def str_min_length?(str, min_len)
    return false if str.nil?

    str.length >= min_len
  end

  def str_max_length?(str, max_len)
    return false if str.nil?

    str.length <= max_len
  end

  def str_uk_telephone?(str)
    return false if str.nil?

    str = str.delete(" ").delete("-")
    str.start_with?(str, "0") && str_min_length?(str, 10) && str_max_length?(str, 11)
  end

  def str_yyyy_mm_dd_date?(str)
    return false if str.nil?

    y, m, d = str.split("-")

    return Date.valid_date?(y.to_i, m.to_i, d.to_i) if str_length?(y, 4)

    false
  end

  def valid_password?(password)
    return false if password.nil?

    min_length = str_min_length?(password, 8)
    return false unless min_length

    contains_number = false
    contains_uppercase = false
    contains_special = false

    password.each_char do |char|
      if str_digits?(char)
        contains_number = true
      elsif char.between?("A", "Z")
        contains_uppercase = true
      elsif !char.between?("A", "Z") && !char.between?("a", "z") && !str_digits?(char)
        contains_special = true
      end
    end

    contains_number && contains_uppercase && contains_special
  end

  def valid_reference_id?(reference_id)
    return false if reference_id.nil? || reference_id.length < 3

    min_length = str_min_length?(reference_id, 8)
    max_length = str_max_length?(reference_id, 12)

    return false if !min_length || !max_length

    first_three_capital_letters = true

    reference_id[0..2].each_char do |char|
      if !char.between?("A", "Z")
        first_three_capital_letters = false
      end
    end

    rest_digits = str_digits?(reference_id[3..])
  
    # valid reference IDs are of the form ABC1234567
    first_three_capital_letters && rest_digits
  end

  def valid_name_format?(name)
    return false if name.nil?

    contains_letter = false

    name.each_char do |char|
      return false unless char.between?("a", "z") || char.between?("A", "Z") || ["-", "'", " "].include?(char)

      contains_letter = true if char.between?("a", "z") || char.between?("A", "Z")
    end

    contains_letter
  end

  def valid_name_capitalization?(name)
    return false if name.nil?

    name[0].between?("A", "Z")
  end
end
