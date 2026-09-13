class EligiblePurchaseType < Sequel::Model
    def self.get_eligible_purchase_type(id)
        case EligiblePurchaseType.first(id: id).type
        when "Beans Only"
            "beans"
        when "Drinks Only"
            "drinks"
        when "Both"
            "both"
        else    # should never happen
            nil
        end
    end
end