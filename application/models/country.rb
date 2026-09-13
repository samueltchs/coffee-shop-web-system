class Country < Sequel::Model 
  include Validation
  extend Validation

  # get the name of the country with the given id, used for bean origin
  def self.get_country_name(country_id)
    origin = Country.first(id: country_id)

    return "N/A" unless origin

    origin.country
  end

  def self.new_origin(input)
    new_origin = new
    new_origin.country = input.strip.split.map(&:capitalize).join(" ")
    new_origin.save
  end

  def self.validate_new_origin(params)
    params[:new_origin] = params[:new_origin].to_s.strip
    return error = "Please input a origin" if params[:new_origin].empty?

    origin_exist = select_map(:country).include?(params[:new_origin])
    return error = "This origin already exists" if origin_exist

    error = "Maximum 40 characters" unless str_max_length?(params[:new_origin], 40)
  end
end
