RSpec.describe Favourite do
  describe ".get_customer_favourites" do
    it "returns only a specific customer's favourites" do
      add_test_favourite_to_db(1)
      add_test_favourite_to_db(2)

      expect(Favourite.get_customer_favourites(1).count).to eq(1)
    end
  end
end
