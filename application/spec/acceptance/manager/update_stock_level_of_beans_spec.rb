RSpec.describe "Update bean stock level" do
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

    context "Updating a Bean Product's stock" do
      it "then shows the updated stock number on the Products - Beans page" do
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
        #original stock level is 25
        fill_in "Stock Level", with: "25"
        select "Medium", from: "Roast Level"
        select "Arabic", from: "Origin"
        click_on "Save"

        #check the new bean is in the Products - Beans page
        expect(page).to have_content "25"

        #Goes into the bean's details page
        click_link "details"
        #Goes into the update beans form
        click_link "Edit"

        fill_in "Stock Level", with: "299"
        click_on "Save"

        #check the updated bean is in the Products - Beans page
        expect(page).not_to have_content "25"
        expect(page).to have_content "299"
      end
    end

  end
end