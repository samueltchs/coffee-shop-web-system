RSpec.describe "customer shop controller" do
    before do
        setup_shop()
    end

    describe "GET /shop" do
        context "when logged in" do 
            before do
                get_as_customer_logged_in("/shop")
            end

            it "response is 200 (ok)" do
                expect(last_response).to be_ok
            end

            it "contains a link to at least one product" do
                expect(last_response.body).to include('href=/shop/product?product_id=')
            end

            it "contains an add to basket button" do
                expect(last_response.body).to include('action="/shop/add-to-basket"')
            end
        end

        context "when not logged in" do
            before do 
                get_as_customer_not_logged_in("/shop")
            end
            
            it "response is 200 (ok)" do
                expect(last_response).to be_ok
            end

            it "contains a link to at least one product" do
                expect(last_response.body).to include('href=/shop/product?product_id=')
            end

            # should only be able to add to basket if logged in
            it "does not contain any add to basket buttons" do
                expect(last_response.body).not_to include('action="/shop/add-to-basket"')
            end
        end
    end

    describe "GET /shop/search" do
        context "with an empty search field" do
            context "when logged in" do 
                before do
                    get_as_customer_logged_in("/shop")
                end

                it "response is 200 (ok)" do
                    expect(last_response).to be_ok
                end

                it "contains a link to at least one product" do
                    expect(last_response.body).to include('href=/shop/product?product_id=')
                end

                it "contains an add to basket button" do
                    expect(last_response.body).to include('action="/shop/add-to-basket"')
                end
            end

            context "when not logged in" do
                before do 
                    get_as_customer_not_logged_in("/shop")
                end
                
                it "response is 200 (ok)" do
                    expect(last_response).to be_ok
                end

                it "contains a link to at least one product" do
                    expect(last_response.body).to include('href=/shop/product?product_id=')
                end

                # should only be able to add to basket if logged in
                it "does not contain any add to basket buttons" do
                    expect(last_response.body).not_to include('action="/shop/add-to-basket"')
                end
            end
        end
    
        # this isn't to check the buttons to the pages are correct, since this is already done,
        # but rather to check the searching works to find relevant results
        context "when searching for 'bean'" do
            before do
                get_as_customer_logged_in("/shop/search", {"search-term": "bean"})
            end

            it "shows the test beans" do
                # this checks that the page contains a card with title "Test Beans"
                expect(last_response.body).to include('class="bean-title">Test Beans')
            end

            it "does not show the test drink" do
                expect(last_response.body).not_to include('class="bean-title">Latte')
            end
        end
    end

    describe "GET /shop/product" do
        context "when logged in" do
            context "when product is a bean" do # works using the bean inputted by setup_shop, which is id 1, Test Beans
                before do
                    get_as_customer_logged_in("/shop/product", {"product_id": "1"})
                end

                it "has title" do
                    expect(last_response.body).to include('product-page-name">Test Beans')
                end

                it "has price" do
                    expect(last_response.body).to include('£22.99')
                end

                it "has add to basket button" do
                    expect(last_response.body).to include('action="/shop/add-to-basket"')
                end

                it "has origin" do
                    expect(last_response.body).to include("Arabic")
                end

                it "has roast level" do
                    expect(last_response.body).to include("Light")
                end
            end

            context "when product is not favourited" do
                before do
                    unfavourite_all()
                    get_as_customer_logged_in("/shop/product", {"product_id": "1"})
                end
                
                it "has add to favourites button" do
                    expect(last_response.body).to include("favourites/add")
                end
            end

            context "when product is favourited" do
                before do
                    favourite_test_bean()
                    get_as_customer_logged_in("/shop/product", {"product_id": "1"})
                end
                
                it "has remove from favourites button" do
                    expect(last_response.body).to include("favourites/remove")
                end
            end

            context "when product is a drink" do # works using the drink inputted by setup_shop, which is id 2, Latte
                before do
                    get_as_customer_logged_in("/shop/product", {"product_id": "2"})
                end

                it "has title" do
                    expect(last_response.body).to include('product-page-name">Latte')
                end

                it "has price" do
                    expect(last_response.body).to include('product-page-price">£3.2')
                end

                it "has add to basket button" do
                    expect(last_response.body).to include('action="/shop/add-to-basket"')
                end

                it "has milk selector" do
                    expect(last_response.body).to include('<select name="milk" id="milk">')
                end

                it "has size selector" do
                    expect(last_response.body).to include('<select name="size" id="size">')
                end
            end
        end

        context "when not logged in" do
            before do
                get_as_customer_not_logged_in("/shop/product", {"product_id": "1"})
            end

            # loads
            it "response is 200 (ok)" do
                expect(last_response).to be_ok
            end

            it "doesn't have add to basket button" do
                expect(last_response.body).not_to include('action="/shop/add-to-basket"')
            end
        end
    end
end
