RSpec.describe LoginTime do
  describe ".get_customer_login_times" do
    it "returns a maximum of 10 login times" do
      1.upto(11) do |i|
        add_test_login_time_to_db(1)
      end

      expect(LoginTime.get_customer_login_times(1).count).to eq(10)
    end

    it "returns the login times in reverse order (most recent one 1st)" do
      time1 = Time.now.utc - SECONDS_IN_DAY * 2
      time2 = Time.now.utc
      time3 = Time.now.utc - SECONDS_IN_DAY * 7

      add_test_login_time_to_db(1, time1)
      add_test_login_time_to_db(1, time2)
      add_test_login_time_to_db(1, time3)

      login_times = LoginTime.get_customer_login_times(1).all

      expect(login_times[0].login_time).to eq(time2.to_s)
      expect(login_times[1].login_time).to eq(time1.to_s)
      expect(login_times[2].login_time).to eq(time3.to_s)
    end

    it "returns only a specific customer's login times" do
      add_test_login_time_to_db(1)
      add_test_login_time_to_db(2)
      expect(LoginTime.get_customer_login_times(1).count).to eq(1)
    end
  end
end
