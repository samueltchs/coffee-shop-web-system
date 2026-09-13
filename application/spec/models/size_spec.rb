RSpec.describe Size do
  describe ".get_size" do
    it "returns the size name for a valid size id" do
      add_test_size_to_db("Small")
      
      expect(Size.get_size(1)).to eq("Small")
    end

    it "returns an empty string if size id is nil" do
      expect(Size.get_size(nil)).to eq("")
    end

    it "returns an empty string if no size record is found with the size id" do
      expect(Size.get_size(1)).to eq("")
    end
  end

  describe ".get_id" do
    it "returns the size id for a valid size name" do
      add_test_size_to_db("Small")

      expect(Size.get_id("Small")).to eq(1)
    end

    it "returns -1 if size name does is not valid" do
      expect(Size.get_id("Small")).to eq(-1)
    end
  end

  describe ".get_all_size_names" do
    it "returns all size names in an array" do
      add_test_size_to_db("Small")
      add_test_size_to_db("Regular")
      add_test_size_to_db("Large")
      add_test_size_to_db("XLarge")

      expect(Size.get_all_size_names).to eq(["Small", "Regular", "Large", "XLarge"])
    end
    
    it "returns an empty array if there is no Size entry in the database" do
      expect(Size.get_all_size_names).to eq([])
    end

  end

end
