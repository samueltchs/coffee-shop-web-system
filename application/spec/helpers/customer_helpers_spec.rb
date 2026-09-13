RSpec.describe CustomerHelpers do
  include described_class

  describe "#customer_times_recorded" do
    context "when customer is nil" do
      it "returns an empty array" do
        expect(customer_times_recorded(nil)).to eq([])
      end
    end

    context "when no times are recorded for the customer" do
      it "returns an empty array" do
        customer = add_test_customer_to_db
        expect(customer_times_recorded(customer)).to eq([])
      end
    end

    context "when times are recorded for the customer" do
      it "returns an array of all the times recorded" do
        customer = add_test_customer_to_db
        add_test_order_to_db(1)
        add_test_login_time_to_db(1)
        add_test_favourite_to_db(1)
        add_test_recent_view_to_db(1)
        add_test_profile_update_to_db(1)
        expect(customer_times_recorded(customer).length).to eq(5)
      end
    end
  end

  describe "#compute_inactivity" do
    context "when no times are recorded and registered time is nil" do
      it "returns nil" do
        customer = add_test_customer_to_db(
          1, "Mikel", "Merino", "address1", "address2", "Sheffield", "S1 1AA", "7710002000", "email@gmail.com", 0, nil
        )
        expect(compute_inactivity(customer)).to be_nil
      end
    end

    context "when no times are recorded but registered time exists" do
      it "returns the time since registration" do
        customer = add_test_customer_to_db(
          1, "Mikel", "Merino", "address1", "address2", "Sheffield", "S1 1AA",
          "7710002000", "email@gmail.com", 0, Time.now.utc - SECONDS_IN_DAY * 10
        )
        expect(compute_inactivity(customer)).to be_between(SECONDS_IN_DAY * 10, SECONDS_IN_DAY * 10 + 5).inclusive
      end
    end

    context "when times are recorded" do
      it "returns the time since most recent activity" do
        customer = add_test_customer_to_db
        add_test_login_time_to_db(1, Time.now.utc - SECONDS_IN_DAY * 5)
        add_test_recent_view_to_db(1, 1, Time.now.utc - SECONDS_IN_DAY * 10)
        expect(compute_inactivity(customer)).to be_between(SECONDS_IN_DAY * 5, SECONDS_IN_DAY * 5 + 5).inclusive
      end
    end
  end

  describe "#inactivity_in_months" do
    context "when no times are recorded and registered time is nil" do
      it "returns nil" do
        customer = add_test_customer_to_db(
          1, "Mikel", "Merino", "address1", "address2", "Sheffield", "S1 1AA", "7710002000", "email@gmail.com", 0, nil
        )
        expect(inactivity_in_months(customer)).to be_nil
      end
    end

    context "when the customer has been inactive for less than a month" do
      it "returns < 1 month" do
        customer = add_test_customer_to_db(
          1, "Mikel", "Merino", "address1", "address2", "Sheffield", "S1 1AA",
          "7710002000", "email@gmail.com", 0, Time.now.utc - SECONDS_IN_DAY * 10
        )
        expect(inactivity_in_months(customer)).to eq("< 1 month")
      end
    end

    context "when the customer has been inactive for 1 month" do
      it "returns 1 month" do
        customer = add_test_customer_to_db(
          1, "Mikel", "Merino", "address1", "address2", "Sheffield", "S1 1AA",
          "7710002000", "email@gmail.com", 0, Time.now.utc - SECONDS_IN_MONTH
        )
        expect(inactivity_in_months(customer)).to eq("1 month")
      end
    end

    context "when the customer has been inactive for more than 1 month" do
      it "returns the number of months since inactive" do
        customer = add_test_customer_to_db(
          1, "Mikel", "Merino", "address1", "address2", "Sheffield", "S1 1AA",
          "7710002000", "email@gmail.com", 0, Time.now.utc - SECONDS_IN_MONTH * 3
        )
        expect(inactivity_in_months(customer)).to eq("3 months")
      end
    end
  end

  describe "#five_months_inactive" do
    context "when customer has no times recorded and registered time is nil" do
      it "returns false" do
        customer = add_test_customer_to_db(
          1, "Mikel", "Merino", "address1", "address2", "Sheffield", "S1 1AA", "7710002000", "email@gmail.com", 0, nil
        )
        expect(five_months_inactive(customer)).to be false
      end
    end

    context "when customer has been inactive for less than 5 months" do
      it "returns false" do
        customer = add_test_customer_to_db(
          1, "Mikel", "Merino", "address1", "address2", "Sheffield", "S1 1AA",
          "7710002000", "email@gmail.com", 0, Time.now.utc - SECONDS_IN_MONTH * 4
        )
        expect(five_months_inactive(customer)).to be false
      end
    end

    context "when customer has been inactive for at least 5 months" do
      it "returns true" do
        customer = add_test_customer_to_db(
          1, "Mikel", "Merino", "address1", "address2", "Sheffield", "S1 1AA",
          "7710002000", "email@gmail.com", 0, Time.now.utc - SECONDS_IN_MONTH * 5
        )
        expect(five_months_inactive(customer)).to be true
      end
    end
  end

  describe "#four_days_since_flagged" do
    context "when customer is not flagged" do
      it "returns false" do
        customer = add_test_customer_to_db
        expect(four_days_since_flagged(customer)).to be false
      end
    end

    context "when customer is flagged but flagged_at is nil" do
      it "returns false" do
        customer = add_test_customer_to_db(
          1, "Mikel", "Merino", "address1", "address2", "Sheffield", "S1 1AA",
          "7710002000", "email@gmail.com", 0, Time.now.utc - SECONDS_IN_MONTH, "Flagged"
        )
        expect(four_days_since_flagged(customer)).to be false
      end
    end

    context "when customer has been flagged for less than 4 days" do
      it "returns false" do
        customer = add_flagged_customer_to_db(1, Time.now.utc - SECONDS_IN_DAY * 3)
        expect(four_days_since_flagged(customer)).to be false
      end
    end

    context "when customer has been flagged for at least 4 days" do
      it "returns true" do
        customer = add_flagged_customer_to_db(1, Time.now.utc - SECONDS_IN_DAY * 4)
        expect(four_days_since_flagged(customer)).to be true
      end
    end
  end

  describe "#three_months_since_suspended" do
    context "when customer is not suspended" do
      it "returns false" do
        customer = add_test_customer_to_db
        expect(three_months_since_suspended(customer)).to be false
      end
    end

    context "when customer is suspended but suspended_at is nil" do
      it "returns false" do
        customer = add_test_customer_to_db(
          1, "Mikel", "Merino", "address1", "address2", "Sheffield", "S1 1AA",
          "7710002000", "email@gmail.com", 0, Time.now.utc - SECONDS_IN_MONTH, "Suspended"
        )
        expect(three_months_since_suspended(customer)).to be false
      end
    end

    context "when customer has been suspended for less than 3 months" do
      it "returns false" do
        customer = add_suspended_customer_to_db(
          1, Time.now.utc - SECONDS_IN_DAY * 65, Time.now.utc - SECONDS_IN_MONTH * 2
        )
        expect(three_months_since_suspended(customer)).to be false
      end
    end

    context "when customer has been suspended for at least 3 months" do
      it "returns true" do
        customer = add_suspended_customer_to_db(
          1, Time.now.utc - SECONDS_IN_DAY * 95, Time.now.utc - SECONDS_IN_MONTH * 3
        )
        expect(three_months_since_suspended(customer)).to be true
      end
    end
  end

  describe "#automatic_flag" do
    context "when the customer is not active" do
      it "does not flag them" do
        customer = add_suspended_customer_to_db
        automatic_flag(customer)
        expect(customer.status).to eq("Suspended")
      end
    end

    context "when an active customer has not been inactive for 6 months" do
      it "does not flag them" do
        customer = add_test_customer_to_db(
          1, "Mikel", "Merino", "address1", "address2", "Sheffield", "S1 1AA",
          "7710002000", "email@gmail.com", 0, Time.now.utc - SECONDS_IN_MONTH * 5
        )
        automatic_flag(customer)
        expect(customer.status).to eq("Active")
      end
    end

    context "when an active customer has been inactive for at least 6 months" do
      it "flags them" do
        customer = add_test_customer_to_db(
          1, "Mikel", "Merino", "address1", "address2", "Sheffield", "S1 1AA",
          "7710002000", "email@gmail.com", 0, Time.now.utc - SECONDS_IN_MONTH * 6
        )
        automatic_flag(customer)
        expect(customer.status).to eq("Flagged")
        expect(customer.flagged_at).not_to be_nil
      end
    end
  end

  describe "#automatic_reactivation" do
    context "when the customer is not flagged" do
      it "does not reactivate them" do
        customer = add_suspended_customer_to_db
        automatic_reactivation(customer)
        expect(customer.status).to eq("Suspended")
      end
    end

    context "when a customer is flagged but flagged_at is nil" do
      it "does not reactivate them" do
        customer = add_flagged_customer_to_db(1, nil)
        automatic_reactivation(customer)
        expect(customer.status).to eq("Flagged")
      end
    end

    context "when a flagged customer has no recorded activity for 6 months" do
      it "does not reactivate them" do
        customer = add_flagged_customer_to_db
        automatic_reactivation(customer)
        expect(customer.status).to eq("Flagged")
      end
    end

    context "when a flagged customer records activity during the 5 days before suspension" do
      it "reactivates them" do
        customer = add_flagged_customer_to_db
        add_test_login_time_to_db(customer.loyalty_number, Time.now.utc)
        automatic_reactivation(customer)
        expect(customer.status).to eq("Active")
        expect(customer.flagged_at).to be_nil
      end
    end
  end

  describe "#automatic_suspension" do
    context "when a customer is not flagged" do
      it "does not suspend them" do
        customer = add_test_customer_to_db
        automatic_suspension(customer)
        expect(customer.status).to eq("Active")
      end
    end

    context "when a customer is flagged but flagged_at is nil" do
      it "does not suspend them" do
        customer = add_flagged_customer_to_db(1, nil)
        automatic_suspension(customer)
        expect(customer.status).to eq("Flagged")
      end
    end

    context "when a customer has been flagged for less than 5 days" do
      it "does not suspend them" do
        customer = add_flagged_customer_to_db(1, Time.now.utc - SECONDS_IN_DAY * 4)
        automatic_suspension(customer)
        expect(customer.status).to eq("Flagged")
      end
    end

    context "when a customer has been flagged for at least 5 days" do
      it "suspends them" do
        customer = add_flagged_customer_to_db(1, Time.now.utc - SECONDS_IN_DAY * 5)
        automatic_suspension(customer)
        expect(customer.status).to eq("Suspended")
        expect(customer.suspended_at).not_to be_nil
        expect(customer.suspension_reason_id).to eq(1)
      end
    end
  end

  describe "#automatic_deletion" do
    context "when a customer has not been suspended for at least 3 months" do
      it "does not delete them" do
        customer = add_suspended_customer_to_db(
          1, Time.now.utc - SECONDS_IN_DAY * 65, Time.now.utc - SECONDS_IN_MONTH * 2
        )
        automatic_deletion(customer)
        expect(Customer.first(loyalty_number: customer.loyalty_number)).not_to be_nil
        expect(Customer.where(status: 'Deleted').count).to eq(0)
      end
    end

    context "when a customer has been suspended for less than a week past 3 months" do
      it "does not delete them" do
        customer = add_suspended_customer_to_db(
          1, Time.now.utc - SECONDS_IN_DAY * 95, Time.now.utc - SECONDS_IN_MONTH * 3
        )
        automatic_deletion(customer)
        expect(Customer.first(loyalty_number: customer.loyalty_number)).not_to be_nil
        expect(Customer.where(status: 'Deleted').count).to eq(0)
      end
    end

    context "when a customer has been suspended due to disciplinary reasons for 3 months and a week" do
      it "does not delete them" do
        customer = add_suspended_customer_to_db(
          1, Time.now.utc - SECONDS_IN_DAY * 102, Time.now.utc - SECONDS_IN_MONTH * 3 - SECONDS_IN_DAY * 7, 2
        )
        automatic_deletion(customer)
        expect(Customer.first(loyalty_number: customer.loyalty_number)).not_to be_nil
        expect(Customer.where(status: 'Deleted').count).to eq(0)
      end
    end

    context "when a customer has been suspended due to inactivity for 3 months and a week" do
      it "deletes them" do
        customer = add_suspended_customer_to_db(
          1, Time.now.utc - SECONDS_IN_DAY * 102, Time.now.utc - SECONDS_IN_MONTH * 3 - SECONDS_IN_DAY * 7
        )
        automatic_deletion(customer)
        expect(Customer.first(loyalty_number: customer.loyalty_number)).to be_nil
        expect(Customer.where(status: 'Deleted').count).to eq(1)
        expect(Customer.where(deleted_at: nil).count).to eq(0)
        expect(Customer.where(deletion_reason_id: 1).count).to eq(1)
      end
    end
  end

  describe "#run_inactivity_checks" do
    it "runs all automatic checks on every customer" do
      active_customer = add_test_customer_to_db(
        1, "Mikel", "Merino", "address1", "address2", "Sheffield", "S1 1AA",
        "7710002000", "email@gmail.com", 0, Time.now.utc - SECONDS_IN_MONTH * 6
      )
      flagged_for_suspension_cust = add_flagged_customer_to_db(2, Time.now.utc - SECONDS_IN_DAY * 5)
      flagged_for_reactivation_cust = add_flagged_customer_to_db(3, Time.now.utc - SECONDS_IN_DAY * 2)
      add_test_login_time_to_db(3, Time.now.utc)
      suspended_customer = add_suspended_customer_to_db(
        4, Time.now.utc - SECONDS_IN_DAY * 102, Time.now.utc - SECONDS_IN_DAY * 7 - SECONDS_IN_MONTH * 3
      )

      run_inactivity_checks

      expect(Customer.first(loyalty_number: active_customer.loyalty_number).status).to eq("Flagged")
      expect(Customer.first(loyalty_number: flagged_for_suspension_cust.loyalty_number).status).to eq("Suspended")
      expect(Customer.first(loyalty_number: flagged_for_suspension_cust.loyalty_number).suspended_at).not_to be_nil
      expect(Customer.first(loyalty_number: flagged_for_reactivation_cust.loyalty_number).status).to eq("Active")
      expect(Customer.first(loyalty_number: flagged_for_reactivation_cust.loyalty_number).flagged_at).to be_nil
      expect(Customer.first(loyalty_number: suspended_customer.loyalty_number)).to be_nil
      expect(Customer.where(status: 'Deleted').count).to eq(1)
      expect(Customer.where(deleted_at: nil).count).to eq(3)
    end
  end

  describe "#anonymize_customer" do
    before do
      @customer = add_test_customer_to_db
    end

    context "when the customer is successfully anonymized" do
      it "changes the customer's loyalty number" do
        new_loyalty_no = anonymize_customer(@customer, 1)
        expect(new_loyalty_no).not_to eq(@customer.loyalty_number)
        expect(new_loyalty_no).not_to be_nil
      end

      it "anonymizes all columns of the customers table" do
        anonymize_customer(@customer, 1)

        deleted_cust = Customer.first(status: 'Deleted')
        expect(deleted_cust).not_to be_nil
        expect(deleted_cust.first_name).to eq("Deleted")
        expect(deleted_cust.last_name).not_to eq(@customer.last_name)
        expect(deleted_cust.pass_hash).to be_nil
        expect(deleted_cust.address_line_1).to be_nil
        expect(deleted_cust.address_line_2).to be_nil
        expect(deleted_cust.city).to be_nil
        expect(deleted_cust.postcode).to be_nil
        expect(deleted_cust.phone_number).to be_nil
        expect(deleted_cust.email).to be_nil
        expect(deleted_cust.registered_time).to be_nil
        expect(deleted_cust.flagged_at).to be_nil
        expect(deleted_cust.suspended_at).to be_nil
        expect(deleted_cust.deleted_at).not_to be_nil
        expect(deleted_cust.suspension_reason_id).to be_nil
        expect(deleted_cust.deletion_reason_id).to eq(1)
      end

      it "updates all of the customer's associated records to have the new loyalty number" do
        old_loyalty_no = @customer.loyalty_number
        add_test_order_to_db(old_loyalty_no)
        add_test_login_time_to_db(old_loyalty_no)
        add_test_favourite_to_db(old_loyalty_no)
        add_test_recent_view_to_db(old_loyalty_no)
        add_test_size_to_db
        add_test_milk_option_to_db
        add_test_country_to_db
        add_test_roast_level_to_db
        add_test_product_to_db
        add_test_basket_item_to_db(old_loyalty_no)
        add_test_product_variant_to_db
        add_test_free_coffee_redemption_to_db(old_loyalty_no)
        add_test_profile_update_to_db(old_loyalty_no)
        add_test_refund_to_db(old_loyalty_no)
        add_test_discount_code_to_db
        add_test_discount_redemption_to_db(old_loyalty_no)
        add_test_promotion_to_db(old_loyalty_no)
        add_test_complaint_to_db(old_loyalty_no)

        new_loyalty_no = anonymize_customer(@customer, 1)

        model_classes = [
          Order, LoginTime, Favourite, RecentView, FreeCoffeeRedemption,
          ProfileUpdate, Refund, DiscountRedemption, Promotion, Complaint
        ]

        model_classes.each do |model|
          expect(model.where(loyalty_number: old_loyalty_no).count).to eq(0)
          expect(model.where(loyalty_number: new_loyalty_no).count).to eq(1)
        end

        expect(BasketItem.where(loyalty_number: new_loyalty_no).count).to eq(0)

        profile_update = ProfileUpdate.first(loyalty_number: new_loyalty_no)
        refund = Refund.first(loyalty_number: new_loyalty_no)
        complaint = Complaint.first(loyalty_number: new_loyalty_no)

        expect(profile_update.old_value).to be_nil
        expect(profile_update.new_value).to be_nil
        expect(refund.refund_reason).to eq('')
        expect(complaint.complaint_text).to eq('Deleted')
      end
    end

    context "when the anonymization fails" do
      it "does not change the customer's loyalty number" do
        allow(self).to receive(:anonymize_customer_record).and_return(0)
        anonymize_customer(@customer, 1)
        expect(Customer.first(loyalty_number: @customer.loyalty_number)).not_to be_nil
      end
    end
  end

  describe "#unique_deleted_cust_loyalty_no" do
    it "returns an integer number" do
      expect(unique_deleted_cust_loyalty_no).to be_instance_of(Integer)
    end

    it "returns a number within range" do
      expect(unique_deleted_cust_loyalty_no).to be_between(1, 999_999_999).inclusive
    end

    it "returns a unique loyalty number" do
      expect(Customer.first(loyalty_number: unique_deleted_cust_loyalty_no)).to be_nil
    end
  end
end
