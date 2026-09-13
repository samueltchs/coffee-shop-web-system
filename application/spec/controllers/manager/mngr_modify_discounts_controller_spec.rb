RSpec.describe "manager modify discounts controller" do
  describe "GET /manager/create-discount" do
    context "when not logged in" do
      it "redirects to employee login page" do
        get "/manager/create-discount"

        expect(last_response).to be_redirect
        expect(last_response.location).to include("/employee-login-page?error")
      end
    end

    context "when logged in but not as manager" do
      it "redirects to the appropriate page" do
        barista = add_test_barista_to_db
        get_as_employee(barista, "/manager/create-discount")

        expect(last_response).to be_redirect
        expect(last_response.location).to end_with("/barista/main")
      end
    end

    context "when logged in as manager" do
      before do
        @manager = add_test_manager_to_db
        add_default_discount_options_to_db
      end

      it "loads create discount page" do
        get_as_employee(@manager, "/manager/create-discount")

        expect(last_response).to be_ok
        expect(last_response.body).to include("Create New Discount")
      end

      it "shows the discount form fields" do
        get_as_employee(@manager, "/manager/create-discount")

        expect(last_response.body).to include('form method="post" action="/manager/create-discount"')
        expect(last_response.body).to include("Details:")
        expect(last_response.body).to include('name="code"')
        expect(last_response.body).to include('name="name"')
        expect(last_response.body).to include('name="percentage"')
        expect(last_response.body).to include('name="expiry"')
        expect(last_response.body).to include('name="status"')

        expect(last_response.body).to include("Eligibility:")
        expect(last_response.body).to include("Purchase Timeframe")
        expect(last_response.body).to include('name="from"')
        expect(last_response.body).to include('name="to"')
        expect(last_response.body).to include('name="pur_type"')
        expect(last_response.body).to include('name="elig_rule"')
        expect(last_response.body).to include('name="min_amount"')
      end

      it "shows all the default Eligible Purchase Type options" do
        get_as_employee(@manager, "/manager/create-discount")

        EligiblePurchaseType.all.each do |type|
          expect(last_response.body).to include(type.type)
        end
      end

      it "shows all the default Eligible Rules options" do
        get_as_employee(@manager, "/manager/create-discount")

        EligibleRule.all.each do |rule|
          expect(last_response.body).to include(rule.rule)
        end
      end

      it "has cancel button to current campaigns page when entered from current campaigns" do
        get_as_employee(@manager, "/manager/create-discount")

        expect(last_response.body).to include("href='/manager/discounts'")
        expect(last_response.body).to include("Cancel")
      end

      it "has cancel button to past campaigns page when entered from past campaigns" do
        get_as_employee(@manager, "/manager/create-discount", { "from_past" => "yes" })

        expect(last_response.body).to include("href='/manager/discounts/past'")
        expect(last_response.body).to include("Cancel")
      end

      it "shows submit button" do
        get_as_employee(@manager, "/manager/create-discount")

        expect(last_response.body).to include('type="submit">Submit<')
      end
    end
  end

  describe "POST /manager/create-discount" do
    context "when not logged in" do
      it "redirects to employee login page" do
        post "/manager/create-discount"

        expect(last_response).to be_redirect
        expect(last_response.location).to include("/employee-login-page?error")
      end
    end

    context "when logged in but not as manager" do
      it "redirects to the appropriate page" do
        barista = add_test_barista_to_db
        post_as_employee(barista, "/manager/create-discount")

        expect(last_response).to be_redirect
        expect(last_response.location).to end_with("/barista/main")
      end
    end

    context "when logged in as manager" do
      before do
        @manager = add_test_manager_to_db
        add_default_discount_options_to_db
      end

      context "when inputs are valid" do
        it "creates a new discount code in database" do
          params = test_discount_params

          expect {
            post_as_employee(@manager, "/manager/create-discount", params)
          }.to change(DiscountCode, :count).by(1)
        end

        it "saves the correct discount details" do
          params = test_discount_params
          post_as_employee(@manager, "/manager/create-discount", params)

          discount = DiscountCode.last
          expect(discount.discount_code).to eq(params[:code])
          expect(discount.campaign_name).to eq(params[:name])
          expect(discount.percentage_off).to eq(params[:percentage].to_i)
          expect(discount.eligible_type).to eq(params[:pur_type].to_i)
          expect(discount.eligible_rule).to eq(params[:elig_rule].to_i)
          expect(discount.eligible_min).to eq(params[:min_amount].to_f)
          expect(discount.valid_purchase_date_from).to eq(params[:from])
          expect(discount.valid_purchase_date_to).to eq(params[:to])
          expect(discount.code_expiry_date).to eq(params[:expiry])
          expect(discount.is_active).to eq(params[:status].to_i)
        end

        it "distribute to eligible customers when successfully created" do
          add_test_discount_eligible_customer_and_order
          params = test_discount_params
          post_as_employee(@manager, "/manager/create-discount", params)
          
          discount = DiscountCode.last
          eligible_customer = discount.get_all_eligible_customers.first
          redemption = DiscountRedemption.where(
            loyalty_number: eligible_customer.loyalty_number,
            code: discount.discount_code
          ).first

          expect(eligible_customer.name).to eq("Mikel Merino")
          #check the record exists -> means it is distributed correctly
          expect(redemption.is_redeemed).to eq(0)
        end

        context "if entered create discount through current campaigns page" do
          it "redirects to current campaigns page on successful create" do
            params = test_discount_params
            post_as_employee(@manager, "/manager/create-discount", params)

            expect(last_response).to be_redirect
            expect(last_response.location).to end_with("/manager/discounts")
          end
        end

        context "if entered create discount through past campaigns page" do
          it "redirects to past campaigns page on successful create" do
            params = test_discount_params
            post_as_employee(
              @manager, "/manager/create-discount",
              params.merge("from_past" => "yes")
            )

            expect(last_response).to be_redirect
            expect(last_response.location).to end_with("/manager/discounts/past")
          end
        end
      end

      context "when inputs are invalid" do
        it "does not create a new discount code" do
          params = test_discount_params(code: "")

          expect {
            post_as_employee(@manager, "/manager/create-discount", params)
          }.not_to change(DiscountCode, :count)
        end

        it "does not distribute discount to eligible customers when inputs are invalid" do
          add_test_discount_eligible_customer_and_order
          params = test_discount_params(code: "")

          expect {
            post_as_employee(@manager, "/manager/create-discount", params)
          }.not_to change(DiscountRedemption, :count)
        end

        it "re-renders create discount page" do
          params = test_discount_params(code: "")
          post_as_employee(@manager, "/manager/create-discount", params)

          expect(last_response).to be_ok
          expect(last_response.body).to include("Create New Discount")
        end

        it "keeps previously entered values in form" do
          params = test_discount_params(code: "", name: "Retain Inputs")
          post_as_employee(@manager, "/manager/create-discount", params)

          expect(last_response.body).to include('value="Retain Inputs"')
        end

        it "keeps from_past in the form when re-render if from_past is yes" do
          params = test_discount_params(code: "")
          post_as_employee(@manager, "/manager/create-discount", params.merge("from_past" => "yes"))

          expect(last_response.body).to include(
            'type="hidden" name="from_past" value="yes"'
          )
        end

        it "shows cancel button to past campaigns page when from_past is yes" do
          params = test_discount_params(code: "")
          post_as_employee(@manager, "/manager/create-discount", params.merge("from_past" => "yes"))

          expect(last_response.body).to include("href='/manager/discounts/past'")
        end

        context "When inputs are empty" do
          it "shows error message for empty Discount Code" do
            params = test_discount_params(code: "")
            post_as_employee(@manager, "/manager/create-discount", params)

            expect(last_response.body).to include('error_msg">Discount code cannot be empty<')
          end

          it "shows error message for empty Campaign Name" do
            params = test_discount_params(name: "")
            post_as_employee(@manager, "/manager/create-discount", params)

            expect(last_response.body).to include('error_msg">Campaign name cannot be empty<')
          end

          it "shows error message for empty Percentage off" do
            params = test_discount_params(percentage: "")
            post_as_employee(@manager, "/manager/create-discount", params)

            expect(last_response.body).to include('error_msg">Percentage off cannot be empty<')
          end

          it "shows error message for empty Code Expiry Date:" do
            params = test_discount_params(expiry: "")
            post_as_employee(@manager, "/manager/create-discount", params)

            expect(last_response.body).to include('error_msg">Expiry date cannot be empty<')
          end

          it "shows error message for empty Status" do
            params = test_discount_params(status: "")
            post_as_employee(@manager, "/manager/create-discount", params)

            expect(last_response.body).to include('error_msg">Status cannot be empty<')
          end

          it "shows error message for empty From date" do
            params = test_discount_params(from: "")
            post_as_employee(@manager, "/manager/create-discount", params)

            expect(last_response.body).to include('error_msg">Daterange cannot be empty<')
          end

          it "shows error message for empty To date" do
            params = test_discount_params(to: "")
            post_as_employee(@manager, "/manager/create-discount", params)

            expect(last_response.body).to include('error_msg">Daterange cannot be empty<')
          end

          it "shows error message for empty Purchase type" do
            params = test_discount_params(pur_type: "")
            post_as_employee(@manager, "/manager/create-discount", params)

            expect(last_response.body).to include('error_msg">Purchase type cannot be empty<')
          end
          
          it "shows error message for empty Eligible rule" do
            params = test_discount_params(elig_rule: "")
            post_as_employee(@manager, "/manager/create-discount", params)

            expect(last_response.body).to include('error_msg">Eligible rule cannot be empty<')
          end

          it "shows error message for empty Minimum amount" do
            params = test_discount_params(min_amount: "")
            post_as_employee(@manager, "/manager/create-discount", params)

            expect(last_response.body).to include('error_msg">Minimum amount cannot be empty<')
          end
        end

        it "shows error message when inputted code already exists" do
          add_test_discount_code_to_db(discount_code: "EXISTS")
          params = test_discount_params(code: "EXISTS")
          post_as_employee(@manager, "/manager/create-discount", params)

          expect(last_response.body).to include('error_msg">Discount code already exists<')
        end

        it "shows error message when inputted code consists of non letters or non numbers" do
          params = test_discount_params(code: "$#@!CODE")
          post_as_employee(@manager, "/manager/create-discount", params)

          expect(last_response.body).to include('error_msg">Only letters and numbers allowed<')
        end

        it "shows error message when inputted code is not between 4-12 characters" do
          params = test_discount_params(code: "1234567890123")
          post_as_employee(@manager, "/manager/create-discount", params)

          expect(last_response.body).to include('error_msg">Discount code must be between 4-12 characters<')
        end

        it "shows error message when inputted campaign name is longer than 40 characters" do
          params = test_discount_params(name: "very very very very very very very very very long")
          post_as_employee(@manager, "/manager/create-discount", params)

          expect(last_response.body).to include('error_msg">Maximum 40 characters<')
        end

        it "shows error message when percentage is not between 1 and 100" do
          params = test_discount_params(percentage: "0")
          post_as_employee(@manager, "/manager/create-discount", params)

          expect(last_response.body).to include('error_msg">Percentage must be between 1 and 100<')
        end

        it "shows error message when expiry date is in the past" do
          params = test_discount_params(expiry: "2020-01-01")
          post_as_employee(@manager, "/manager/create-discount", params)

          expect(last_response.body).to include('error_msg">Expiry date must be in the future<')
        end

        it "shows error message when start date is later than end date" do
          params = test_discount_params(from: "2026-07-01", to: "2026-06-01")
          post_as_employee(@manager, "/manager/create-discount", params)

          expect(last_response.body).to include(
            'error_msg">Start date cannot be later than end date<'
          )
        end

        it "shows error message when minimum amount is less than 0" do
          params = test_discount_params(min_amount: "-1")
          post_as_employee(@manager, "/manager/create-discount", params)

          expect(last_response.body).to include('error_msg">Minimum amount has to be at least 0<')
        end
      end
    end
  end

  describe "GET /manager/update-discount" do
    context "when not logged in" do
      it "redirects to employee login page" do
        get "/manager/update-discount"

        expect(last_response).to be_redirect
        expect(last_response.location).to include("/employee-login-page?error")
      end
    end

    context "when logged in but not as manager" do
      it "redirects to the appropriate page" do
        barista = add_test_barista_to_db
        get_as_employee(barista, "/manager/update-discount")

        expect(last_response).to be_redirect
        expect(last_response.location).to end_with("/barista/main")
      end
    end

    context "when logged in as manager" do
      before do
        @manager = add_test_manager_to_db
        add_default_discount_options_to_db
        @discount = add_test_discount_code_to_db
      end

      it "loads update discount page" do
        get_as_employee(
          @manager, "/manager/update-discount", 
          { "viewcode" => @discount.discount_code }
        )

        expect(last_response).to be_ok
        expect(last_response.body).to include("Update Discount")
        expect(last_response.body).to include('form method="post" action="/manager/update-discount"')
        expect(last_response.body).to include("name=\"viewcode\" value=\"#{@discount.discount_code}\"")
        expect(last_response.body).to include('name="action" value="update"')
      end

      it "redirects to current campaigns page when discount code does not exist" do
        get_as_employee(@manager, "/manager/update-discount", { "viewcode" => "FAKECODE" })

        expect(last_response).to be_redirect
        expect(last_response.location).to end_with("/manager/discounts")
      end

      it "shows existing discount details in the form" do
        get_as_employee(
          @manager, "/manager/update-discount", 
          { "viewcode" => @discount.discount_code }
        )

        expect(last_response.body).to include(@discount.discount_code)
        expect(last_response.body).to include(@discount.campaign_name)
        expect(last_response.body).to include(@discount.percentage_off.to_s)
        expect(last_response.body).to include(@discount.code_expiry_date)

        #check status is displayed
        expect(last_response.body).to match(
          /id="enable" name="status" value="1" required\s+checked/
        ) if @discount.is_active == 1
        expect(last_response.body).to match(
          /id="disable" name="status" value="0"\s+checked/
        ) if @discount.is_active == 0
        
        expect(last_response.body).to include(@discount.valid_purchase_date_from)
        expect(last_response.body).to include(@discount.valid_purchase_date_to)
        
        #check whether existing eligible type is selected
        EligiblePurchaseType.all.each do |type|
          expect(last_response.body).to match(
            /selected\s+>#{type.type}<\/option>/
          ) if @discount.eligible_type == type.id
        end

        #check whether existing eligible rule is selected
        EligibleRule.all.each do |rule|
          expect(last_response.body).to match(
            /selected\s+>#{rule.rule}<\/option>/
          ) if @discount.eligible_rule == rule.id
        end

        expect(last_response.body).to include(@discount.eligible_min.to_s)
      end

      it "hides the discount code submitting to the form and shows the code as <span>" do
        get_as_employee(
          @manager, "/manager/update-discount", 
          { "viewcode" => @discount.discount_code }
        )

        expect(last_response.body).to include('type="hidden" name="code"')
        expect(last_response.body).to include(
          "<span class=\"row_end\">#{@discount.discount_code}</span>"
        )
      end

      context "when entered like current campaigns -> discount details -> update discount" do
        it "has a cancel button back to current discounts details page" do
          get_as_employee(
            @manager, "/manager/update-discount", 
            { "viewcode" => @discount.discount_code }
          )

          expect(last_response.body).to include(
            "href='/manager/discounts/details?viewcode=#{@discount.discount_code}'"
          )
        end
      end

      context "when entered like past campaigns -> discount details -> update discount" do
        it "keeps from_past in hidden input" do
          get_as_employee(
            @manager, "/manager/update-discount", 
            { "viewcode" => @discount.discount_code, "from_past" => "yes" }
          )

          expect(last_response.body).to include('type="hidden" name="from_past" value="yes"')
        end

        it "has a cancel button back to past discount details page" do
          get_as_employee(
            @manager, "/manager/update-discount", 
            { "viewcode" => @discount.discount_code, "from_past" => "yes" }
          )

          expect(last_response.body).to include(
            "href='/manager/discounts/details?viewcode=#{@discount.discount_code}&from_past=yes'"
          )
        end
      end

      it "shows the save button" do
        get_as_employee(
          @manager, "/manager/update-discount", 
          { "viewcode" => @discount.discount_code }
        )

        expect(last_response.body).to include('type="submit">Save<')
      end
    end
  end

  describe "POST /manager/update-discount" do
    context "when not logged in" do
      it "redirects to employee login page" do
        post "/manager/update-discount"

        expect(last_response).to be_redirect
        expect(last_response.location).to include("/employee-login-page?error")
      end
    end

    context "when logged in but not as manager" do
      it "redirects to the appropriate page" do
        barista = add_test_barista_to_db
        post_as_employee(barista, "/manager/update-discount")

        expect(last_response).to be_redirect
        expect(last_response.location).to end_with("/barista/main")
      end
    end

    context "when logged in as manager" do
      before do
        @manager = add_test_manager_to_db
        add_default_discount_options_to_db
        @discount = add_test_discount_code_to_db(
          eligible_rule: "1", eligible_min: "15"
        )
      end

      context "when inputs are valid" do
        it "updates the discount code details" do
          params = test_discount_params(
            code: @discount.discount_code, 
            name: "Updated Campaign", 
            percentage: "30", 
            action: "update", 
            viewcode: @discount.discount_code
          )
          post_as_employee(@manager, "/manager/update-discount", params)

          updated_discount = DiscountCode[@discount.discount_code]

          expect(updated_discount.campaign_name).to eq("Updated Campaign")
          expect(updated_discount.percentage_off).to eq(30)
        end

        it "distributes to new eligible customers when successfully updated" do
          #Customer 1 loyalty_number = 1, first_name = "Mikel", last_name = "Merino"
          #with order 1 (5 small latte) net_price £19.20
          #Customer 2 loyalty_number = 2, first_name = "Discount", last_name = "Tester"
          #with order 2 (10 small latte) net_price £32.00
          add_test_update_discount_eligible_customer_and_order

          #original discount eligibility, Amount of Drinks Purchase >= £25.00 
          discount = add_test_discount_code_to_db(
            discount_code:"TEST", eligible_rule: "1", eligible_min: "25"
          )

          #distribute for the @discount "COFFEE20" in before do
          #and the original "TEST" to create the comparison
          DiscountRedemption.distribute_to_eligible_customers

          #update to eligibility, Amount of Drinks Purchase >= £15.00
          #Mikel Merino will be eligible for the discount too after update
          params = test_discount_params(
            code: discount.discount_code, 
            action: "update",
            elig_rule: "1",
            min_amount: "15",
            viewcode: discount.discount_code
          )

          #Mikel Merino is added
          expect {
            post_as_employee(@manager, "/manager/update-discount", params)
          }.to change(DiscountRedemption, :count).by(1)

          #now the two customers both eligible for TEST
          redemption = DiscountRedemption.where(code: "TEST")
          expect(redemption.count).to eq(2)
        end

        context "when entered like current campaigns -> discount details -> update discount" do
          it "redirects to current discount details page after successful update" do
            params = test_discount_params(
              code: @discount.discount_code, 
              action: "update", 
              viewcode: @discount.discount_code
            )
            post_as_employee(@manager, "/manager/update-discount", params)

            expect(last_response).to be_redirect
            expect(last_response.location).to end_with("/manager/discounts/details?viewcode=#{@discount.discount_code}")
          end
        end

        context "when entered like past campaigns -> discount details -> update discount" do
          it "redirects to past discount details page after successful update" do
            params = test_discount_params(code: @discount.discount_code, action: "update", viewcode: @discount.discount_code)
            post_as_employee(@manager, "/manager/update-discount", params.merge("from_past" => "yes"))

            expect(last_response).to be_redirect
            expect(last_response.location).to end_with(
              "/manager/discounts/details?viewcode=#{@discount.discount_code}&from_past=yes"
            )
          end
        end
      end

      context "when inputs are invalid" do
        it "does not update details of the discount code" do
          original_name = @discount.campaign_name
          params = test_discount_params(
            code: @discount.discount_code,
            name: "",
            action: "update",
            viewcode: @discount.discount_code
          )
          post_as_employee(@manager, "/manager/update-discount", params)

          discount = DiscountCode[@discount.discount_code]
          expect(discount.campaign_name).to eq(original_name)
        end

        it "does not distribute discount to new eligible customers" do
          add_test_update_discount_eligible_customer_and_order
          discount = add_test_discount_code_to_db(
            discount_code:"TEST", eligible_rule: "1", eligible_min: "25"
          )

          DiscountRedemption.distribute_to_eligible_customers

          params = test_discount_params(
            code: discount.discount_code, 
            action: "update",
            name: "",
            elig_rule: "1",
            min_amount: "15",
            viewcode: discount.discount_code
          )

          expect {
            post_as_employee(@manager, "/manager/update-discount", params)
          }.not_to change(DiscountRedemption, :count)
        end

        it "re-renders update discount page" do
          params = test_discount_params(
            code: @discount.discount_code, 
            name: "", 
            action: "update", 
            viewcode: @discount.discount_code
          )
          post_as_employee(@manager, "/manager/update-discount", params)

          expect(last_response).to be_ok
          expect(last_response.body).to include("Update Discount")
        end

        it "keeps previously entered values in form" do
          params = test_discount_params(
            code: @discount.discount_code,
            name: "Retain Inputs",
            percentage: "",
            action: "update",
            viewcode: @discount.discount_code
          )
          post_as_employee(@manager, "/manager/update-discount", params)

          expect(last_response.body).to include('value="Retain Inputs"')
        end

        it "keeps from_past in the form when re-render if from_past is yes" do
          params = test_discount_params(
            code: @discount.discount_code, 
            name: "", 
            action: "update", 
            viewcode: @discount.discount_code
          )
          post_as_employee(@manager, "/manager/update-discount", params.merge("from_past" => "yes"))

          expect(last_response.body).to include('type="hidden" name="from_past" value="yes"')
        end

        it "shows cancel button to past discount details page when from_past is yes" do
          params = test_discount_params(
            code: @discount.discount_code,
            name: "",
            action: "update",
            viewcode: @discount.discount_code
          )
          post_as_employee(@manager, "/manager/update-discount", params.merge("from_past" => "yes"))

          expect(last_response.body).to include(
            "href='/manager/discounts/details?viewcode=#{@discount.discount_code}&from_past=yes'"
          )
        end

        context "When inputs are empty" do
          it "shows error message for empty Campaign Name" do
            params = test_discount_params(
              code: @discount.discount_code, 
              name: "", 
              action: "update", 
              viewcode: @discount.discount_code
            )
            post_as_employee(@manager, "/manager/update-discount", params)

            expect(last_response.body).to include('error_msg">Campaign name cannot be empty<')
          end

          it "shows error message for empty Percentage off" do
            params = test_discount_params(
              code: @discount.discount_code, 
              percentage: "", 
              action: "update", 
              viewcode: @discount.discount_code
            )
            post_as_employee(@manager, "/manager/update-discount", params)

            expect(last_response.body).to include('error_msg">Percentage off cannot be empty<')
          end

          it "shows error message for empty Code Expiry Date" do
            params = test_discount_params(
              code: @discount.discount_code, 
              expiry: "", 
              action: "update", 
              viewcode: @discount.discount_code
            )
            post_as_employee(@manager, "/manager/update-discount", params)

            expect(last_response.body).to include('error_msg">Expiry date cannot be empty<')
          end

          it "shows error message for empty Status" do
            params = test_discount_params(
              code: @discount.discount_code, 
              status: "", 
              action: "update", 
              viewcode: @discount.discount_code
            )
            post_as_employee(@manager, "/manager/update-discount", params)

            expect(last_response.body).to include('error_msg">Status cannot be empty<')
          end

          it "shows error message for empty From date" do
            params = test_discount_params(
              code: @discount.discount_code, 
              from: "", 
              action: "update", 
              viewcode: @discount.discount_code
            )
            post_as_employee(@manager, "/manager/update-discount", params)

            expect(last_response.body).to include('error_msg">Daterange cannot be empty<')
          end

          it "shows error message for empty To date" do
            params = test_discount_params(
              code: @discount.discount_code, 
              to: "", 
              action: "update", 
              viewcode: @discount.discount_code
            )
            post_as_employee(@manager, "/manager/update-discount", params)

            expect(last_response.body).to include('error_msg">Daterange cannot be empty<')
          end

          it "shows error message for empty Purchase type" do
            params = test_discount_params(
              code: @discount.discount_code, 
              pur_type: "", 
              action: "update", 
              viewcode: @discount.discount_code
            )
            post_as_employee(@manager, "/manager/update-discount", params)

            expect(last_response.body).to include('error_msg">Purchase type cannot be empty<')
          end

          it "shows error message for empty Eligible rule" do
            params = test_discount_params(
              code: @discount.discount_code, 
              elig_rule: "", 
              action: "update", 
              viewcode: @discount.discount_code
            )
            post_as_employee(@manager, "/manager/update-discount", params)

            expect(last_response.body).to include('error_msg">Eligible rule cannot be empty<')
          end

          it "shows error message for empty Minimum amount" do
            params = test_discount_params(
              code: @discount.discount_code, 
              min_amount: "", 
              action: "update", 
              viewcode: @discount.discount_code
            )
            post_as_employee(@manager, "/manager/update-discount", params)

            expect(last_response.body).to include('error_msg">Minimum amount cannot be empty<')
          end
        end

        it "shows error message when discount code is changed" do
          params = test_discount_params(
            code: "NEWCODE", 
            action: "update", 
            viewcode: @discount.discount_code
          )
          post_as_employee(@manager, "/manager/update-discount", params)

          expect(last_response.body).to include('error_msg">Discount Code cannot be changed<')
        end

        it "shows error message when inputted campaign name is longer than 40 characters" do
          params = test_discount_params(
            code: @discount.discount_code, 
            name: "very very very very very very very very very long", 
            action: "update", 
            viewcode: @discount.discount_code
          )
          post_as_employee(@manager, "/manager/update-discount", params)

          expect(last_response.body).to include('error_msg">Maximum 40 characters<')
        end

        it "shows error message when percentage is not between 1 and 100" do
          params = test_discount_params(
            code: @discount.discount_code, 
            percentage: "0", 
            action: "update", 
            viewcode: @discount.discount_code
          )
          post_as_employee(@manager, "/manager/update-discount", params)

          expect(last_response.body).to include('error_msg">Percentage must be between 1 and 100<')
        end

        it "shows error message when start date is later than end date" do
          params = test_discount_params(
            code: @discount.discount_code, 
            from: "2026-07-01", 
            to: "2026-06-01", 
            action: "update", 
            viewcode: @discount.discount_code
          )
          post_as_employee(@manager, "/manager/update-discount", params)

          expect(last_response.body).to include('error_msg">Start date cannot be later than end date<')
        end

        it "shows error message when minimum amount is less than 0" do
          params = test_discount_params(
            code: @discount.discount_code, 
            min_amount: "-1", 
            action: "update", 
            viewcode: @discount.discount_code
          )
          post_as_employee(@manager, "/manager/update-discount", params)

          expect(last_response.body).to include('error_msg">Minimum amount has to be at least 0<')
        end
      end
    end
  end
end