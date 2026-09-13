RSpec.describe "manager products page controller" do
  describe "GET /manager/products/drinks" do
    context "when not logged in" do
      it "redirects to employee login page" do
        #run the get at a manager page without signing in as an employee
        get "/manager/products/drinks"

        #user will be redirected to the employee login
        expect(last_response).to be_redirect
        expect(last_response.location).to include("/employee-login-page?error")
      end
    end

    context "when logged in but not as manager" do
      it "redirects to the appropriate page" do
        barista = add_test_barista_to_db
        #run the get at manager pages as a barista
        get_as_employee(barista, "/manager/products/drinks")

        #the user will be redirected back to barista's main page
        expect(last_response).to be_redirect
        expect(last_response.location).to end_with("/barista/main")
      end
    end

    context "when logged in as manager" do
      it "loads the page" do
        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/products/drinks")

        expect(last_response).to be_ok
        expect(last_response.body).to include("Products - Drinks")
      end

      it "shows the product table" do
        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/products/drinks")

        expect(last_response.body).to include("<table")
      end

      it "has the right table headers" do
        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/products/drinks")

        expect(last_response.body).to include("ID")
        expect(last_response.body).to include("Name")
        expect(last_response.body).to include("Price")
        expect(last_response.body).to include("Cost")
        expect(last_response.body).to include("Available")
        expect(last_response.body).to include("Details")
      end

      it "has sortable table headers" do
        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/products/drinks")
        
        #testing whether the link for sorting exists for each table header
        expect(last_response.body).to include('class="sort-head"')
        expect(last_response.body).to include('sort=product_id')
        expect(last_response.body).to include('sort=name')
        expect(last_response.body).to include('sort=price')
        expect(last_response.body).to include('sort=cost')
        expect(last_response.body).to include('sort=availability')
      end

      it "shows the drinks entries in the table" do
        add_default_product_options_to_db
        drink = add_test_product_to_db
        variant = add_test_product_variant_to_db(
          drink.product_id, 3, 3
        )

        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/products/drinks")

        expect(last_response.body).to include(drink.product_id.to_s)
        expect(last_response.body).to include(drink.name)
        expect(last_response.body).to include("£#{variant.price}")
        expect(last_response.body).to include("£#{variant.cost}")
        expect(last_response.body).to include("yes")
      end

      it "does not show beans entries in the table" do
        add_default_product_options_to_db
        bean, variant = add_test_bean_to_db
        
        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/products/drinks")

        expect(last_response.body).not_to include(bean.name)
      end

      it "shows all size variants in the table" do
        add_default_product_options_to_db
        #this is a drink with 3 different size variants
        product, variants = add_drink_with_multiple_sizes_to_db
        
        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/products/drinks")

        expect(last_response.body).to include(product.product_id.to_s)
        #there will be one entry in the table for each size variant
        #sharing the same product_id
        variants.each do |variant|
          size = Size.get_size(variant.size_id)
          expect(last_response.body).to include("#{size} #{product.name}")
          expect(last_response.body).to include("£#{variant.price}")
          expect(last_response.body).to include("£#{variant.cost}")
        end
      end

      it "shows available drinks availability as yes" do
        add_default_product_options_to_db
        product = add_test_product_to_db
        variant = add_test_product_variant_to_db(
          product.product_id, 3, 3
        )

        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/products/drinks")

        expect(last_response.body).to include("yes")
      end

      it "shows unavailable drinks availability as no" do
        add_default_product_options_to_db
        #the 0 is for unavailable
        product = add_test_product_to_db("drinks", "Latte", nil, 0)
        variant = add_test_product_variant_to_db(
          product.product_id, 3, 3
        )

        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/products/drinks")

        expect(last_response.body).to include("no")
      end

      it "links to Product Details for each Product" do
        add_default_product_options_to_db
        product = add_test_product_to_db
        variant = add_test_product_variant_to_db(
          product.product_id, 3, 3
        )

        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/products/drinks")
        #test the "details" hyperlink in the 6th column
        link = "href=\"/manager/products/details?id=#{product.product_id}\""
        expect(last_response.body).to include(link)
      end

      it "shows the search bar" do
        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/products/drinks")

        expect(last_response.body).to include('id="search_bar"')
        expect(last_response.body).to include('method="get"')
        expect(last_response.body).to include('action="/manager/products/drinks"')
        expect(last_response.body).to include('name="search_input"')
        expect(last_response.body).to include('name="column_to_search"')
      end

      it "shows the add drinks and add beans buttons" do
        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/products/drinks")

        expect(last_response.body).to include('id="add_drink_btn"')
        expect(last_response.body).to include('id="add_bean_btn"')
        expect(last_response.body).to include("Add Drinks")
        expect(last_response.body).to include("Add Beans")
        #buttons linking to adding new drinks and beans
        expect(last_response.body).to include("/manager/products/add-drinks")
        expect(last_response.body).to include("/manager/products/add-beans")
      end

      context "sorting" do
        it "sorts by price descending" do
          p1_size1_name, p1_size2_name, p2_size_name = add_test_sort_drinks_to_db

          manager = add_test_manager_to_db
          get_as_employee(manager, "/manager/products/drinks",
            { "sort" => "price", "order" => "desc" }
          )

          body = last_response.body
          #test which product variant's name appears first in the table after sort
          expect(body.index(p1_size2_name)).to be < body.index(p2_size_name)
          expect(body.index(p2_size_name)).to be < body.index(p1_size1_name)
        end
        
        it "sorts by price ascending" do
          p1_size1_name, p1_size2_name, p2_size_name = add_test_sort_drinks_to_db

          manager = add_test_manager_to_db
          get_as_employee(manager, "/manager/products/drinks",
            { "sort" => "price", "order" => "asc" }
          )

          body = last_response.body
          #test which product variant's name appears first in the table after sort
          expect(body.index(p1_size2_name)).to be > body.index(p2_size_name)
          expect(body.index(p2_size_name)).to be > body.index(p1_size1_name)
        end

        it "sorts by name descending" do
          p1_size1_name, p1_size2_name, p2_size_name = add_test_sort_drinks_to_db

          manager = add_test_manager_to_db
          get_as_employee(manager, "/manager/products/drinks",
            { "sort" => "name", "order" => "desc" }
          )

          body = last_response.body
          #test which product variant's name appears first in the table after sort
          expect(body.index(p1_size1_name)).to be < body.index(p1_size2_name)
          expect(body.index(p1_size2_name)).to be < body.index(p2_size_name)
        end

        it "sorts by name ascending" do
          p1_size1_name, p1_size2_name, p2_size_name = add_test_sort_drinks_to_db

          manager = add_test_manager_to_db
          get_as_employee(manager, "/manager/products/drinks",
            { "sort" => "name", "order" => "asc" }
          )

          body = last_response.body
          #test which product variant's name appears first in the table after sort
          expect(body.index(p1_size1_name)).to be > body.index(p1_size2_name)
          expect(body.index(p1_size2_name)).to be > body.index(p2_size_name)
        end

        it "falls back to sort by product_id for invalid sort params" do
          p1_size1_name, p1_size2_name, p2_size_name = add_test_sort_drinks_to_db
          
          manager = add_test_manager_to_db
          get_as_employee(manager, "/manager/products/drinks",
            { "sort" => "error", "order" => "desc" }
          )

          body = last_response.body
          #test which product variant's name appears first in the table after sort
          expect(body.index(p2_size_name)).to be < body.index(p1_size1_name)
          expect(body.index(p2_size_name)).to be < body.index(p1_size2_name)
        end

        it "falls back to ascending for invalid order params" do
          p1_size1_name, p1_size2_name, p2_size_name = add_test_sort_drinks_to_db

          manager = add_test_manager_to_db
          get_as_employee(manager, "/manager/products/drinks",
            { "sort" => "name", "order" => "error" }
          )

          body = last_response.body
          #test which product variant's name appears first in the table after sort
          expect(body.index(p1_size1_name)).to be > body.index(p1_size2_name)
          expect(body.index(p1_size2_name)).to be > body.index(p2_size_name)
        end

        it "by default sorts by product_id ascending" do
          manager = add_test_manager_to_db
          get_as_employee(manager, "/manager/products/drinks")

          #the link in table header specify the order of the next sort
          #when the header is pressed so by default the next order
          #for all headers will be order=desc none of them should have order=asc
          expect(last_response.body).to include("order=desc")
          expect(last_response.body).not_to include("order=asc")
        end

        it "does not show the sort direction arrow by default" do
          manager = add_test_manager_to_db
          get_as_employee(manager, "/manager/products/drinks")
          
          expect(last_response.body).not_to include("▼")
          expect(last_response.body).not_to include("▲")
        end

        context "when sorted already" do
          context "pressing on the same column header reverse the sorting order" do
            it "has descending order now" do
              manager = add_test_manager_to_db
              get_as_employee(manager, "/manager/products/drinks",
                { "sort" => "price", "order" => "desc" }
              )

              #test the link in Price table header
              expect(last_response.body).to include("sort=price&order=asc")
            end
            
            it "has ascending order now" do
              manager = add_test_manager_to_db
              get_as_employee(
                manager,
                "/manager/products/drinks",
                { "sort" => "price", "order" => "asc" }
              )

              #test the link in Price table header
              expect(last_response.body).to include("sort=price&order=desc")
            end
          end

          it "pressing any other column header will sort in descending order" do
            manager = add_test_manager_to_db
            get_as_employee(
              manager,
              "/manager/products/drinks",
              { "sort" => "price", "order" => "desc" }
            )
            #test the link of all other table headers except Price
            expect(last_response.body).to include("sort=product_id&order=desc")
            expect(last_response.body).to include("sort=name&order=desc")
            expect(last_response.body).to include("sort=cost&order=desc")
            expect(last_response.body).to include("sort=availability&order=desc")
          end

          context "shows the correct sort direction symbol on the right column header" do
            it "shows ▼ when in descending order" do
              manager = add_test_manager_to_db
              get_as_employee(
                manager,
                "/manager/products/drinks",
                { "sort" => "price", "order" => "desc" }
              )

              expect(last_response.body).to include("Price ▼")
            end

            it "shows ▲ when in ascending order" do
              manager = add_test_manager_to_db
              get_as_employee(
                manager,
                "/manager/products/drinks",
                { "sort" => "price", "order" => "asc" }
              )

              expect(last_response.body).to include("Price ▲")
            end
          end
        end
        
        it "keeps searching filters when sorting" do
          manager = add_test_manager_to_db
          get_as_employee(
            manager,
            "/manager/products/drinks",
            { "column_to_search" => "name", "search_input" => "Latte" }
          )

          #5 sort headers plus the two add buttons therefore count 7
          expect(last_response.body.scan("column_to_search=name").length).to eq(7)
          expect(last_response.body.scan("search_input=Latte").length).to eq(7)
        end
      end

      context "searching" do
        it "searches by Product ID" do
          latte, americano, mocha = add_test_search_drinks_to_db

          manager = add_test_manager_to_db
          get_as_employee(
            manager,
            "/manager/products/drinks",
            { "column_to_search" => "product_id", "search_input" => latte[:product].product_id.to_s }
          )

          #Only shows the name of all size variants with the product_id 1
          expect(last_response.body).to include(latte[:small])
          expect(last_response.body).to include(latte[:regular])
          expect(last_response.body).not_to include(americano[:regular])
          expect(last_response.body).not_to include(mocha[:regular])
        end

        it "searches by name" do
          latte, americano, mocha = add_test_search_drinks_to_db

          manager = add_test_manager_to_db
          get_as_employee(
            manager,
            "/manager/products/drinks",
            { "column_to_search" => "name", "search_input" => "Latte" }
          )

          #Only shows the name of all size variants with the term "Latte" in them
          expect(last_response.body).to include(latte[:small])
          expect(last_response.body).to include(latte[:regular])
          expect(last_response.body).not_to include(americano[:regular])
          expect(last_response.body).not_to include(mocha[:regular])
        end

        it "searches with size by name" do
          latte, americano, mocha = add_test_search_drinks_to_db

          manager = add_test_manager_to_db
          get_as_employee(
            manager,
            "/manager/products/drinks",
            { "column_to_search" => "name", "search_input" => "Regular" }
          )

          #Only shows the name of all size variants with the term "Regular" in them
          expect(last_response.body).not_to include(latte[:small])
          expect(last_response.body).to include(latte[:regular])
          expect(last_response.body).to include(americano[:regular])
          expect(last_response.body).to include(mocha[:regular])
        end

        it "can search by name with partial strings" do
          latte, americano, mocha = add_test_search_drinks_to_db

          manager = add_test_manager_to_db
          get_as_employee(
            manager,
            "/manager/products/drinks",
            { "column_to_search" => "name", "search_input" => "Lat" }
          )

          #Only shows the name of all size variants with the term "Lat" in them
          #show the search accepts substrings of product variants names
          expect(last_response.body).to include(latte[:small])
          expect(last_response.body).to include(latte[:regular])
          expect(last_response.body).not_to include(americano[:regular])
          expect(last_response.body).not_to include(mocha[:regular])
        end

        it "searches name case insensitively" do
          latte, americano, mocha = add_test_search_drinks_to_db

          manager = add_test_manager_to_db
          get_as_employee(
            manager,
            "/manager/products/drinks",
            { "column_to_search" => "name", "search_input" => "LaTtE" }
          )

          #Only shows the name of all size variants with the term "LaTtE" in them
          #shows the search is case insensitive
          expect(last_response.body).to include(latte[:small])
          expect(last_response.body).to include(latte[:regular])
          expect(last_response.body).not_to include(americano[:regular])
          expect(last_response.body).not_to include(mocha[:regular])
        end

        it "searches available products" do
          latte, americano, mocha = add_test_search_drinks_to_db

          manager = add_test_manager_to_db
          get_as_employee(
            manager,
            "/manager/products/drinks",
            { "column_to_search" => "availability", "search_input" => "yes" }
          )

          #Only shows the name of all size variants with availability 1
          expect(last_response.body).to include(latte[:small])
          expect(last_response.body).to include(latte[:regular])
          expect(last_response.body).to include(americano[:regular])
          expect(last_response.body).not_to include(mocha[:regular])
        end

        it "searches unavailable products" do
          latte, americano, mocha = add_test_search_drinks_to_db

          manager = add_test_manager_to_db
          get_as_employee(
            manager,
            "/manager/products/drinks",
            { "column_to_search" => "availability", "search_input" => "no" }
          )

          #Only shows the name of all size variants with availability 0
          expect(last_response.body).not_to include(latte[:small])
          expect(last_response.body).not_to include(latte[:regular])
          expect(last_response.body).not_to include(americano[:regular])
          expect(last_response.body).to include(mocha[:regular])
        end

        it "searches availability case insensitively" do
          latte, americano, mocha = add_test_search_drinks_to_db

          manager = add_test_manager_to_db
          get_as_employee(
            manager,
            "/manager/products/drinks",
            { "column_to_search" => "availability", "search_input" => "YeS" }
          )

          #Only shows the name of all size variants with availability 1
          #shows the search is case insensitive
          expect(last_response.body).to include(latte[:small])
          expect(last_response.body).to include(latte[:regular])
          expect(last_response.body).to include(americano[:regular])
          expect(last_response.body).not_to include(mocha[:regular])
        end

        it "searches availability with partial strings" do
          latte, americano, mocha = add_test_search_drinks_to_db

          manager = add_test_manager_to_db
          get_as_employee(
            manager,
            "/manager/products/drinks",
            { "column_to_search" => "availability", "search_input" => "y" }
          )

          #Only shows the name of all size variants with availability 1
          #shows the search accepts substring of yes/no
          expect(last_response.body).to include(latte[:small])
          expect(last_response.body).to include(latte[:regular])
          expect(last_response.body).to include(americano[:regular])
          expect(last_response.body).not_to include(mocha[:regular])
        end

        it "returns no result for invalid availability input" do
          latte, americano, mocha = add_test_search_drinks_to_db

          manager = add_test_manager_to_db
          get_as_employee(
            manager,
            "/manager/products/drinks",
            { "column_to_search" => "availability", "search_input" => "error" }
          )

          expect(last_response.body).not_to include(latte[:small])
          expect(last_response.body).not_to include(latte[:regular])
          expect(last_response.body).not_to include(americano[:regular])
          expect(last_response.body).not_to include(mocha[:regular])
        end

        it "shows all entries for invalid column_to_search input" do
          latte, americano, mocha = add_test_search_drinks_to_db

          manager = add_test_manager_to_db
          get_as_employee(
            manager,
            "/manager/products/drinks",
            { "column_to_search" => "error", "search_input" => "Something does not exist" }
          )

          #Everything shows in the table when column_to_search input is not
          #in the whitelist
          expect(last_response.body).to include(latte[:small])
          expect(last_response.body).to include(latte[:regular])
          expect(last_response.body).to include(americano[:regular])
          expect(last_response.body).to include(mocha[:regular])
        end
      end

      it "keeps the search input after search" do
        manager = add_test_manager_to_db
        get_as_employee(
          manager,
          "/manager/products/drinks",
          { "column_to_search" => "name", "search_input" => "Testing keep input" }
        )

        #The search keeps user's input in the search bar
        expect(last_response.body).to include("Testing keep input")
      end

      it "keeps the sorting order when searching" do
        latte, americano, mocha = add_test_search_drinks_to_db
        
        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/products/drinks",
          { 
            "sort" => "name", "order" => "desc",
            "column_to_search" => "name", "search_input" => "Regular"
          }
        )

        body = last_response.body
        #Hidden input is used to save sorting order for search
        expect(body).to include('form id="search_bar"')
        expect(body).to include('type="hidden" name="sort" value="name"')
        expect(body).to include('type="hidden" name="order" value="desc"')
        
        #Test the product variants names' order and the filtering of the search
        expect(body).not_to include(latte[:small])
        expect(body).to include(latte[:regular])
        expect(body).to include(americano[:regular])
        expect(body).to include(mocha[:regular])
        expect(body.index(mocha[:regular])).to be < body.index(latte[:regular])
        expect(body.index(latte[:regular])).to be < body.index(americano[:regular])
      end
    end
  end

  describe "GET /manager/products/beans" do
    context "when not logged in" do
      it "redirects to employee login page" do
        get "/manager/products/beans"

        expect(last_response).to be_redirect
        expect(last_response.location).to include("/employee-login-page?error")
      end
    end

    context "when logged in but not as manager" do
      it "redirects to the appropriate page" do
        barista = add_test_barista_to_db
        get_as_employee(barista, "/manager/products/beans")

        expect(last_response).to be_redirect
        expect(last_response.location).to end_with("/barista/main")
      end
    end

    context "when logged in as manager" do
      it "loads the page" do
        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/products/beans")

        expect(last_response).to be_ok
        expect(last_response.body).to include("Products - Beans")
      end

      it "shows the product table" do
        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/products/beans")

        expect(last_response.body).to include("<table")
      end

      it "has the right table headers" do
        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/products/beans")

        expect(last_response.body).to include("ID")
        expect(last_response.body).to include("Name")
        expect(last_response.body).to include("Price")
        expect(last_response.body).to include("Cost")
        expect(last_response.body).to include("Available")
        expect(last_response.body).to include("Stock")
        expect(last_response.body).to include("Details")
      end

      it "has sortable table headers" do
        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/products/beans")
        
        #testing whether the link for sorting exists for each table header
        expect(last_response.body).to include('class="sort-head"')
        expect(last_response.body).to include('sort=product_id')
        expect(last_response.body).to include('sort=name')
        expect(last_response.body).to include('sort=price')
        expect(last_response.body).to include('sort=cost')
        expect(last_response.body).to include('sort=stock_level')
        expect(last_response.body).to include('sort=availability')
      end

      it "shows the beans entries in the table" do
        add_default_product_options_to_db
        bean, variant = add_test_bean_to_db

        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/products/beans")

        expect(last_response.body).to include(bean.product_id.to_s)
        expect(last_response.body).to include(bean.name)
        expect(last_response.body).to include("£#{variant.price}")
        expect(last_response.body).to include("£#{variant.cost}")
        expect(last_response.body).to include("yes")
      end

      it "does not show drinks entries in the table" do
        add_default_product_options_to_db
        drink = add_test_product_to_db
        variant = add_test_product_variant_to_db(
          drink.product_id, 3, 3
        )
        
        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/products/beans")

        expect(last_response.body).not_to include(drink.name)
      end

      it "shows available beans availability as yes" do
        add_default_product_options_to_db
        bean, variant = add_test_bean_to_db

        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/products/beans")

        expect(last_response.body).to include("yes")
      end

      it "shows unavailable beans availability as no" do
        add_default_product_options_to_db
        #the 0 is for unavailable
        product = add_test_product_to_db("beans", "Bean", 30, 0)
        variant = add_test_product_variant_to_db(
          product.product_id, 1, 1
        )

        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/products/beans")

        expect(last_response.body).to include("no")
      end

      it "links to Product Details for each Product" do
        add_default_product_options_to_db
        bean, variant = add_test_bean_to_db

        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/products/beans")

        #test the "details" hyperlink in the 7th column
        link = "href=\"/manager/products/details?id=#{bean.product_id}\""
        expect(last_response.body).to include(link)
      end

      it "shows the search bar" do
        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/products/beans")

        expect(last_response.body).to include('id="search_bar"')
        expect(last_response.body).to include('method="get"')
        expect(last_response.body).to include('action="/manager/products/beans"')
        expect(last_response.body).to include('name="search_input"')
        expect(last_response.body).to include('name="column_to_search"')
      end

      it "shows the add drinks and add beans buttons" do
        manager = add_test_manager_to_db
        get_as_employee(manager, "/manager/products/beans")

        expect(last_response.body).to include('id="add_drink_btn"')
        expect(last_response.body).to include('id="add_bean_btn"')
        expect(last_response.body).to include("Add Drinks")
        expect(last_response.body).to include("Add Beans")
        #buttons linking to adding new drinks and beans
        expect(last_response.body).to include("/manager/products/add-drinks")
        expect(last_response.body).to include("/manager/products/add-beans")
      end

      context "sorting" do
        it "sorts by cost descending" do
          bean_a, bean_z = add_test_sort_beans_to_db
          
          manager = add_test_manager_to_db
          get_as_employee(manager, "/manager/products/beans",
            { "sort" => "cost", "order" => "desc" }
          )

          body = last_response.body
          #test which beans' name appears first in the table after sort
          expect(body.index(bean_z[0].name)).to be < body.index(bean_a[0].name)
        end

        it "sorts by cost ascending" do
          bean_a, bean_z = add_test_sort_beans_to_db
          
          manager = add_test_manager_to_db
          get_as_employee(manager, "/manager/products/beans",
            { "sort" => "cost", "order" => "asc" }
          )

          body = last_response.body
          #test which beans' name appears first in the table after sort
          expect(body.index(bean_z[0].name)).to be > body.index(bean_a[0].name)
        end

        it "sorts by stock descending" do
          bean_a, bean_z = add_test_sort_beans_to_db
          
          manager = add_test_manager_to_db
          get_as_employee(manager, "/manager/products/beans",
            { "sort" => "stock_level", "order" => "desc" }
          )

          body = last_response.body
          #test which beans' name appears first in the table after sort
          expect(body.index(bean_z[0].name)).to be > body.index(bean_a[0].name)
        end

        it "sorts by stock ascending" do
          bean_a, bean_z = add_test_sort_beans_to_db
          
          manager = add_test_manager_to_db
          get_as_employee(manager, "/manager/products/beans",
            { "sort" => "stock_level", "order" => "asc" }
          )

          body = last_response.body
          #test which beans' name appears first in the table after sort
          expect(body.index(bean_z[0].name)).to be < body.index(bean_a[0].name)
        end

        it "falls back to sort by product_id for invalid sort params" do
          bean_a, bean_z = add_test_sort_beans_to_db

          manager = add_test_manager_to_db
          get_as_employee(manager, "/manager/products/beans",
            { "sort" => "error", "order" => "desc" }
          )

          body = last_response.body
          #test which beans' name appears first in the table after sort
          expect(body.index(bean_z[0].name)).to be < body.index(bean_a[0].name)
        end

        it "falls back to ascending for invalid order params" do
          bean_a, bean_z = add_test_sort_beans_to_db

          manager = add_test_manager_to_db
          get_as_employee(manager, "/manager/products/beans",
            { "sort" => "name", "order" => "error" }
          )

          body = last_response.body
          #test which beans' name appears first in the table after sort
          expect(body.index(bean_z[0].name)).to be > body.index(bean_a[0].name)
        end

        it "by default sorts by product_id ascending" do
          manager = add_test_manager_to_db
          get_as_employee(manager, "/manager/products/beans")

          #the link in table header specify the order of the next sort
          #when the header is pressed so by default the next order
          #for all headers will be order=desc none of them should have order=asc
          expect(last_response.body).to include("order=desc")
          expect(last_response.body).not_to include("order=asc")
        end

        it "does not show the sort direction arrow by default" do
          manager = add_test_manager_to_db
          get_as_employee(manager, "/manager/products/beans")
          
          expect(last_response.body).not_to include("▼")
          expect(last_response.body).not_to include("▲")
        end

        context "when sorted already" do
          context "pressing on the same column header reverse the sorting order" do
            it "has descending order now" do
              manager = add_test_manager_to_db
              get_as_employee(manager, "/manager/products/beans",
                { "sort" => "stock_level", "order" => "desc" }
              )

              #test the link in Stock table header
              expect(last_response.body).to include("sort=stock_level&order=asc")
            end

            it "has ascending order now" do
              manager = add_test_manager_to_db
              get_as_employee(
                manager,
                "/manager/products/beans",
                { "sort" => "stock_level", "order" => "asc" }
              )

              #test the link in Stock table header
              expect(last_response.body).to include("sort=stock_level&order=desc")
            end
          end

          it "pressing any other column header will sort in descending order" do
            manager = add_test_manager_to_db
            get_as_employee(
              manager,
              "/manager/products/beans",
              { "sort" => "stock_level", "order" => "desc" }
            )
            #test the link of all other table headers except Stock
            expect(last_response.body).to include("sort=product_id&order=desc")
            expect(last_response.body).to include("sort=name&order=desc")
            expect(last_response.body).to include("sort=price&order=desc")
            expect(last_response.body).to include("sort=cost&order=desc")
            expect(last_response.body).to include("sort=availability&order=desc")
          end

          context "shows the correct sort direction symbol on the right column header" do
            it "shows ▼ when in descending order" do
              manager = add_test_manager_to_db
              get_as_employee(
                manager,
                "/manager/products/beans",
                { "sort" => "stock_level", "order" => "desc" }
              )

              expect(last_response.body).to include("Stock ▼")
            end

            it "shows ▲ when in ascending order" do
              manager = add_test_manager_to_db
              get_as_employee(
                manager,
                "/manager/products/beans",
                { "sort" => "stock_level", "order" => "asc" }
              )

              expect(last_response.body).to include("Stock ▲")
            end
          end

          it "keeps searching filters when sorting" do
            manager = add_test_manager_to_db
            get_as_employee(
              manager,
              "/manager/products/beans",
              { "column_to_search" => "name", "search_input" => "Special Name" }
            )

            #6 sort headers plus the two add buttons therefore count 8
            expect(last_response.body.scan("column_to_search=name").length).to eq(8)
            expect(last_response.body.scan("search_input=Special+Name").length).to eq(8)
          end
        end
      end
      context "searching" do
        it "searches by Product ID" do
          arabic, ethiopian, brazilian = add_test_search_beans_to_db

          manager = add_test_manager_to_db
          get_as_employee(
            manager,
            "/manager/products/beans",
            { "column_to_search" => "product_id", "search_input" => arabic[:bean].product_id.to_s }
          )

          #Only shows the name of bean with the product_id 1
          expect(last_response.body).to include(arabic[:bean].name)
          expect(last_response.body).not_to include(ethiopian[:bean].name)
          expect(last_response.body).not_to include(brazilian[:bean].name)
        end

        it "searches by name" do
          arabic, ethiopian, brazilian = add_test_search_beans_to_db

          manager = add_test_manager_to_db
          get_as_employee(
            manager,
            "/manager/products/beans",
            { "column_to_search" => "name", "search_input" => "Arabic" }
          )

          #Only shows the name of bean with the string "Arabic"
          expect(last_response.body).to include(arabic[:bean].name)
          expect(last_response.body).not_to include(ethiopian[:bean].name)
          expect(last_response.body).not_to include(brazilian[:bean].name)
        end

        it "searches roast level by name" do
          arabic, ethiopian, brazilian = add_test_search_beans_to_db

          manager = add_test_manager_to_db
          get_as_employee(
            manager,
            "/manager/products/beans",
            { "column_to_search" => "name", "search_input" => "Light" }
          )

          #Only shows the name of bean with the string "Light"
          expect(last_response.body).not_to include(arabic[:bean].name)
          expect(last_response.body).to include(ethiopian[:bean].name)
          expect(last_response.body).not_to include(brazilian[:bean].name)
        end

        it "can search by name with partial strings" do
          arabic, ethiopian, brazilian = add_test_search_beans_to_db

          manager = add_test_manager_to_db
          get_as_employee(
            manager,
            "/manager/products/beans",
            { "column_to_search" => "name", "search_input" => "ra" }
          )

          #Only shows the name of all beans with the term "ra" in them
          #show the search accepts substrings of beans names
          expect(last_response.body).to include(arabic[:bean].name)
          expect(last_response.body).not_to include(ethiopian[:bean].name)
          expect(last_response.body).to include(brazilian[:bean].name)
        end

        it "searches name case insensitively" do
          arabic, ethiopian, brazilian = add_test_search_beans_to_db

          manager = add_test_manager_to_db
          get_as_employee(
            manager,
            "/manager/products/beans",
            { "column_to_search" => "name", "search_input" => "aRaBic" }
          )

          #Only shows the name of all beans with the term "aRaBic" in them
          #shows the search is case insensitive
          expect(last_response.body).to include(arabic[:bean].name)
          expect(last_response.body).not_to include(ethiopian[:bean].name)
          expect(last_response.body).not_to include(brazilian[:bean].name)
        end

        it "searches available products" do
          arabic, ethiopian, brazilian = add_test_search_beans_to_db

          manager = add_test_manager_to_db
          get_as_employee(
            manager,
            "/manager/products/beans",
            { "column_to_search" => "availability", "search_input" => "yes" }
          )

          #Only shows the name of all beans with availability 1
          expect(last_response.body).to include(arabic[:bean].name)
          expect(last_response.body).to include(ethiopian[:bean].name)
          expect(last_response.body).not_to include(brazilian[:bean].name)
        end

        it "searches unavailable products" do
          arabic, ethiopian, brazilian = add_test_search_beans_to_db

          manager = add_test_manager_to_db
          get_as_employee(
            manager,
            "/manager/products/beans",
            { "column_to_search" => "availability", "search_input" => "no" }
          )

          #Only shows the name of all beans with availability 0
          expect(last_response.body).not_to include(arabic[:bean].name)
          expect(last_response.body).not_to include(ethiopian[:bean].name)
          expect(last_response.body).to include(brazilian[:bean].name)
        end

        it "searches availability case insensitively" do
          arabic, ethiopian, brazilian = add_test_search_beans_to_db

          manager = add_test_manager_to_db
          get_as_employee(
            manager,
            "/manager/products/beans",
            { "column_to_search" => "availability", "search_input" => "YeS" }
          )

          #Only shows the name of beans with availability 1
          #shows the search is case insensitive
          expect(last_response.body).to include(arabic[:bean].name)
          expect(last_response.body).to include(ethiopian[:bean].name)
          expect(last_response.body).not_to include(brazilian[:bean].name)
        end

        it "searches availability with partial strings" do
          arabic, ethiopian, brazilian = add_test_search_beans_to_db

          manager = add_test_manager_to_db
          get_as_employee(
            manager,
            "/manager/products/beans",
            { "column_to_search" => "availability", "search_input" => "y" }
          )

          #Only shows the name of beans with availability 1
          #shows the search accepts substring of yes/no
          expect(last_response.body).to include(arabic[:bean].name)
          expect(last_response.body).to include(ethiopian[:bean].name)
          expect(last_response.body).not_to include(brazilian[:bean].name)
        end

        it "returns no result for invalid availability input" do
          arabic, ethiopian, brazilian = add_test_search_beans_to_db

          manager = add_test_manager_to_db
          get_as_employee(
            manager,
            "/manager/products/beans",
            { "column_to_search" => "availability", "search_input" => "error" }
          )

          expect(last_response.body).not_to include(arabic[:bean].name)
          expect(last_response.body).not_to include(ethiopian[:bean].name)
          expect(last_response.body).not_to include(brazilian[:bean].name)
        end

        it "shows all entries for invalid column_to_search input" do
          arabic, ethiopian, brazilian = add_test_search_beans_to_db
          
          manager = add_test_manager_to_db
          get_as_employee(
            manager,
            "/manager/products/beans",
            { "column_to_search" => "error", "search_input" => "Something does not exist" }
          )

          #Everything shows in the table when column_to_search input is not
          #in the whitelist
          expect(last_response.body).to include(arabic[:bean].name)
          expect(last_response.body).to include(ethiopian[:bean].name)
          expect(last_response.body).to include(brazilian[:bean].name)
        end

        it "keeps the search input after search" do
          manager = add_test_manager_to_db
          get_as_employee(
            manager,
            "/manager/products/beans",
            { "column_to_search" => "name", "search_input" => "Testing keep input" }
          )

          #The search keeps user's input in the search bar
          expect(last_response.body).to include("Testing keep input")
        end

        it "keeps the sorting order when searching" do
          arabic_medium, ethiopian, brazilian = add_test_search_beans_to_db
          bean = add_test_product_to_db("beans", "Arabic Dark", 34, 1, 2, 4)
          arabic_dark = {
            bean: bean,
            variant: add_test_product_variant_to_db(bean.product_id, 1, 1, 45, 22)
          }

          manager = add_test_manager_to_db
          get_as_employee(manager, "/manager/products/beans",
            { 
              "sort" => "name", "order" => "desc",
              "column_to_search" => "name", "search_input" => "Dark"
            }
          )

          body = last_response.body
          #Hidden input is used to save sorting order for search
          expect(body).to include('form id="search_bar"')
          expect(body).to include('type="hidden" name="sort" value="name"')
          expect(body).to include('type="hidden" name="order" value="desc"')
          
          #Test the beans names' order and the filtering of the search
          expect(last_response.body).not_to include(arabic_medium[:bean].name)
          expect(last_response.body).to include(arabic_dark[:bean].name)
          expect(last_response.body).not_to include(ethiopian[:bean].name)
          expect(last_response.body).to include(brazilian[:bean].name)
          expect(body.index(brazilian[:bean].name)).to be < body.index(arabic_dark[:bean].name)
        end
      end
    end
  end
end