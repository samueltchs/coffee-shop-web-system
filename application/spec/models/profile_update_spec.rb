RSpec.describe ProfileUpdate do
  describe ".get_customer_profile_updates" do
    it "returns a maximum of 10 profile updates" do
      1.upto(11) do |i|
        add_test_profile_update_to_db(1, "city", "old#{i}", "new#{i}")
      end

      expect(ProfileUpdate.get_customer_profile_updates(1).count).to eq(10)
    end

    it "returns the profile updates in reverse order (most recent one 1st)" do
      add_test_profile_update_to_db(1, "city", "old", "new", Time.now.utc - SECONDS_IN_DAY * 2)
      add_test_profile_update_to_db(1, "email", "old@gmail.com", "new@gmail.com", Time.now.utc)
      add_test_profile_update_to_db(1, "last_name", "Old", "Young", Time.now.utc - SECONDS_IN_DAY * 7)

      updates = ProfileUpdate.get_customer_profile_updates(1).all

      expect(updates[0].field_updated).to eq("email")
      expect(updates[1].field_updated).to eq("city")
      expect(updates[2].field_updated).to eq("last_name")
    end

    it "returns only a specific customer's profile updates" do
      add_test_profile_update_to_db(1)
      add_test_profile_update_to_db(2)
      expect(ProfileUpdate.get_customer_profile_updates(1).count).to eq(1)
    end
  end

  describe "#display_field" do
    it "replaces underscores with spaces and capitalizes" do
      update = add_test_profile_update_to_db(1, "first_name")
      expect(update.display_field).to eq("First name")
    end

    it "capitalizes a single word field" do
      update = add_test_profile_update_to_db(1, "password")
      expect(update.display_field).to eq("Password")
    end
  end

  describe "#display_value" do
    it "returns the value when the field is not password" do
      update = add_test_profile_update_to_db(1, "city", "Manchester", "Sheffield")
      expect(update.display_value("Manchester")).to eq("Manchester")
    end

    it "returns 'Private info' for any value when the field is password" do
      update = add_test_profile_update_to_db(1, "password", nil, nil)
      expect(update.display_value(nil)).to eq("Private info")
    end
  end
end
