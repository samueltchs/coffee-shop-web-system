class Promotion < Sequel::Model
  def self.create_ad_with_items(loyalty_number, top_items)
    DB.transaction do
      promotion = Promotion.new
      promotion.loyalty_number = loyalty_number
      promotion.sent_at = Time.now.utc
      promotion.save_changes

      top_items.each do |(item_id, size_id, milk_id), _count|
        promotion_item = PromotionItem.new
        promotion_item.promotion_id = promotion.promotion_id
        promotion_item.item_id = item_id
        promotion_item.size_id = size_id
        promotion_item.milk_id = milk_id
        promotion_item.save_changes
      end
    end
  end
end
