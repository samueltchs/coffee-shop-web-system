RSpec.describe "manager modify products controller" do
  describe "GET /manager/products/add-drinks" do
    context "when not logged in" do
      it "redirects to employee login page" do
        get "/manager/products/add-drinks"

        expect(last_response).to be_redirect
        expect(last_response.location).to include("/employee-login-page?error")
      end
    end

    context "when logged in but not as manager" do
      it "redirects to the appropriate page" do
        barista = add_test_barista_to_db
        get_as_employee(barista, "/manager/products/add-drinks")

        expect(last_response).to be_redirect
        expect(last_response.location).to end_with("/barista/main")
      end
    end

    context "when logged in as manager" do
      it "loads the page" do
        add_default_product_options_to_db

        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/products/add-drinks")

        expect(last_response).to be_ok
      end

      it "shows the add drinks form" do
        add_default_product_options_to_db

        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/products/add-drinks")
        
        expect(last_response.body).to include("Add Product")
        expect(last_response.body).to include("Add New Drinks")
        expect(last_response.body).to match(/id="product_form"\s+method="post"/)
        expect(last_response.body).to include('action="/manager/products/add-drinks"')
        expect(last_response.body).to include('enctype="multipart/form-data"')
      end

      it "shows the basic product fields" do
        add_default_product_options_to_db

        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/products/add-drinks")

        expect(last_response.body).to include("Product Name:")
        expect(last_response.body).to match(/type="text"\s+id="pname"\s+name="pname"/)

        expect(last_response.body).to include("Description:")
        expect(last_response.body).to match(/<textarea\s+name="description"\s+id="description"/)

        expect(last_response.body).to include("Upload Image")
        expect(last_response.body).to match(/type="file"\s+id="image"\s+name="image"\s+accept=".png,.jpg,.jpeg,.webp"/)

        expect(last_response.body).to include("Availability")
        expect(last_response.body).to match(/type="checkbox"\s+id="availability"\s+name="availability"\s+value="1"/)
      end

      it "shows price and cost fields for each drink size" do
        add_default_product_options_to_db

        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/products/add-drinks")

        expect(last_response.body).to include("Prices:")
        expect(last_response.body).to include('name="price[]"')

        expect(last_response.body).to include("Costs:")
        expect(last_response.body).to include('name="cost[]"')

        Size.offset(1).each do |size|
          expect(last_response.body).to include(">#{size.size} £<")
          expect(last_response.body).to include("id=\"#{size.size}_price\"")
          expect(last_response.body).to include("id=\"#{size.size}_cost\"")
        end
      end

      it "shows drink size checkboxes" do
        add_default_product_options_to_db

        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/products/add-drinks")

        expect(last_response.body).to include("Drink Sizes:")
        expect(last_response.body).to include('name="size[]"')

        Size.offset(1).each do |size|
          expect(last_response.body).to include(">#{size.size}<")
          expect(last_response.body).to match(/type="checkbox"\s+id="size#{size.id}"/)
          expect(last_response.body).to include("value=\"#{size.id}\"")
        end
      end

      it "shows milk option checkboxes" do
        add_default_product_options_to_db

        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/products/add-drinks")

        expect(last_response.body).to include("Milk Options:")
        expect(last_response.body).to include('name="milk[]"')

        MilkOption.offset(1).each do |milk|
          expect(last_response.body).to include(">#{milk.milk}<")
          expect(last_response.body).to match(/type="checkbox"\s+id="milk#{milk.id}"/)
          expect(last_response.body).to include("value=\"#{milk.id}\"")
        end
      end

      it "shows the form buttons" do
        add_default_product_options_to_db

        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/products/add-drinks")

        expect(last_response.body).to match(/<button\s+id="cancel"/)
        expect(last_response.body).to include("Cancel")
        expect(last_response.body).to include('type="submit" value="Save"')
      end
    end
  end

  describe "GET /manager/products/add-beans" do
    context "when not logged in" do
      it "redirects to employee login page" do
        get "/manager/products/add-beans"

        expect(last_response).to be_redirect
        expect(last_response.location).to include("/employee-login-page?error")
      end
    end

    context "when logged in but not as manager" do
      it "redirects to the appropriate page" do
        barista = add_test_barista_to_db
        get_as_employee(barista, "/manager/products/add-beans")

        expect(last_response).to be_redirect
        expect(last_response.location).to end_with("/barista/main")
      end
    end

    context "when logged in as manager" do
      it "loads the page" do
        add_default_product_options_to_db

        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/products/add-beans")

        expect(last_response).to be_ok
      end

      it "shows the add beans form" do
        add_default_product_options_to_db

        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/products/add-beans")

        expect(last_response.body).to include("Add Product")
        expect(last_response.body).to include("Add New Beans")
        expect(last_response.body).to match(/id="product_form"\s+method="post"/)
        expect(last_response.body).to include('action="/manager/products/add-beans"')
        expect(last_response.body).to include('enctype="multipart/form-data"')
      end

      it "shows the basic product fields" do
        add_default_product_options_to_db

        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/products/add-beans")

        expect(last_response.body).to include("Product Name:")
        expect(last_response.body).to match(/type="text"\s+id="pname"\s+name="pname"/)

        expect(last_response.body).to include("Description:")
        expect(last_response.body).to match(/<textarea\s+name="description"\s+id="description"/)

        expect(last_response.body).to include("Upload Image")
        expect(last_response.body).to match(/type="file"\s+id="image"\s+name="image"\s+accept=".png,.jpg,.jpeg,.webp"/)

        expect(last_response.body).to include("Availability")
        expect(last_response.body).to match(/type="checkbox"\s+id="availability"\s+name="availability"\s+value="1"/)
      end

      it "shows price and cost fields for adding beans" do
        add_default_product_options_to_db

        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/products/add-beans")

        expect(last_response.body).to include(">Price £<")
        expect(last_response.body).to match(/type="number"\s+id="price"\s+name="price"/)


        expect(last_response.body).to include(">Cost £<")
        expect(last_response.body).to match(/type="number"\s+id="cost"\s+name="cost"/)
      end

      it "shows stock level field" do
        add_default_product_options_to_db

        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/products/add-beans")

        expect(last_response.body).to include(">Stock Level<")
        expect(last_response.body).to match(/type="number"\s+id="stock"\s+name="stock"/)
      end

      it "shows dropdown menu for roast level" do
        add_default_product_options_to_db

        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/products/add-beans")

        expect(last_response.body).to include(">Roast Level<")
        expect(last_response.body).to include('<select id="roast" name="roast"')

        expect(last_response.body).to include('<option value="">Select roast level<')
        RoastLevel.offset(1).each do |roast|
          expect(last_response.body).to include("value=\"#{roast.id}\"")
          expect(last_response.body).to include(">#{roast.roast_level}<")
        end
      end

      it "shows dropdown menu for bean origins" do
        add_default_product_options_to_db

        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/products/add-beans")

        expect(last_response.body).to include(">Origin<")
        expect(last_response.body).to include('<select id="origin" name="origin"')

        expect(last_response.body).to include('<option value="">Select origin<')
        Country.offset(1).each do |origin|
          expect(last_response.body).to include("value=\"#{origin.id}\"")
          expect(last_response.body).to include(">#{origin.country}<")
        end
      end

      it "shows the button to call up the add origin form" do
        add_default_product_options_to_db

        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/products/add-beans")

        expect(last_response.body).to include('id="add_link" href="#add_origin"')
        expect(last_response.body).to include(">Add Origin<")
      end

      it "shows the add origin form" do
        add_default_product_options_to_db

        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/products/add-beans")

        expect(last_response.body).to include('id="add_origin" class="overlay"')
        expect(last_response.body).to include('id="origin_form" method="post"')
        expect(last_response.body).to include('action="/manager/products/new-origin"')

        expect(last_response.body).to include(">New Origin<")
        expect(last_response.body).to match(/type="text"\s+id="new_origin"\s+name="new_origin"/)

        expect(last_response.body).to include('id="submit" type="submit"')
        #button to close overlay
        expect(last_response.body).to include('id="close_link" href="#"')
        expect(last_response.body).to match(/>\s+close\s+</)
      end

      it "shows the form buttons" do
        add_default_product_options_to_db

        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/products/add-beans")

        expect(last_response.body).to match(/<button\s+id="cancel"/)
        expect(last_response.body).to include("Cancel")
        expect(last_response.body).to include('type="submit" value="Save"')
      end
    end
  end

  describe "GET /manager/products/update-drinks" do
    context "when not logged in" do
      it "redirects to employee login page" do
        get "/manager/products/update-drinks?id=1"

        expect(last_response).to be_redirect
        expect(last_response.location).to include("/employee-login-page?error")
      end
    end

    context "when logged in but not as manager" do
      it "redirects to the appropriate page" do
        barista = add_test_barista_to_db
        get_as_employee(barista, "/manager/products/update-drinks?id=1")

        expect(last_response).to be_redirect
        expect(last_response.location).to end_with("/barista/main")
      end
    end

    context "when logged in as manager" do
      it "loads the update drinks page" do
        add_default_product_options_to_db
        drink = add_test_product_to_db
        variant = add_test_product_variant_to_db(drink.product_id, 3, 3)

        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/products/update-drinks", { "id" => drink.product_id.to_s  })

        expect(last_response).to be_ok
      end

      it "shows the update drinks form" do
        add_default_product_options_to_db
        drink = add_test_product_to_db
        variant = add_test_product_variant_to_db(drink.product_id, 3, 3)

        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/products/update-drinks", { "id" => drink.product_id.to_s  })

        expect(last_response.body).to include("Update Product")
        expect(last_response.body).to include("Product ID: #{drink.product_id}")
        expect(last_response.body).to match(/id="product_form"\s+method="post"/)
        expect(last_response.body).to include('action="/manager/products/update-drinks"')
        #the hidden input storing product_id and to be submitted
        expect(last_response.body).to include("name=\"id\" value=\"#{drink.product_id}\"")
      end

      it "shows the existing drink details" do
        add_default_product_options_to_db
        drink = add_test_product_to_db
        variant = add_test_product_variant_to_db(drink.product_id, 3, 3)

        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/products/update-drinks", { "id" => drink.product_id.to_s  })

        expect(last_response.body).to include(drink.name)
        expect(last_response.body).to include(drink.description)
      end

      it "shows existing drink price and cost values" do
        add_default_product_options_to_db
        drink, variants = add_drink_with_multiple_sizes_to_db

        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/products/update-drinks", { "id" => drink.product_id.to_s  })

        variants.each do |variant|
          expect(last_response.body).to include("value=\"#{variant.price}\"")
          expect(last_response.body).to include("value=\"#{variant.cost}\"")
        end
      end

      it "checks the existing drink sizes and milk options" do
        add_default_product_options_to_db
        drink, variants = add_drink_with_multiple_sizes_to_db

        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/products/update-drinks", { "id" => drink.product_id.to_s  })

        variants.each do |variant|
          expect(last_response.body).to match(
            /id="size#{variant.size_id}"\s+name="size\[\]"\s+value="#{variant.size_id}"\s+checked/
          )
          expect(last_response.body).to match(
            /id="milk#{variant.milk_id}"\s+name="milk\[\]"\s+value="#{variant.milk_id}"\s+checked/
          )
        end
      end

      it "does not require image upload when updating" do
        add_default_product_options_to_db
        drink = add_test_product_to_db
        variant = add_test_product_variant_to_db(drink.product_id, 3, 3)

        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/products/update-drinks", { "id" => drink.product_id.to_s  })

        expect(last_response.body).to match(/name="image"\s+accept=".png,.jpg,.jpeg,.webp"\s+>/)
      end

      it "shows the form buttons" do
        add_default_product_options_to_db
        drink = add_test_product_to_db
        variant = add_test_product_variant_to_db(drink.product_id, 3, 3)

        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/products/update-drinks", { "id" => drink.product_id.to_s  })

        expect(last_response.body).to match(/<button\s+id="cancel"/)
        expect(last_response.body).to include("Cancel")
        expect(last_response.body).to include('type="submit" value="Save"')
      end
    end
  end

  describe "GET /manager/products/update-beans" do
    context "when not logged in" do
      it "redirects to employee login page" do
        get "/manager/products/update-beans?id=1"

        expect(last_response).to be_redirect
        expect(last_response.location).to include("/employee-login-page?error")
      end
    end

    context "when logged in but not as manager" do
      it "redirects to the appropriate page" do
        barista = add_test_barista_to_db
        get_as_employee(barista, "/manager/products/update-beans?id=1")

        expect(last_response).to be_redirect
        expect(last_response.location).to end_with("/barista/main")
      end
    end

    context "when logged in as manager" do
      it "loads the update beans page" do
        add_default_product_options_to_db
        bean, variant = add_test_bean_to_db

        manager = add_test_manager_to_db
        get_as_employee(
          manager, "/manager/products/update-beans", 
          { "id" => bean.product_id.to_s }
        )

        expect(last_response).to be_ok
      end

      it "shows the update beans form" do
        add_default_product_options_to_db
        bean, variant = add_test_bean_to_db

        manager = add_test_manager_to_db
        get_as_employee(
          manager, "/manager/products/update-beans",
          { "id" => bean.product_id.to_s }
        )

        expect(last_response.body).to include("Update Product")
        expect(last_response.body).to include("Product ID: #{bean.product_id}")
        expect(last_response.body).to match(/id="product_form"\s+method="post"/)
        expect(last_response.body).to include('action="/manager/products/update-beans"')
        #the hidden input storing product_id and to be submitted
        expect(last_response.body).to include("name=\"id\" value=\"#{bean.product_id}\"")
      end

      it "shows the existing bean details" do
        add_default_product_options_to_db
        bean, variant = add_test_bean_to_db

        manager = add_test_manager_to_db
        get_as_employee(
          manager, "/manager/products/update-beans",
          { "id" => bean.product_id.to_s  }
        )

        expect(last_response.body).to include(bean.name)
        expect(last_response.body).to include(bean.description)
      end

      it "shows existing bean price and cost" do
        add_default_product_options_to_db
        bean, variant = add_test_bean_to_db

        manager = add_test_manager_to_db
        get_as_employee(
          manager, "/manager/products/update-beans",
          { "id" => bean.product_id.to_s  }
        )

        expect(last_response.body).to include("value=\"#{variant.price}\"")
        expect(last_response.body).to include("value=\"#{variant.cost}\"")
      end

      it "shows existing stock level" do
        add_default_product_options_to_db
        bean, variant = add_test_bean_to_db

        manager = add_test_manager_to_db
        get_as_employee(
          manager, "/manager/products/update-beans",
          { "id" => bean.product_id.to_s  }
        )

        expect(last_response.body).to include("value=\"#{bean.stock_level}\"")
      end

      it "shows selected roast level" do
        add_default_product_options_to_db
        bean, variant = add_test_bean_to_db

        manager = add_test_manager_to_db
        get_as_employee(
          manager, "/manager/products/update-beans",
          { "id" => bean.product_id.to_s  }
        )

        expect(last_response.body).to match(/value="#{bean.roast_level}"\s+selected/)
      end

      it "shows selected bean origin" do
        add_default_product_options_to_db
        bean, variant = add_test_bean_to_db

        manager = add_test_manager_to_db
        get_as_employee(
          manager, "/manager/products/update-beans",
          { "id" => bean.product_id.to_s  }
        )

        expect(last_response.body).to match(/value="#{bean.origin}"\s+selected/)
      end

      it "does not require image upload when updating" do
        add_default_product_options_to_db
        bean, variant = add_test_bean_to_db

        manager = add_test_manager_to_db
        get_as_employee(
          manager, "/manager/products/update-beans",
          { "id" => bean.product_id.to_s  }
        )

        expect(last_response.body).to match(/name="image"\s+accept=".png,.jpg,.jpeg,.webp"\s+>/)
      end

      it "shows the button to call up the add origin form" do
        add_default_product_options_to_db
        bean, variant = add_test_bean_to_db

        manager = add_test_manager_to_db
        get_as_employee(
          manager, "/manager/products/update-beans",
          { "id" => bean.product_id.to_s  }
        )

        expect(last_response.body).to include('id="add_link" href="#add_origin"')
        expect(last_response.body).to include(">Add Origin<")
      end

      it "shows the add origin form" do
        add_default_product_options_to_db
        bean, variant = add_test_bean_to_db

        manager = add_test_manager_to_db
        get_as_employee(
          manager, "/manager/products/update-beans",
          { "id" => bean.product_id.to_s  }
        )

        expect(last_response.body).to include('id="add_origin" class="overlay"')
        expect(last_response.body).to include('id="origin_form" method="post"')
        expect(last_response.body).to include('action="/manager/products/new-origin"')

        expect(last_response.body).to include(">New Origin<")
        expect(last_response.body).to match(/type="text"\s+id="new_origin"\s+name="new_origin"/)

        expect(last_response.body).to include('id="submit" type="submit"')
        #button to close overlay
        expect(last_response.body).to include('id="close_link" href="#"')
        expect(last_response.body).to match(/>\s+close\s+</)
      end

      it "shows the form buttons" do
        add_default_product_options_to_db
        bean, variant = add_test_bean_to_db

        manager = add_test_manager_to_db
        get_as_employee(
          manager, "/manager/products/update-beans",
          { "id" => bean.product_id.to_s  }
        )

        expect(last_response.body).to match(/<button\s+id="cancel"/)
        expect(last_response.body).to include("Cancel")
        expect(last_response.body).to include('type="submit" value="Save"')
      end
    end
  end

  describe "POST /manager/products/add-drinks" do 
    context "when not logged in" do
      it "redirects to employee login page" do
        post "/manager/products/add-drinks"

        expect(last_response).to be_redirect
        expect(last_response.location).to include("/employee-login-page?error")
      end
    end

    context "when logged in but not as manager" do
      it "redirects to the appropriate page" do
        barista = add_test_barista_to_db
        post_as_employee(barista, "/manager/products/add-drinks")

        expect(last_response).to be_redirect
        expect(last_response.location).to end_with("/barista/main")
      end
    end

    context "when logged in as manager" do
      before do 
        add_default_product_options_to_db
        @manager = add_test_manager_to_db
        #avoid the test from creating an image in the product images folder
        #and create a fake image path for testing
        allow_any_instance_of(Product).to receive(:save_image_path) do |product|
          product.update(image_path: "/images/product_images/test.png")
        end
      end

      context "Inputs are valid" do
        it "creates a new drink in products database" do
          params = test_drink_params

          #check the change in number of entries in product database
          expect { 
            post_as_employee(@manager, "/manager/products/add-drinks", params)
          }.to change(Product, :count).by(1)
        end

        it "creates drink variants for selected sizes and milk options" do
          params = test_drink_params

          #3 sizes and 3 milk options selected
          num_of_variants = 3 * 3

          #check the change in number of entries in product_variants database
          expect { 
            post_as_employee(@manager, "/manager/products/add-drinks", params)
          }.to change(ProductVariant, :count).by(num_of_variants)
        end

        it "saves the correct product details in the database" do
          params = test_drink_params

          post_as_employee(@manager, "/manager/products/add-drinks", params)
          product = Product.last

          expect(product.name).to eq(params[:pname])
          expect(product.type).to eq(params[:type])
          expect(product.description).to eq(params[:description])
          expect(product.availability.to_s).to eq(params[:availability])
          expect(product.origin.to_s).to eq("1")
          expect(product.roast_level.to_s).to eq("1")
          expect(product.image_path).to eq("/images/product_images/test.png")
        end

        it "saves the correct variants details in the database" do
          params = test_drink_params
          post_as_employee(@manager, "/manager/products/add-drinks", params)
          
          product = Product.last
          variants = ProductVariant.where(product_id: product.product_id)

          saved_sizes = variants.distinct.select_map(:size_id)
          saved_milks = variants.distinct.select_map(:milk_id)
          saved_prices = variants.distinct.select_map(:price)
          saved_costs = variants.distinct.select_map(:cost)

          expect(saved_sizes.map(&:to_s)).to match_array(params[:size])
          expect(saved_milks.map(&:to_s)).to match_array(params[:milk])
          expect(saved_prices.map(&:to_s)).to match_array(params[:price])
          expect(saved_costs.map(&:to_s)).to match_array(params[:cost])
        end

        it "redirects to product - drinks page after successful add" do
          params = test_drink_params
          post_as_employee(@manager, "/manager/products/add-drinks", params)

          expect(last_response).to be_redirect
          expect(last_response.location).to include("/manager/products/drinks")
        end
      end

      context "Some inputs are invalid" do
        it "re-renders the form when inputs are invalid" do
          #when the product name is left empty
          params = test_drink_params(pname: "")
          post_as_employee(@manager, "/manager/products/add-drinks", params)

          expect(last_response).to be_ok
          expect(last_response.body).to include("Add New Drinks")
          expect(last_response.body).to match(
            /form\s+id="product_form"\s+method="post"\s+action="\/manager\/products\/add-drinks"/
          )
          expect(last_response.body).to include("error_msg")
        end

        it "does not save a new product or variant when inputs invalid" do
          params = test_drink_params(pname: "")

          product_count = Product.count
          variant_count = ProductVariant.count

          post_as_employee(@manager, "/manager/products/add-drinks", params)

          expect(Product.count).to eq(product_count)
          expect(ProductVariant.count).to eq(variant_count)
        end

        it "keeps the entered values when re-rendered" do
          params = test_drink_params(pname: "")
          post_as_employee(@manager, "/manager/products/add-drinks", params)

          expect(last_response.body).to include(params[:description])
          expect(last_response.body).to include("value=\"#{params[:price][0]}\"")
          expect(last_response.body).to include("value=\"#{params[:cost][0]}\"")
        end

        context "when any field is empty" do
          it "shows error message when name is empty" do
            params = test_drink_params(pname: "")
            post_as_employee(@manager, "/manager/products/add-drinks", params)

            expect(last_response.body).to include(
              'class="error_msg">Product Name cannot be empty<'
            )
          end

          it "shows error message when description is empty" do
            params = test_drink_params(description: "")
            post_as_employee(@manager, "/manager/products/add-drinks", params)

            expect(last_response.body).to include(
              'class="error_msg">Description cannot be empty<'
            )
          end

          it "shows error message when user did not upload a product image" do
            params = test_drink_params(image: "")
            post_as_employee(@manager, "/manager/products/add-drinks", params)

            expect(last_response.body).to include(
              'class="error_msg">Please upload an image<'
            )
          end

          it "shows error message when user did not input price for all selected sizes" do
            params = test_drink_params(price: ["2.3", "", "4.5"])
            post_as_employee(@manager, "/manager/products/add-drinks", params)

            expect(last_response.body).to include(
              'class="error_msg">Please fill in price for all selected sizes<'
            )
          end

          it "shows error message when user did not input cost for all selected sizes" do
            params = test_drink_params(cost: ["", "", ""])
            post_as_employee(@manager, "/manager/products/add-drinks", params)

            expect(last_response.body).to include(
              'class="error_msg">Please fill in cost for all selected sizes<'
            )
          end

          it "shows error message when user did not select any size" do
            params = test_drink_params(size: [])
            post_as_employee(@manager, "/manager/products/add-drinks", params)

            expect(last_response.body).to include(
              'class="error_msg">Please select at least one size<'
            )
          end

          it "shows error message when user did not select any milk option" do
            params = test_drink_params(milk: [])
            post_as_employee(@manager, "/manager/products/add-drinks", params)

            expect(last_response.body).to include(
              'class="error_msg">Please select at least one milk option<'
            )
          end
        end

        context "when any input is invalid" do
          it "shows error message for product name longer than 40 characters" do
            params = test_drink_params(
              pname: "Super super super super super longggggg product name"
            )
            post_as_employee(@manager, "/manager/products/add-drinks", params)

            expect(last_response.body).to include(
              'class="error_msg">Product Name cannot exceed 40 characters<'
            )
          end

          it "shows error message when description input exceed 500 characters" do
            params = test_drink_params(
              description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.
                Vivamus fermentum, justo at efficitur tincidunt, urna turpis suscipit 
                augue, vitae tristique nibh turpis eget lorem. Curabitur sed risus nec 
                nulla aliquet malesuada. Integer vitae turpis sed arcu pulvinar consequat. 
                Donec consequat, velit eget facilisis facilisis, lorem libero sollicitudin, 
                sed hendrerit velit lorem non mi. Suspendisse potenti. Aliquam erat volutpat. 
                Morbi non augue sed sapien cursus interdum. Praesent sit amet tincidunt ligula. 
                Integer suscipit magna nec turpis vulputate, nec viverra ligula pulvinar. 
                Duis eget ligula sed ipsum pellentesque porta. Sed nec lectus ac odio tincidunt 
                volutpat. Nam malesuada lorem sed nisl faucibus, vitae consequat augue convallis. 
                Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis 
                egestas massa."
            )
            post_as_employee(@manager, "/manager/products/add-drinks", params)

            expect(last_response.body).to include(
              'class="error_msg">Description cannot exceed 500 characters<'
            )
          end

          it "shows error message when wrong file type is uploaded for product image" do
            params = test_drink_params(
              image: Rack::Test::UploadedFile.new("spec/test_images/latte.pdf", "application/pdf")
            )
            post_as_employee(@manager, "/manager/products/add-drinks", params)

            expect(last_response.body).to include('class="error_msg">Invalid image type<')
          end

          it "shows error message when any price input is -ve or greater than 300" do
            params = test_drink_params(price: ["-1", "400", "-100"])
            post_as_employee(@manager, "/manager/products/add-drinks", params)

            expect(last_response.body).to include(
              'class="error_msg">Prices must be between 0 and 300<'
            )
          end

          it "shows error message when any cost input is -ve or greater than 300" do
            params = test_drink_params(cost: ["-1", "400", "-100"])
            post_as_employee(@manager, "/manager/products/add-drinks", params)

            expect(last_response.body).to include(
              'class="error_msg">Costs must be between 0 and 300<'
            )
          end

          it "shows error message when size input does not exist in sizes database" do
            params = test_drink_params(size: ["fake size", "-10"])
            post_as_employee(@manager, "/manager/products/add-drinks", params)

            expect(last_response.body).to include(
              'class="error_msg">Invalid size input<'
            )
          end

          it "shows error message when milk option input does not exist in milk_options database" do
            params = test_drink_params(milk: ["doesn't exist", "-10"])
            post_as_employee(@manager, "/manager/products/add-drinks", params)

            expect(last_response.body).to include(
              'class="error_msg">Invalid milk option input<'
            )
          end
        end
      end
    end
  end

  describe "POST /manager/products/add-beans" do
    context "when not logged in" do
      it "redirects to employee login page" do
        post "/manager/products/add-beans"

        expect(last_response).to be_redirect
        expect(last_response.location).to include("/employee-login-page?error")
      end
    end

    context "when logged in but not as manager" do
      it "redirects to the appropriate page" do
        barista = add_test_barista_to_db
        post_as_employee(barista, "/manager/products/add-beans")

        expect(last_response).to be_redirect
        expect(last_response.location).to end_with("/barista/main")
      end
    end

    context "when logged in as manager" do
      before do 
        add_default_product_options_to_db
        @manager = add_test_manager_to_db

        #avoid the test from creating an image in the product images folder
        #and create a fake image path for testing
        allow_any_instance_of(Product).to receive(:save_image_path) do |product|
          product.update(image_path: "/images/product_images/test.png")
        end
      end

      context "Inputs are valid" do
        it "creates a new bean in products database" do
          params = test_bean_params

          #check the change in number of entries in product database
          expect { 
            post_as_employee(@manager, "/manager/products/add-beans", params)
          }.to change(Product, :count).by(1)
        end

        it "creates bean variant in product_variants database" do
          params = test_bean_params

          #check the change in number of entries in product_variants database
          expect { 
            post_as_employee(@manager, "/manager/products/add-beans", params)
          }.to change(ProductVariant, :count).by(1)
        end

        it "saves the correct product details in the database" do
          params = test_bean_params

          post_as_employee(@manager, "/manager/products/add-beans", params)
          product = Product.last

          expect(product.name).to eq(params[:pname])
          expect(product.type).to eq(params[:type])
          expect(product.description).to eq(params[:description])
          expect(product.availability.to_s).to eq(params[:availability])
          expect(product.origin.to_s).to eq(params[:origin])
          expect(product.roast_level.to_s).to eq(params[:roast])
          expect(product.stock_level.to_s).to eq(params[:stock])
          expect(product.image_path).to eq("/images/product_images/test.png")
        end

        it "saves the correct variant details in the database" do
          params = test_bean_params

          post_as_employee(@manager, "/manager/products/add-beans", params)
          product = Product.last

          variant = ProductVariant.first(product_id: product.product_id)

          expect(variant.size_id.to_s).to eq("1")
          expect(variant.milk_id.to_s).to eq("1")
          expect(variant.price).to eq(params[:price].to_f)
          expect(variant.cost).to eq(params[:cost].to_f)
        end

        it "redirects to product - beans page after successful add" do
          params = test_bean_params
          post_as_employee(@manager, "/manager/products/add-beans", params)

          expect(last_response).to be_redirect
          expect(last_response.location).to include("/manager/products/beans")
        end
      end

      context "Some inputs are invalid" do
        it "re-renders the form when inputs are invalid" do
          #when the product name is left empty
          params = test_bean_params(pname: "")
          post_as_employee(@manager, "/manager/products/add-beans", params)

          expect(last_response).to be_ok
          expect(last_response.body).to include("Add New Beans")
          expect(last_response.body).to match(
            /form\s+id="product_form"\s+method="post"\s+action="\/manager\/products\/add-beans"/
          )
          expect(last_response.body).to include("error_msg")
        end

        it "does not save a new product or variant when inputs invalid" do
          params = test_bean_params(pname: "")

          product_count = Product.count
          variant_count = ProductVariant.count

          post_as_employee(@manager, "/manager/products/add-beans", params)

          expect(Product.count).to eq(product_count)
          expect(ProductVariant.count).to eq(variant_count)
        end

        it "keeps the entered values when re-rendered" do
          params = test_bean_params(pname: "")
          post_as_employee(@manager, "/manager/products/add-beans", params)

          expect(last_response.body).to include(params[:description])
          expect(last_response.body).to include("value=\"#{params[:price]}\"")
          expect(last_response.body).to include("value=\"#{params[:cost]}\"")
        end

        context "when any field is empty" do
          it "shows error message when name is empty" do
            params = test_bean_params(pname: "")
            post_as_employee(@manager, "/manager/products/add-beans", params)

            expect(last_response.body).to include(
              'class="error_msg">Product Name cannot be empty<'
            )
          end

          it "shows error message when description is empty" do
            params = test_bean_params(description: "")
            post_as_employee(@manager, "/manager/products/add-beans", params)

            expect(last_response.body).to include(
              'class="error_msg">Description cannot be empty<'
            )
          end

          it "shows error message when user did not upload a product image" do
            params = test_bean_params(image: "")
            post_as_employee(@manager, "/manager/products/add-beans", params)

            expect(last_response.body).to include(
              'class="error_msg">Please upload an image<'
            )
          end

          it "shows error message when user did not input price" do
            params = test_bean_params(price: "")
            post_as_employee(@manager, "/manager/products/add-beans", params)

            expect(last_response.body).to include(
              'class="error_msg">Price cannot be empty<'
            )
          end

          it "shows error message when user did not input cost" do
            params = test_bean_params(cost: "")
            post_as_employee(@manager, "/manager/products/add-beans", params)

            expect(last_response.body).to include(
              'class="error_msg">Cost cannot be empty<'
            )
          end

          it "shows error message when user did not input stock level" do
            params = test_bean_params(stock: "")
            post_as_employee(@manager, "/manager/products/add-beans", params)

            expect(last_response.body).to include(
              'class="error_msg">Stock level cannot be empty<'
            )
          end

          it "shows error message when user did not select roast level" do
            params = test_bean_params(roast: "")
            post_as_employee(@manager, "/manager/products/add-beans", params)

            expect(last_response.body).to include(
              'class="error_msg">Please select a roast level<'
            )
          end

          it "shows error message when user did not select origin" do
            params = test_bean_params(origin: "")
            post_as_employee(@manager, "/manager/products/add-beans", params)

            expect(last_response.body).to include(
              'class="error_msg">Please select an origin<'
            )
          end
        end

        context "when any input is invalid" do
          it "shows error message for product name longer than 40 characters" do
            params = test_bean_params(
              pname: "Super super super super super longggggg product name"
            )
            post_as_employee(@manager, "/manager/products/add-beans", params)

            expect(last_response.body).to include(
              'class="error_msg">Product Name cannot exceed 40 characters<'
            )
          end

          it "shows error message when description input exceed 500 characters" do
            params = test_bean_params(
              description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.
                Vivamus fermentum, justo at efficitur tincidunt, urna turpis suscipit 
                augue, vitae tristique nibh turpis eget lorem. Curabitur sed risus nec 
                nulla aliquet malesuada. Integer vitae turpis sed arcu pulvinar consequat. 
                Donec consequat, velit eget facilisis facilisis, lorem libero sollicitudin, 
                sed hendrerit velit lorem non mi. Suspendisse potenti. Aliquam erat volutpat. 
                Morbi non augue sed sapien cursus interdum. Praesent sit amet tincidunt ligula. 
                Integer suscipit magna nec turpis vulputate, nec viverra ligula pulvinar. 
                Duis eget ligula sed ipsum pellentesque porta. Sed nec lectus ac odio tincidunt 
                volutpat. Nam malesuada lorem sed nisl faucibus, vitae consequat augue convallis. 
                Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis 
                egestas massa."
            )
            post_as_employee(@manager, "/manager/products/add-beans", params)

            expect(last_response.body).to include(
              'class="error_msg">Description cannot exceed 500 characters<'
            )
          end

          it "shows error message when wrong file type is uploaded for product image" do
            params = test_bean_params(
              image: Rack::Test::UploadedFile.new("spec/test_images/arabic_light.pdf", "application/pdf")
            )
            post_as_employee(@manager, "/manager/products/add-beans", params)

            expect(last_response.body).to include('class="error_msg">Invalid image type<')
          end
          
          it "shows error message when price input is -ve or greater than 300" do
            params = test_bean_params(price: "-100.5")
            post_as_employee(@manager, "/manager/products/add-beans", params)

            expect(last_response.body).to include(
              'class="error_msg">Price must be between 0 and 300<'
            )
          end

          it "shows error message when cost input is -ve or greater than 300" do
            params = test_bean_params(cost: "400")
            post_as_employee(@manager, "/manager/products/add-beans", params)

            expect(last_response.body).to include(
              'class="error_msg">Cost must be between 0 and 300<'
            )
          end

          it "shows error message when stock level input is -ve or greater than 1000" do
            params = test_bean_params(stock: "-5")
            post_as_employee(@manager, "/manager/products/add-beans", params)

            expect(last_response.body).to include(
              'class="error_msg">Stock level must be between 0 and 1000<'
            )
          end

          it "shows error message when roast level input does not exist in roast_levels database" do
            params = test_bean_params(roast: "-1")
            post_as_employee(@manager, "/manager/products/add-beans", params)

            expect(last_response.body).to include(
              'class="error_msg">Invalid roast level<'
            )
          end

          it "shows error message when origin input does not exist in countries database" do
            params = test_bean_params(origin: "-1")
            post_as_employee(@manager, "/manager/products/add-beans", params)

            expect(last_response.body).to include(
              'class="error_msg">Invalid origin<'
            )
          end
        end
      end
    end
  end

  describe "POST /manager/products/update-drinks" do
    context "when not logged in" do
      it "redirects to employee login page" do
        post "/manager/products/update-drinks"

        expect(last_response).to be_redirect
        expect(last_response.location).to include("/employee-login-page?error")
      end
    end

    context "when logged in but not as manager" do
      it "redirects to the appropriate page" do
        barista = add_test_barista_to_db
        post_as_employee(barista, "/manager/products/update-drinks")

        expect(last_response).to be_redirect
        expect(last_response.location).to end_with("/barista/main")
      end
    end

    context "when logged in as manager" do
      before do
        add_default_product_options_to_db
        @manager = add_test_manager_to_db

        #avoid the test from creating an image in the product images folder
        #and create a fake image path for testing
        allow_any_instance_of(Product).to receive(:save_image_path) do |product|
          product.update(image_path: "/images/product_images/test.png")
        end
      end

      context "Inputs are valid" do
        it "updates the existing drink product details" do
          original_product, variants = add_drink_with_multiple_sizes_to_db

          params = test_drink_params(
            id: original_product.product_id.to_s,
            pname: "Updated Latte",
            description: "Updated description",
            availability: "0"
          )

          post_as_employee(@manager, "/manager/products/update-drinks", params)

          updated_product = Product[original_product.product_id]

          expect(updated_product.name).to eq("Updated Latte")
          expect(updated_product.description).to eq("Updated description")
          expect(updated_product.availability).to eq(0)
          expect(updated_product.image_path).to eq("/images/product_images/test.png")
        end

        it "updates the existing drinks variants details" do
          original_product, variants = add_drink_with_multiple_sizes_to_db
          
          params = test_drink_params(
            id: original_product.product_id.to_s,
            price: ["100", "200", "300"],
            cost: ["55", "66", "77"]
          )

          post_as_employee(@manager, "/manager/products/update-drinks", params)

          updated_variants = ProductVariant.where(product_id: original_product.product_id)
          saved_prices = updated_variants.distinct.select_map(:price)
          saved_costs = updated_variants.distinct.select_map(:cost)

          #checks the variants have the updated prices and costs or not
          expect(saved_prices).to match_array(params[:price].map(&:to_f))
          expect(saved_costs).to match_array(params[:cost].map(&:to_f))
        end

        it "creates newly selected variants" do
          original_product, variants = add_drink_with_multiple_sizes_to_db
          original_count = variants.length

          #add one milk option for all sizes
          params = test_drink_params(
            id: original_product.product_id.to_s,
            milk: ["3", "4"]
          )

          post_as_employee(@manager, "/manager/products/update-drinks", params)

          updated_variants = ProductVariant.where(product_id: original_product.product_id)
          saved_milk_options = updated_variants.distinct.select_map(:milk_id)
          
          expect(updated_variants.count).to be > original_count
          #2 milk types for 3 sizes
          expect(updated_variants.count).to eq(6)
          expect(saved_milk_options.map(&:to_s)).to match_array(params[:milk])
        end

        it "deletes unselected variants" do
          original_product, variants = add_drink_with_multiple_sizes_to_db
          original_count = variants.length

          #keeps only one size and one milk option
          params = test_drink_params(
            id: original_product.product_id.to_s,
            size: ["3"],
            milk: ["3"]
          )

          post_as_employee(@manager, "/manager/products/update-drinks", params)

          updated_variants = ProductVariant.where(product_id: original_product.product_id)

          expect(updated_variants.count).to eq(1)
          expect(updated_variants.first.size_id).to eq(3)
          expect(updated_variants.first.milk_id).to eq(3)
          expect(updated_variants.count).to be < original_count
        end

        it "redirects to product - drinks page after successful update" do
          original_product, variants = add_drink_with_multiple_sizes_to_db
          params = test_drink_params(id: original_product.product_id.to_s)
          
          post_as_employee(@manager, "/manager/products/update-drinks", params)

          expect(last_response).to be_redirect
          expect(last_response.location).to include("/manager/products/drinks")
        end
      end
      context "Some inputs are invalid" do
        it "re-renders the form when inputs are invalid" do
          original_product, variants = add_drink_with_multiple_sizes_to_db
          original_id = original_product.product_id.to_s
          
          #when the product name is left empty
          params = test_drink_params(
            id: original_id,
            pname: ""
          )
          post_as_employee(@manager, "/manager/products/update-drinks", params)

          expect(last_response).to be_ok
          expect(last_response.body).to include("Product ID: #{original_id}")
          expect(last_response.body).to match(
            /form\s+id="product_form"\s+method="post"\s+action="\/manager\/products\/update-drinks"/
          )
          expect(last_response.body).to include("error_msg")
        end

        it "does not update product or variants when inputs invalid" do
          original_product, variants = add_drink_with_multiple_sizes_to_db
          original_id = original_product.product_id.to_s

          #when the product name is left empty
          #but try to add more milk options and change description
          params = test_drink_params(
            id: original_id,
            pname: "",
            description: "Updated description",
            milk: ["3", "4", "5"]
          )
          post_as_employee(@manager, "/manager/products/update-drinks", params)

          product = Product[original_id]
          variants = ProductVariant.where(product_id: original_id)
          saved_milks = variants.distinct.select_map(:milk_id)

          expect(product.description).not_to eq("Updated description")
          expect(saved_milks.map(&:to_s)).not_to match_array(params[:milk])
        end

        it "keeps the entered values when re-rendered" do
          original_product, variants = add_drink_with_multiple_sizes_to_db
          original_id = original_product.product_id.to_s

          params = test_drink_params(id: original_id, pname: "")
          post_as_employee(@manager, "/manager/products/update-drinks", params)

          expect(last_response.body).to include(params[:description])
          expect(last_response.body).to include("value=\"#{params[:price][0]}\"")
          expect(last_response.body).to include("value=\"#{params[:cost][0]}\"")
        end
      

        context "when any field is empty" do
          before do
            original_product, variants = add_drink_with_multiple_sizes_to_db
            @original_id = original_product.product_id.to_s
          end
          
          it "shows error message when name is empty" do
            params = test_drink_params(id: @original_id, pname: "")
            post_as_employee(@manager, "/manager/products/update-drinks", params)

            expect(last_response.body).to include(
                  'class="error_msg">Product Name cannot be empty<'
            )
          end

          it "shows error message when description is empty" do
            params = test_drink_params(id: @original_id, description: "")
            post_as_employee(@manager, "/manager/products/update-drinks", params)

            expect(last_response.body).to include(
                'class="error_msg">Description cannot be empty<'
            )
          end

          it "shows error message when user did not input price for all selected sizes" do
            params = test_drink_params(id: @original_id, price: ["2.3", "", "4.5"])
            post_as_employee(@manager, "/manager/products/update-drinks", params)

            expect(last_response.body).to include(
                'class="error_msg">Please fill in price for all selected sizes<'
            )
          end

          it "shows error message when user did not input cost for all selected sizes" do
            params = test_drink_params(id: @original_id, cost: ["", "", ""])
            post_as_employee(@manager, "/manager/products/update-drinks", params)

            expect(last_response.body).to include(
                'class="error_msg">Please fill in cost for all selected sizes<'
            )
          end

          it "shows error message when user did not select any size" do
            params = test_drink_params(id: @original_id, size: [])
            post_as_employee(@manager, "/manager/products/update-drinks", params)

            expect(last_response.body).to include(
                'class="error_msg">Please select at least one size<'
            )
          end

          it "shows error message when user did not select any milk option" do
            params = test_drink_params(id: @original_id, milk: [])
            post_as_employee(@manager, "/manager/products/update-drinks", params)

            expect(last_response.body).to include(
                'class="error_msg">Please select at least one milk option<'
            )
          end
        end

        context "when any input is invalid" do
          before do
            original_product, variants = add_drink_with_multiple_sizes_to_db
            @original_id = original_product.product_id.to_s
          end

          it "shows error message for product name longer than 40 characters" do
            params = test_drink_params(
              id: @original_id,
              pname: "Super super super super super longggggg product name"
            )

            post_as_employee(@manager, "/manager/products/update-drinks", params)

            expect(last_response.body).to include(
              'class="error_msg">Product Name cannot exceed 40 characters<'
            )
          end

          it "shows error message when description input exceed 500 characters" do
            params = test_drink_params(
              id: @original_id,
              description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.
                Vivamus fermentum, justo at efficitur tincidunt, urna turpis suscipit 
                augue, vitae tristique nibh turpis eget lorem. Curabitur sed risus nec 
                nulla aliquet malesuada. Integer vitae turpis sed arcu pulvinar consequat. 
                Donec consequat, velit eget facilisis facilisis, lorem libero sollicitudin, 
                sed hendrerit velit lorem non mi. Suspendisse potenti. Aliquam erat volutpat. 
                Morbi non augue sed sapien cursus interdum. Praesent sit amet tincidunt ligula. 
                Integer suscipit magna nec turpis vulputate, nec viverra ligula pulvinar. 
                Duis eget ligula sed ipsum pellentesque porta. Sed nec lectus ac odio tincidunt 
                volutpat. Nam malesuada lorem sed nisl faucibus, vitae consequat augue convallis. 
                Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis 
                egestas massa."
            )
            post_as_employee(@manager, "/manager/products/update-drinks", params)  
            
            expect(last_response.body).to include(
              'class="error_msg">Description cannot exceed 500 characters<'
            )
          end

          it "shows error message when wrong file type is uploaded for product image" do
            params = test_drink_params(
              id: @original_id,
              image: Rack::Test::UploadedFile.new("spec/test_images/latte.pdf", "application/pdf")
            )
            post_as_employee(@manager, "/manager/products/update-drinks", params)  

            expect(last_response.body).to include('class="error_msg">Invalid image type<')
          end

          it "shows error message when any price input is -ve or greater than 300" do
            params = test_drink_params(
              id: @original_id,
              price: ["-1", "400", "-100"]
            )

            post_as_employee(@manager, "/manager/products/update-drinks", params)

            expect(last_response.body).to include(
              'class="error_msg">Prices must be between 0 and 300<'
            )
          end

          it "shows error message when any cost input is -ve or greater than 300" do
            params = test_drink_params(
              id: @original_id,
              cost: ["-1", "400", "-100"]
            )

            post_as_employee(@manager, "/manager/products/update-drinks", params)

            expect(last_response.body).to include(
              'class="error_msg">Costs must be between 0 and 300<'
            )
          end

          it "shows error message when size input does not exist in sizes database" do
            params = test_drink_params(
              id: @original_id,
              size: ["fake size", "-10"]
            )

            post_as_employee(@manager, "/manager/products/update-drinks", params)

            expect(last_response.body).to include(
              'class="error_msg">Invalid size input<'
            )
          end

          it "shows error message when milk option input does not exist in milk_options database" do
            params = test_drink_params(
              id: @original_id,
              milk: ["doesn't exist", "-10"]
            )

            post_as_employee(@manager, "/manager/products/update-drinks", params)

            expect(last_response.body).to include(
              'class="error_msg">Invalid milk option input<'
            )
          end
        end
      end
    end
  end

  describe "POST /manager/products/update-beans" do
    context "when not logged in" do
      it "redirects to employee login page" do
        post "/manager/products/update-beans"

        expect(last_response).to be_redirect
        expect(last_response.location).to include("/employee-login-page?error")
      end
    end

    context "when logged in but not as manager" do
      it "redirects to the appropriate page" do
        barista = add_test_barista_to_db
        post_as_employee(barista, "/manager/products/update-beans")

        expect(last_response).to be_redirect
        expect(last_response.location).to end_with("/barista/main")
      end
    end

    context "when logged in as manager" do
      before do
        add_default_product_options_to_db
        @bean, @variant = add_test_bean_to_db
        @id = @bean.product_id.to_s
        @manager = add_test_manager_to_db

        #avoid the test from creating an image in the product images folder
        #and create a fake image path for testing
        allow_any_instance_of(Product).to receive(:save_image_path) do |product|
          product.update(image_path: "/images/product_images/test.png")
        end
      end

      context "Inputs are valid" do
        it "updates the existing bean product details" do
          params = test_bean_params(
            id: @id,
            pname: "Updated Bean",
            description: "Updated description",
            availability: "0",
            stock: 88,
            origin: "3",
            roast: "4"
          )
          post_as_employee(@manager, "/manager/products/update-beans", params)

          updated_product = Product[@id]

          expect(updated_product.name).to eq("Updated Bean")
          expect(updated_product.description).to eq("Updated description")
          expect(updated_product.availability).to eq(0)
          expect(updated_product.stock_level).to eq(88)
          expect(updated_product.origin).to eq(3)
          expect(updated_product.roast_level).to eq(4)
          expect(updated_product.image_path).to eq("/images/product_images/test.png")
        end

        it "updates the existing bean variant details" do
          params = test_bean_params(
            id: @id,
            price: "299.99",
            cost: "200.99"
          )
          post_as_employee(@manager, "/manager/products/update-beans", params)

          updated_variant = ProductVariant.first(product_id: @id)
          expect(updated_variant.price).to eq(params[:price].to_f)
          expect(updated_variant.cost).to eq(params[:cost].to_f)
        end

        it "redirects to product - beans page after successful update" do
          params = test_bean_params(id: @id)
          
          post_as_employee(@manager, "/manager/products/update-beans", params)

          expect(last_response).to be_redirect
          expect(last_response.location).to include("/manager/products/beans")
        end
      end

      context "Some inputs are invalid" do
        it "re-renders the form when inputs are invalid" do
          params = test_bean_params(
            id: @id,
            pname: ""
          )
          post_as_employee(@manager, "/manager/products/update-beans", params)

          expect(last_response).to be_ok
          expect(last_response.body).to include("Product ID: #{@id}")
          expect(last_response.body).to match(
            /form\s+id="product_form"\s+method="post"\s+action="\/manager\/products\/update-beans"/
          )
          expect(last_response.body).to include("error_msg")
        end

        it "does not update product or variants when inputs invalid" do
          params = test_bean_params(
            id: @id,
            pname: "",
            description: "Updated description",
            price: "76.88"
          )
          post_as_employee(@manager, "/manager/products/update-beans", params)

          product = Product[@id]
          variant = ProductVariant.first(product_id: @id)

          expect(product.description).not_to eq("Updated description")
          expect(variant.price).not_to eq(params[:price].to_f)
        end

        it "keeps the entered values when re-rendered" do
          params = test_bean_params(
            id: @id,
            pname: "",
            description: "Updated description",
            price: "76.88"
          )
          post_as_employee(@manager, "/manager/products/update-beans", params)

          expect(last_response.body).to include(params[:description])
          expect(last_response.body).to include("value=\"#{params[:price]}\"")
          expect(last_response.body).to include("value=\"#{params[:cost]}\"")
        end

        context "when any field is empty" do
          it "shows error message when name is empty" do
            params = test_bean_params(id: @id, pname: "")
            post_as_employee(@manager, "/manager/products/update-beans", params)

            expect(last_response.body).to include(
              'class="error_msg">Product Name cannot be empty<'
            )
          end

          it "shows error message when description is empty" do
            params = test_bean_params(id: @id, description: "")
            post_as_employee(@manager, "/manager/products/update-beans", params)

            expect(last_response.body).to include(
              'class="error_msg">Description cannot be empty<'
            )
          end

          it "shows error message when user did not input price" do
            params = test_bean_params(id: @id, price: "")
            post_as_employee(@manager, "/manager/products/update-beans", params)

            expect(last_response.body).to include(
              'class="error_msg">Price cannot be empty<'
            )
          end

          it "shows error message when user did not input cost" do
            params = test_bean_params(id: @id, cost: "")
            post_as_employee(@manager, "/manager/products/update-beans", params)

            expect(last_response.body).to include(
              'class="error_msg">Cost cannot be empty<'
            )
          end

          it "shows error message when user did not input stock level" do
            params = test_bean_params(id: @id, stock: "")
            post_as_employee(@manager, "/manager/products/update-beans", params)

            expect(last_response.body).to include(
              'class="error_msg">Stock level cannot be empty<'
            )
          end

          it "shows error message when user did not select roast level" do
            params = test_bean_params(id: @id, roast: "")
            post_as_employee(@manager, "/manager/products/update-beans", params)

            expect(last_response.body).to include(
              'class="error_msg">Please select a roast level<'
            )
          end

          it "shows error message when user did not select origin" do
            params = test_bean_params(id: @id, origin: "")
            post_as_employee(@manager, "/manager/products/update-beans", params)

            expect(last_response.body).to include(
              'class="error_msg">Please select an origin<'
            )
          end
        end

        context "when any input is invalid" do
          it "shows error message for product name longer than 40 characters" do
            params = test_bean_params(
              id: @id,
              pname: "Super super super super super longggggg product name"
            )

            post_as_employee(@manager, "/manager/products/update-beans", params)

            expect(last_response.body).to include(
              'class="error_msg">Product Name cannot exceed 40 characters<'
            )
          end

          it "shows error message when description input exceed 500 characters" do
            params = test_bean_params(
              id: @id,
              description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.
                Vivamus fermentum, justo at efficitur tincidunt, urna turpis suscipit 
                augue, vitae tristique nibh turpis eget lorem. Curabitur sed risus nec 
                nulla aliquet malesuada. Integer vitae turpis sed arcu pulvinar consequat. 
                Donec consequat, velit eget facilisis facilisis, lorem libero sollicitudin, 
                sed hendrerit velit lorem non mi. Suspendisse potenti. Aliquam erat volutpat. 
                Morbi non augue sed sapien cursus interdum. Praesent sit amet tincidunt ligula. 
                Integer suscipit magna nec turpis vulputate, nec viverra ligula pulvinar. 
                Duis eget ligula sed ipsum pellentesque porta. Sed nec lectus ac odio tincidunt 
                volutpat. Nam malesuada lorem sed nisl faucibus, vitae consequat augue convallis. 
                Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis 
                egestas massa."
            )

            post_as_employee(@manager, "/manager/products/update-beans", params)

            expect(last_response.body).to include(
              'class="error_msg">Description cannot exceed 500 characters<'
            )
          end

          it "shows error message when wrong file type is uploaded for product image" do
            params = test_bean_params(
              id: @id,
              image: Rack::Test::UploadedFile.new(
                "spec/test_images/arabic_light.pdf",
                "application/pdf"
              )
            )

            post_as_employee(@manager, "/manager/products/update-beans", params)

            expect(last_response.body).to include(
              'class="error_msg">Invalid image type<'
            )
          end

          it "shows error message when price input is -ve or greater than 300" do
            params = test_bean_params(id: @id, price: "-100.5")

            post_as_employee(@manager, "/manager/products/update-beans", params)

            expect(last_response.body).to include(
              'class="error_msg">Price must be between 0 and 300<'
            )
          end

          it "shows error message when cost input is -ve or greater than 300" do
            params = test_bean_params(id: @id, cost: "400")

            post_as_employee(@manager, "/manager/products/update-beans", params)

            expect(last_response.body).to include(
              'class="error_msg">Cost must be between 0 and 300<'
            )
          end

          it "shows error message when stock level input is -ve or greater than 1000" do
            params = test_bean_params(id: @id, stock: "-5")

            post_as_employee(@manager, "/manager/products/update-beans", params)

            expect(last_response.body).to include(
              'class="error_msg">Stock level must be between 0 and 1000<'
            )
          end

          it "shows error message when roast level input does not exist in roast_levels database" do
            params = test_bean_params(id: @id, roast: "-1")

            post_as_employee(@manager, "/manager/products/update-beans", params)

            expect(last_response.body).to include(
              'class="error_msg">Invalid roast level<'
            )
          end

          it "shows error message when origin input does not exist in countries database" do
            params = test_bean_params(id: @id, origin: "-1")

            post_as_employee(@manager, "/manager/products/update-beans", params)

            expect(last_response.body).to include(
              'class="error_msg">Invalid origin<'
            )
          end
        end
      end
    end
  end

  describe "GET /manager/products/details" do
    context "when not logged in" do
      it "redirects to employee login page" do
        get "/manager/products/details?id=1"

        expect(last_response).to be_redirect
        expect(last_response.location).to include("/employee-login-page?error")
      end
    end

    context "when logged in but not as manager" do
      it "redirects to the appropriate page" do
        barista = add_test_barista_to_db
        get_as_employee(barista, "/manager/products/details?id=1")

        expect(last_response).to be_redirect
        expect(last_response.location).to end_with("/barista/main")
      end
    end

    context "when logged in as manager" do
      it "redirects to product - drinks page when product does not exist" do
        manager = add_test_manager_to_db

        get_as_employee(manager, "/manager/products/details", { "id" => "-1" })

        expect(last_response).to be_redirect
        expect(last_response.location).to include("/manager/products/drinks")
      end

      it "shows drink product details" do
        add_default_product_options_to_db
        drink, variants = add_drink_with_multiple_sizes_to_db
        id = drink.product_id.to_s
        manager = add_test_manager_to_db

        get_as_employee(manager, "/manager/products/details", {
          "id" => id
        })

        expect(last_response).to be_ok
        expect(last_response.body).to include("Product Details")
        expect(last_response.body).to include("Product ID:")
        expect(last_response.body).to include(id)
        expect(last_response.body).to include("Product Name:")
        expect(last_response.body).to include(drink.name)
        expect(last_response.body).to include("Product Type:")
        expect(last_response.body).to include("drinks")
        expect(last_response.body).to include("Description:")
        expect(last_response.body).to include(drink.description)

        expect(last_response.body).to include("Status:")
        if drink.availability == 1 
          expect(last_response.body).to include("Available")
        else
          expect(last_response.body).to include("Unavailable")
        end

        expect(last_response.body).to include("Back")
        expect(last_response.body).to include("Edit")
        expect(last_response.body).to include("href=\"/manager/products/update-drinks?id=#{id}\"")
      end

      it "shows drink variant details" do
        add_default_product_options_to_db
        drink, variants = add_drink_with_multiple_sizes_to_db
        manager = add_test_manager_to_db

        get_as_employee(
          manager, "/manager/products/details", 
          { "id" => drink.product_id.to_s }
        )

        expect(last_response.body).to include("Available Sizes:")
        expect(last_response.body).to include("Milk Options:")
        expect(last_response.body).to include("Prices:")
        expect(last_response.body).to include("Costs:")

        variants.each do |variant|
          expect(last_response.body).to include(Size.get_size(variant.size_id))
          expect(last_response.body).to include(MilkOption.get_milk_name(variant.milk_id))
          expect(last_response.body).to include("£#{variant.price}")
          expect(last_response.body).to include("£#{variant.cost}")
        end
      end

      it "shows bean product details" do
        add_default_product_options_to_db
        bean, variant = add_test_bean_to_db
        id = bean.product_id.to_s
        manager = add_test_manager_to_db

        get_as_employee(manager, "/manager/products/details", {
          "id" => id
        })

        expect(last_response).to be_ok
        expect(last_response.body).to include("Product Details")
        expect(last_response.body).to include("Product ID:")
        expect(last_response.body).to include(id)
        expect(last_response.body).to include("Product Name:")
        expect(last_response.body).to include(bean.name)
        expect(last_response.body).to include("Product Type:")
        expect(last_response.body).to include("beans")
        expect(last_response.body).to include("Description:")
        expect(last_response.body).to include(bean.description)

        expect(last_response.body).to include("Origin:")
        expect(last_response.body).to include("Roast Level:")
        expect(last_response.body).to include("Price:")
        expect(last_response.body).to include("Cost:")
        expect(last_response.body).to include("Stock:")

        expect(last_response.body).to include(variant.price.to_s)
        expect(last_response.body).to include(variant.cost.to_s)
        expect(last_response.body).to include(bean.stock_level.to_s)

        expect(last_response.body).to include("Status:")
        if bean.availability == 1 
          expect(last_response.body).to include("Available")
        else
          expect(last_response.body).to include("Unavailable")
        end

        expect(last_response.body).to include("Back")
        expect(last_response.body).to include("Edit")
        expect(last_response.body).to include("href=\"/manager/products/update-beans?id=#{id}\"")
      end
    end
  end

  describe "POST /manager/products/new-origin" do
    context "when not logged in" do
      it "redirects to employee login page" do
        post "/manager/products/new-origin"

        expect(last_response).to be_redirect
        expect(last_response.location).to include("/employee-login-page?error")
      end
    end

    context "when logged in but not as manager" do
      it "redirects to the appropriate page" do
        barista = add_test_barista_to_db

        post_as_employee(barista, "/manager/products/new-origin", {
          new_origin: "Italian",
          action: "add"
        })

        expect(last_response).to be_redirect
        expect(last_response.location).to end_with("/barista/main")
      end
    end

    context "when logged in as manager" do
      before do
        add_default_product_options_to_db
        @manager = add_test_manager_to_db
      end

      it "creates a new origin" do
        params = { new_origin: "Italian", action: "add", lastpage: "beans" }

        expect {
          post_as_employee(@manager, "/manager/products/new-origin", params)
        }.to change(Country, :count).by(1)
      end

      it "redirects back to add beans page after creating origin while adding" do
        params = { new_origin: "Italian", action: "add", lastpage: "beans" }

        post_as_employee(@manager, "/manager/products/new-origin", params)

        expect(last_response).to be_redirect
        expect(last_response.location).to include("/manager/products/add-beans")
      end

      it "redirects back to update beans page after creating origin while updating" do
        bean, variant = add_test_bean_to_db

        params = { new_origin: "Italian", action: "update", id: bean.product_id.to_s }

        post_as_employee(@manager, "/manager/products/new-origin", params)

        expect(last_response).to be_redirect
        expect(last_response.location).to include(
          "/manager/products/update-beans?id=#{bean.product_id}"
        )
      end

      it "does not create a new origin when input is invalid" do
        params = { new_origin: "", action: "add", lastpage: "beans" }

        expect {
          post_as_employee(@manager, "/manager/products/new-origin", params)
        }.not_to change(Country, :count)
      end

      it "redirects back to add beans form with error when invalid while adding" do
        params = { new_origin: "", action: "add", lastpage: "beans" }

        post_as_employee(@manager, "/manager/products/new-origin", params)

        expect(last_response).to be_redirect
        expect(last_response.location).to include("/manager/products/add-beans")
        expect(last_response.location).to include("error=")
        expect(last_response.location).to include("origin_input=")
        expect(last_response.location).to include("#add_origin")
      end

      it "redirects back to update beans form with error when invalid while updating" do
        bean, variant = add_test_bean_to_db

        params = { new_origin: "", action: "update", id: bean.product_id.to_s }

        post_as_employee(@manager, "/manager/products/new-origin", params)

        expect(last_response).to be_redirect
        expect(last_response.location).to include("/manager/products/update-beans")
        expect(last_response.location).to include("id=#{bean.product_id}")
        expect(last_response.location).to include("error=")
        expect(last_response.location).to include("origin_input=")
        expect(last_response.location).to include("#add_origin")
      end

      it "shows error message when user does not input an origin" do
        params = { new_origin: "", action: "add", lastpage: "beans" }
        post_as_employee(@manager, "/manager/products/new-origin", params)

        follow_redirect!
        expect(last_response.body).to include(
          'class="error_msg">Please input a origin<'
        )
      end

      it "shows error message when the input origin already exists" do
        params = { new_origin: "Arabic", action: "add", lastpage: "beans" }
        post_as_employee(@manager, "/manager/products/new-origin", params)

        follow_redirect!
        expect(last_response.body).to include(
          'class="error_msg">This origin already exists<'
        )
      end

      it "shows error message when the input origin longer than 40 characters" do
        params = { 
          new_origin: "Veryyyyyyyyyyyyy longggggggggggggggggg originnnnnnnnnnnnnnnnn",
          action: "add", lastpage: "beans" 
        }
        post_as_employee(@manager, "/manager/products/new-origin", params)
        
        follow_redirect!
        expect(last_response.body).to include(
          'class="error_msg">Maximum 40 characters<'
        )
      end
    end
  end
end