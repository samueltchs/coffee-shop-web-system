RSpec.describe RoastLevel do
  describe ".get_roast_level_name" do
    it "returns the roast level name for a valid roast level id" do
      add_test_roast_level_to_db("Light")

      expect(RoastLevel.get_roast_level_name(1)).to eq("Light")
    end

    it "returns N/A if no roast level record is found with the roast level id" do
      expect(RoastLevel.get_roast_level_name(1)).to eq("N/A")
    end

    it "returns N/A if roast level id is nil" do
      expect(RoastLevel.get_roast_level_name(nil)).to eq("N/A")
    end
  end
end
