RSpec.describe RecentView do
  describe ".get_customer_recent_views" do
    it "returns a maximum of 7 recent views" do
      1.upto(8) do |i|
        add_test_recent_view_to_db(1, i + 1)
      end

      expect(RecentView.get_customer_recent_views(1).count).to eq(7)
    end

    it "returns the views in reverse order (most recent one first)" do
      add_test_recent_view_to_db(1, 1, Time.now.utc - SECONDS_IN_DAY * 2)
      add_test_recent_view_to_db(1, 2, Time.now.utc)
      add_test_recent_view_to_db(1, 3, Time.now.utc - SECONDS_IN_DAY * 7)

      views = RecentView.get_customer_recent_views(1).all

      expect(views[0].item_id).to eq(2)
      expect(views[1].item_id).to eq(1)
      expect(views[2].item_id).to eq(3)
    end

    it "returns only a specific customer's recent views" do
      add_test_recent_view_to_db(1, 1)
      add_test_recent_view_to_db(2, 2)
      expect(RecentView.get_customer_recent_views(1).count).to eq(1)
    end
  end
end
