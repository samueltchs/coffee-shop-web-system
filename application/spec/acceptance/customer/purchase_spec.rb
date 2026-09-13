RSpec.describe "Shop System" do
    before do
        setup_shop()
    end

    describe "Searching for products" do
        it "can access product search page" do
            visit("/customer/dashboard")
            click_link "search"
            expect(page).to have_current_path("/shop/search")
        end

        context "when searching for a bean" do
            before do
                search_for_test_bean()
            end

            it "displays the test bean" do
                expect(page).to have_content('Test Beans')
            end

            it "does not display the test drink" do
                expect(page).not_to have_content('Latte')
            end

            it "can click bean to reach product page" do
                click_link "product-1" # this is the test bean's id
                expect(page).to have_current_path("/shop/product?product_id=1")
            end
        end
    end

    describe "Adding products to basket" do
        context "when logged in" do
            before do 
                login_as_customer(log_in_test_customer)
            end

            context "when on the search page" do
                before do 
                    search_for_test_bean()
                end

                it "has add to basket button" do
                    expect(page).to have_content("Add to Basket")
                end

                context "when pressing add to basket" do
                    before do
                        click_button "Add to Basket"
                    end

                    it "redirects to basket" do
                        expect(page).to have_current_path("/shop/basket")
                    end
                end
            end

            context "when on the gallery page" do
                before do
                    visit("/shop")
                end
                
                it "has add to basket button" do
                    expect(page).to have_content("Add to Basket")
                end
            end
            
            context "when on the product page" do
                context "when product is a bean" do
                    before do
                        visit("/shop/product/product_id=1")
                    end

                    it "has add to basket button" do
                        expect(page).to have_content("Add to Basket")
                        expect(page).not_to have_content("Log in to add to basket") # when not logged in, this text is shown
                    end

                    context "when pressing add to basket" do
                        before do
                            click_button "Add to Basket"
                        end

                        it "redirects to basket" do
                            expect(page).to have_current_path("/shop/basket")
                        end
                    end
                end
            end
        end
    end

    describe "Viewing the basket" do
        context "when logged in" do
            before do
                login_as_customer(log_in_test_customer)
            end

            context "after adding test beans to basket" do
                before do 
                    visit("/")
                end
            end
        end

        context "when not logged in" do
            it "redirects to login page" do
                expect(page).to have_current_path("/login")
            end
        end
    end
end