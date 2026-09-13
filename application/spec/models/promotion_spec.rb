RSpec.describe Promotion do
  describe ".create_ad_with_items" do
    before do
      customer = add_test_customer_to_db
      top_items = [[[1, 1, 1,], 5], [[2, 1, 1], 4], [[3, 1, 1,], 3]]
      Promotion.create_ad_with_items(customer.loyalty_number, top_items)
      @promotion = Promotion.first(loyalty_number: customer.loyalty_number)
    end

    it "creates a promotion record correctly" do
      expect(@promotion).not_to be_nil
      expect(@promotion.sent_at).not_to be_nil
    end

    it "creates a promotion item record for each item" do
      promotion_items = PromotionItem.where(promotion_id: @promotion.promotion_id).all
      expect(promotion_items.length).to eq(3)

      promotion_items.each do |item|
        expect(item.item_id).not_to be_nil
        expect(item.size_id).not_to be_nil
        expect(item.milk_id).not_to be_nil
      end
    end
  end
end
