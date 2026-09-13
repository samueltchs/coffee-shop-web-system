RSpec.describe "Adjust loyalty discounts" do
  context "given logged in as manager" do
    before do
      #login as manager
      manager = add_test_manager_to_db
      login_as_employee(manager)
    end

    context "Adding a new discount" do
      it "shows the new discount on the Personalized Discounts page" do
        #go to the page showing all current campaigns
        click_link "Personalized Discounts"

        #goes to the add discount form
        click_link "New Campaign"

        #add the discount
        fill_in "Discount Code:", with: "COFFEE20"
        fill_in "Campaign Name:", with: "Coffee Lovers Deal"
        fill_in "Percentage off:", with: "20"
        fill_in "Code Expiry Date:", with: (Date.today + 60).strftime("%Y-%m-%d")
        choose "Enable"
        fill_in "From:", with: (Date.today - 120).strftime("%Y-%m-%d")
        fill_in "To:", with: (Date.today - 30).strftime("%Y-%m-%d")
        select "Drinks Only", from: "Purchase Type:"
        select "Amount of Purchase", from: "Rule:"
        fill_in "Minimum Amount:", with: "5"
        click_on "Submit"

        #check the new discount is in current campaigns
        expect(page).to have_content "COFFEE20"
      end
    end
    context "Adjusting an existing discount" do
      before do
        #existing discount added
        add_test_discount_code_to_db(
          discount_code: "COFFEE20", campaign_name: "Coffee Lovers Deal", 
          percentage_off: "20", eligible_type: "2", eligible_rule: "2", 
          eligible_min: "5.00", valid_purchase_date_from: "2026-03-01", 
          valid_purchase_date_to: "2026-06-30", code_expiry_date: "2026-08-31", 
          is_active: "1"
        )

        #go to the discount details page of the existing discount
        click_link "Personalized Discounts"
        click_link "details"
      end

      context "Adjust the discount eligibility rule" do
        it "updates the eligibility rule of the loyalty discount" do
          #check eligible rule before update
          expect(page).to have_content "Eligibility Rule: Quantity of Products"
          
          #go into update discount form
          click_link "Edit"
          select "Amount of Purchase", from: "Rule:"
          click_on "Save"

          #check after update
          expect(page).to have_content "Eligibility Rule: Amount of Purchase"
          expect(page).not_to have_content "Eligibility Rule: Quantity of Products"
        end
      end

      context "Adjust the discount eligibility product type" do
        it "updates the eligibility product type of the loyalty discount" do
          #check eligible product type before update
          expect(page).to have_content "Purchase Type: Drinks Only"
         
          #go into update discount form
          click_link "Edit"
          select "Both", from: "Purchase Type:"
          click_on "Save"

          #check after update
          expect(page).to have_content "Purchase Type: Both"
          expect(page).not_to have_content "Purchase Type: Drinks Only"
        end
      end
      
      context "Adjust the timeframe for eligible purchases" do
        it "updates the timeframe for eligible purchases of the loyalty discount" do
          #check timeframe for eligible purchases before update
          expect(page).to have_content "From: 2026-03-01"
          expect(page).to have_content "To: 2026-06-30"
          
          #go into update discount form
          click_link "Edit"
          fill_in "From:", with: "2026-04-04"
          fill_in "To:", with: "2026-07-20"
          click_on "Save"

          #check after update
          expect(page).to have_content "From: 2026-04-04"
          expect(page).to have_content "To: 2026-07-20"
          expect(page).not_to have_content "From: 2026-03-01"
          expect(page).not_to have_content "To: 2026-06-30"
        end
      end
    end
  end




end