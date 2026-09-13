RSpec.describe ProductVariant do
  describe ".get_price" do
    it "returns the price for a product variant key" do
      add_test_size_to_db
      add_test_milk_option_to_db
      add_test_country_to_db
      add_test_roast_level_to_db
      add_test_product_to_db
      add_test_product_variant_to_db
      
      expect(ProductVariant.get_price(1, 1, 1)).to eq(3.7)
    end

    it "returns a default message if no product variant record is found with the key" do
      expect(ProductVariant.get_price(1, 1, 1)).to eq("N/A")
    end
  end
end
