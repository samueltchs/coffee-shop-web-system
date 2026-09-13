class RoastLevel < Sequel::Model 
  # get the name of the roast level with the given id, used for beans 
  def self.get_roast_level_name(roast_level_id)
    roast = RoastLevel.first(id: roast_level_id)

    return "N/A" unless roast

    roast.roast_level
  end
end
