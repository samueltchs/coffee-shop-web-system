class BasketItem < Sequel::Model 

    # return an array of all the Product objects in a given customer's basket (identified by customer's loyalty_number)
    def self.get_all_items_by_customer(loyalty_number) 
        # get entries from basket table where quantity > 0
        entries = get_all_entries_by_customer(loyalty_number)
        
        # extract the products from these entries
        products = []
        entries.each do |entry|
            products.append(Product.get_product_by_id(entry.product_id))
        end
        return products
    end

    def self.basket_empty?(loyalty_number)
        get_all_entries_by_customer(loyalty_number).empty?
    end

    def self.get_all_entries_by_customer(loyalty_number)
        BasketItem.where{Sequel.&({loyalty_number: loyalty_number}, (quantity > 0))}
    end
    
    def self.get_all_items_quantities_by_customer(loyalty_number)
        entries = get_all_entries_by_customer(loyalty_number)
        items_quantities = []
        entries.each do |entry|
            product = Product.get_product_by_id(entry.product_id)
            items_quantities.append({"product" => product, "quantity" => entry.quantity})
        end
        return items_quantities
    end

    def self.get_basket_item(loyalty_number, product_id, milk_id, size_id)
        BasketItem.first(loyalty_number: loyalty_number, product_id: product_id, milk_id: milk_id, size_id: size_id)
    end

    def self.get_basket_item_by_id(basket_item_id)
        BasketItem.first(basket_item_id: basket_item_id)
    end

    def self.basket_contains_drinks(loyalty_number)
        contains_drink = false
        get_all_items_by_customer(loyalty_number).each do |item|
            if item.is_drink?
                contains_drink = true
            end
        end
        return contains_drink
    end

    def self.add_drink_to_basket(loyalty_number, product_id, milk_id, size_id)
        # check item is drinks and is available (so can be added to basket), and check that variant exists
        product = Product.first(product_id: product_id, availability: 1)
        product_variant = ProductVariant.find_variant(product_id, size_id, milk_id)
        cust = Customer.first(loyalty_number: loyalty_number)

        # if this item already exists in basket_items table, increase its quantity by one
        item = BasketItem.get_basket_item(loyalty_number, product_id, milk_id, size_id)
        if !item.nil?
            item.increase_quantity(1)
            return 0
        elsif !product.nil? && !cust.nil? && product.is_drink? && product.available? && !product_variant.nil? 
            # otherwise, add it to table, quantity 1
            entry = BasketItem.new
            entry.loyalty_number = loyalty_number
            entry.product_id = product_id
            entry.milk_id = milk_id
            entry.size_id = size_id
            entry.quantity = 1
            entry.save_changes
            return 0
        else
            return -1
        end
    end

    def self.add_bean_to_basket(loyalty_number, product_id)
        # check item is beans and is available (so can be added to basket)
        product = Product.first(product_id: product_id, availability: 1)
        cust = Customer.first(loyalty_number: loyalty_number)
        
        # if this item already exists in basket_items table, increase its quantity by one
        item = BasketItem.get_basket_item(loyalty_number, product_id, 1, 1)
        if !item.nil?
            item.increase_quantity(1)
            return 0
        elsif !product.nil? && !cust.nil? && product.is_bean? && product.available? # otherwise, add it to table, quantity 1
            entry = BasketItem.new
            entry.loyalty_number = loyalty_number
            entry.product_id = product_id
            entry.milk_id = 1
            entry.size_id = 1
            entry.quantity = 1
            entry.save_changes
            return 0
        else
            return -1
        end
    end

    def self.get_cheapest_drink_price(loyalty_number)
        if basket_contains_drinks(loyalty_number)
            cheapest_price = 5
            entries = get_all_entries_by_customer(loyalty_number)
            entries.each do |entry|
                # must be drink
                if Product.get_product_by_id(entry.product_id).is_drink?
                    product_variant = ProductVariant.find_variant(entry.product_id, entry.size_id, entry.milk_id)
                    price = product_variant.price
                    cheapest_price = price < cheapest_price ? price : cheapest_price
                end
            end
            return cheapest_price
        else
            return nil
        end
    end

    def self.get_total_basket_price(loyalty_number)
        entries = get_all_entries_by_customer(loyalty_number)
        total_price = 0
        entries.each do |entry|
            price_each = ProductVariant.find_variant(entry.product_id, entry.size_id, entry.milk_id).price
            quantity = entry.quantity
            total_price += (price_each * quantity).round(2)
        end
        
        total_price
    end

    def self.get_total_basket_cost(loyalty_number)
        entries = get_all_entries_by_customer(loyalty_number)
        total_cost = 0
        entries.each do |entry|
            cost_each = Product.get_product_by_id(entry.product_id).get_bean_cost
            quantity = entry.quantity
            total_cost += (cost_each * quantity).round(2)
        end
        
        total_cost
    end

    def self.get_total_basket_quantity(loyalty_number)
        entries = get_all_entries_by_customer(loyalty_number)
        total_quantity = 0
        entries.each do |entry|
            total_quantity += entry.quantity
        end
        
        total_quantity
    end

    def self.get_total_basket_price_with_free_coffee(loyalty_number)
        customer = Customer.get_customer(loyalty_number)
        original_price = get_total_basket_price(loyalty_number)
        if FreeCoffeeRedemption.customer_is_eligible(loyalty_number) && basket_contains_drinks(loyalty_number)
            cheapest_drink_price = get_cheapest_drink_price(loyalty_number)
            to_deduct = cheapest_drink_price <= 5 ? cheapest_drink_price : 5 # max deduct is 5
            return original_price - to_deduct
        else
            return original_price
        end        
    end

    def self.get_total_basket_price_with_discount(loyalty_number, discount_code)
        original_price = get_total_basket_price_with_free_coffee(loyalty_number)
        if DiscountRedemption.customer_has_code_unredeemed?(loyalty_number, discount_code)
            return original_price * DiscountCode.get_code_object(discount_code).get_multiplier()
        else
            return original_price
        end
    end

    def self.clear_basket(loyalty_number)
        entries = get_all_entries_by_customer(loyalty_number)
        entries.each do |entry|
            entry.quantity = 0
            entry.save_changes
        end        
    end

    def reduce_quantity(reduce_by)
        new_quantity = self.quantity - reduce_by
        self.quantity = new_quantity < 0 ? 0 : new_quantity
        self.save_changes
    end

    def increase_quantity(increase_by)
        self.quantity += increase_by
        self.save_changes
    end

    def remove()
        self.quantity = 0
        self.save_changes
    end
end