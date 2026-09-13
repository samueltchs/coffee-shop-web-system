class Favourite < Sequel::Model
  def self.get_customer_favourites(loyalty_number)
    Favourite.where(loyalty_number: loyalty_number)
  end

  def self.get_favourite_entry(loyalty_number, item_id)
    Favourite.first(loyalty_number: loyalty_number, item_id: item_id)
  end

  def self.add_new_favourite(loyalty_number, item_id)
    if Favourite.get_favourite_entry(loyalty_number, item_id).nil? && Product.product_exists?(item_id)
      # doesn't already exist in favourites, and is a real item - add it
      entry = Favourite.new
      entry.loyalty_number = loyalty_number
      entry.item_id = item_id
      entry.name = Product.get_product_by_id(item_id).name
      entry.time_favourited = Time.now.utc.to_s
      entry.save_changes
    end
  end

  def self.remove_favourite(loyalty_number, item_id)
    entry = Favourite.get_favourite_entry(loyalty_number, item_id)
    entry.delete
  end

  def self.get_all_favourite_items_by_customer(loyalty_number)
    entries = Favourite.where(loyalty_number: loyalty_number)
    items = []
    entries.each do |entry|
      items.append(Product.get_product_by_id(entry.item_id))
    end
    return items
  end

  def self.favourited?(loyalty_number, item_id)
    return !(Favourite.get_favourite_entry(loyalty_number, item_id).nil?)
  end
end
