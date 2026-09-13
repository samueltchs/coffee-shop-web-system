RSpec.describe MilkOption do
   describe ".get_milk_name" do
    it "returns the milk name for a valid milk id" do
      add_test_milk_option_to_db
      
      expect(MilkOption.get_milk_name(1)).to eq("Whole")
    end
    it "returns an empty string if milk id is nil" do
      expect(MilkOption.get_milk_name(nil)).to eq("")
    end

    it "returns an empty string if no milk record is found with the milk id" do
      expect(MilkOption.get_milk_name(1)).to eq("")
    end
  end

  describe ".get_id" do
    it "returns the milk id equivalent for valid a name" do
      add_test_milk_option_to_db
      expect(MilkOption.get_id("Whole")).to eq(1)
    end

    it "returns -1 for invalid names" do
      expect(MilkOption.get_id("Binga")).to eq(-1)
    end
  end

  describe ".get_all_milk_names" do
    it "returns all milk names" do
      MilkOption.create(milk: "No Milk")
      MilkOption.create(milk: "Whole Milk")
      MilkOption.create(milk: "Soy Milk")
      MilkOption.create(milk: "Oat Milk")

      expect(MilkOption.get_all_milk_names).to eq(["No Milk", "Whole Milk", "Soy Milk", "Oat Milk"])
    end
    it "returns an empty array" do
      expect(MilkOption.get_all_milk_names).to eq([])
    end
  end

end
