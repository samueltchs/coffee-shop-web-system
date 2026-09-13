RSpec.describe "Update products" do
  context "given logged in as manager" do
    before do
      #login as manager
      manager = add_test_manager_to_db
      login_as_employee(manager)

      #add the default options related to products
      add_default_product_options_to_db
      
      #avoid test from saving an image
      allow_any_instance_of(Product).to receive(:save_image_path) do |product|
        product.image_path = "/images/product_images/test.png"
      end
    end

    context "Updating a Drink Product" do
      it "then shows the updated drink on the Products - Drinks page" do
        #add the initial drink to update
        visit "/manager/products/drinks"
        #Goes to the add drinks form
        click_link "Add Drinks"

        #add the drink
        fill_in "Product Name:", with:"Latte"
        fill_in "Description:", with:"Classic espresso with steamed milk."
        attach_file "Upload Image", File.expand_path("spec/test_images/latte.png")
        fill_in "Regular_price", with:"4.5"
        fill_in "Regular_cost", with:"1.2"
        check "Availability"
        check "Regular"
        check "Whole Milk"
        click_on "Save"

        #check the new drink variants are in the Products - Drinks page
        expect(page).to have_content "Regular Latte"

        #Goes into the drink's details page
        click_link "details"
        #Goes into the update drinks form
        click_link "Edit"

        fill_in "Product Name:", with:"Updated Latte"
        click_on "Save"

        #check the updated drink variant is in the Products - Drinks page
        expect(page).to have_content "Regular Updated Latte"
      end
    end

    context "Updating a Bean Product" do
      it "then shows the updated bean on the Products - Beans page" do
        #add the initial bean
        visit "/manager/products/beans"
        #Goes to the add beans form
        click_link "Add Beans"

        #add the bean
        fill_in "Product Name:", with:"Arabic Medium"
        fill_in "Description:", with:"Some Arabic Medium beans."
        attach_file "Upload Image", File.expand_path("spec/test_images/arabic_light.png")
        fill_in "Price £", with: "10.5"
        fill_in "Cost £", with: "7"
        check "Availability"
        fill_in "Stock Level", with: "25"
        select "Medium", from: "Roast Level"
        select "Arabic", from: "Origin"
        click_on "Save"

        #check the new bean is in the Products - Beans page
        expect(page).to have_content "Arabic Medium"

        #Goes into the bean's details page
        click_link "details"
        #Goes into the update beans form
        click_link "Edit"

        fill_in "Product Name:", with:"Updated Arabic Medium"
        click_on "Save"

        #check the updated bean is in the Products - Beans page
        expect(page).to have_content "Updated Arabic Medium"
      end
    end
  end
end