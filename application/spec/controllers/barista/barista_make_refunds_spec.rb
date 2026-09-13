require_relative "../../spec_helper"

RSpec.describe "Barista make refunds controller" do
  before do
    @barista = add_test_barista_to_db
    login_as_employee(@barista)
    @customer = add_test_customer_to_db
  end

  describe "GET /barista/make-refunds" do
    it "returns 200" do
      get_as_employee(@barista, "/barista/make-refunds")
      expect(last_response.status).to eq(200)
    end
  end

  describe "POST /barista/make-refunds" do
    before do
      country  = add_test_country_to_db
      roast    = add_test_roast_level_to_db
      @product = add_test_product_to_db("Coffee", "Latte", nil, 1, country.id, roast.id)
      @size    = add_test_size_to_db
      @milk    = add_test_milk_option_to_db
      add_test_product_variant_to_db(@product.product_id, @size.id, @milk.id)
      @order   = add_test_order_to_db(@customer.loyalty_number)
      add_test_item_in_order_to_db(@product.product_id, @order.order_unique_id, 3.7, 1, @size.id, @milk.id)
    end

    it "renders the form when no submit button is pressed" do
      post_as_employee(@barista, "/barista/make-refunds", {
        entered_loyalty_number: @customer.loyalty_number,
        loyalty_number: @customer.loyalty_number
      })
      expect(last_response.status).to eq(200)
    end

    it "redirects with alert=invalid_customer when the loyalty number matches no customer" do
      post_as_employee(@barista, "/barista/make-refunds", {
        entered_loyalty_number: 9999,
        loyalty_number: "",
        submit_button: "submit",
        refund_reason: "Bad item",
        type: "Order",
        order_id: @order.order_unique_id
      })
      expect(last_response).to be_redirect
      expect(last_response.location).to include("alert=invalid_customer")
    end

    it "redirects with alert=reason when the refund reason is blank" do
      post_as_employee(@barista, "/barista/make-refunds", {
        entered_loyalty_number: @customer.loyalty_number,
        loyalty_number: @customer.loyalty_number,
        submit_button: "submit",
        refund_reason: "",
        type: "Order",
        order_id: @order.order_unique_id
      })
      expect(last_response).to be_redirect
      expect(last_response.location).to include("alert=reason")
    end

    it "redirects with alert=invalid_order when the order does not exist" do
      post_as_employee(@barista, "/barista/make-refunds", {
        entered_loyalty_number: @customer.loyalty_number,
        loyalty_number: @customer.loyalty_number,
        submit_button: "submit",
        refund_reason: "Damaged item",
        type: "Order",
        order_id: -1
      })
      expect(last_response).to be_redirect
      expect(last_response.location).to include("alert=invalid_order")
    end

    it "refunds the order and redirects to success when type is Order" do
      post_as_employee(@barista, "/barista/make-refunds", {
        entered_loyalty_number: @customer.loyalty_number,
        loyalty_number: @customer.loyalty_number,
        submit_button: "submit",
        refund_reason: "Wrong order",
        type: "Order",
        order_id: @order.order_unique_id
      })
      expect(Order.get_order(@order.order_unique_id).status).to eq("Refunded")
      expect(last_response).to be_redirect
      expect(last_response.location).to include("/barista/main?alert=refund_success")
    end

    it "redirects with alert=type when the refund type is not recognised" do
      post_as_employee(@barista, "/barista/make-refunds", {
        entered_loyalty_number: @customer.loyalty_number,
        loyalty_number: @customer.loyalty_number,
        submit_button: "submit",
        refund_reason: "Something",
        type: "Unknown"
      })
      expect(last_response).to be_redirect
      expect(last_response.location).to include("alert=type")
    end

    context "when refunding an item" do
      before do
        @item = add_test_item_in_order_to_db(@product.product_id, @order.order_unique_id, 3.7, 1, @size.id, @milk.id)
      end

      it "redirects with alert=invalid_item when the item does not exist" do
        post_as_employee(@barista, "/barista/make-refunds", {
          entered_loyalty_number: @customer.loyalty_number,
          loyalty_number: @customer.loyalty_number,
          submit_button: "submit",
          refund_reason: "Damaged item",
          type: "Item",
          item_id: -1
        })
        expect(last_response).to be_redirect
        expect(last_response.location).to include("alert=invalid_item")
      end

      it "refunds the item and redirects to success when type is Item" do
        post_as_employee(@barista, "/barista/make-refunds", {
          entered_loyalty_number: @customer.loyalty_number,
          loyalty_number: @customer.loyalty_number,
          submit_button: "submit",
          refund_reason: "Broken",
          type: "Item",
          item_id: @item.item_in_order_id
        })
        expect(last_response).to be_redirect
        expect(last_response.location).to include("/barista/main?alert=refund_success")
      end
    end
  end
end
