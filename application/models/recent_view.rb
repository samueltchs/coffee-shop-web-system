class RecentView < Sequel::Model
  # returns a customer's 7 most recent items viewed
  def self.get_customer_recent_views(loyalty_number)
    RecentView.where(loyalty_number: loyalty_number).reverse_order(:time_viewed).limit(7)
  end

  def self.log_view(loyalty_number, product_id)
    view = RecentView.new
    view.loyalty_number = loyalty_number
    view.item_id = product_id
    view.time_viewed = Time.now.utc.to_s
    view.name = Product.get_product_by_id(product_id).name
    view.save_changes
  end
end
