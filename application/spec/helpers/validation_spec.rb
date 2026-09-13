RSpec.describe Validation do
  include described_class

  describe "#str_email_address?" do
    context "when str is an email address" do
      it "returns true" do
        expect(str_email_address?("p.mcminn@sheffield.ac.uk")).to be(true)
      end
    end

    context "when str is not an email address" do
      it "returns false" do
        expect(str_email_address?("not an email address")).to be(false)
      end
    end
  end

  describe "#str_digits?" do
    context "when str contains digits only" do
      it "returns true" do
        expect(str_digits?("10")).to be(true)
      end
    end

    context "when str is a str" do
      it "returns false" do
        expect(str_digits?("not a number")).to be(false)
      end
    end
  end

  describe "#str_length?" do
    context "when str is the given length" do
      it "returns true" do
        expect(str_length?("10", 2)).to be(true)
      end
    end

    context "when str is not the given length" do
      it "returns false" do
        expect(str_length?("1", 2)).to be(false)
      end
    end
  end

  describe "#str_min_length?" do
    context "when str is the min length" do
      it "returns true" do
        expect(str_min_length?("10", 1)).to be(true)
      end
    end

    context "when str is not the min length" do
      it "returns false" do
        expect(str_min_length?("10", 3)).to be(false)
      end
    end
  end

  describe "#str_max_length?" do
    context "when str is the max length" do
      it "returns true" do
        expect(str_max_length?("10", 3)).to be(true)
      end
    end

    context "when str is not the max length" do
      it "returns false" do
        expect(str_max_length?("10", 1)).to be(false)
      end
    end
  end

  describe "#str_uk_telephone?" do
    context "when str is a telephone number" do
      it "returns true" do
        expect(str_uk_telephone?("0114 222 1826")).to be(true)
      end
    end

    context "when str is not an telephone number" do
      it "returns false" do
        expect(str_uk_telephone?("8798789")).to be(false)
      end
    end
  end

  describe "#str_yyyy_mm_dd_date?" do
    context "when str is a valid date" do
      it "returns true" do
        expect(str_yyyy_mm_dd_date?("1978-04-25")).to be(true)
        expect(str_yyyy_mm_dd_date?("1978-4-25")).to be(true)
      end
    end

    context "when str is not a valid date" do
      it "returns false" do
        expect(str_yyyy_mm_dd_date?("not a date")).to be(false)
        expect(str_yyyy_mm_dd_date?("78-04-25")).to be(false)
        expect(str_yyyy_mm_dd_date?("2023/04/31")).to be(false)
        expect(str_yyyy_mm_dd_date?("2023 04 25")).to be(false)
        expect(str_yyyy_mm_dd_date?("2023-04-31")).to be(false)
        expect(str_yyyy_mm_dd_date?("2023-04-31-10")).to be(false)
      end
    end
  end

  describe "#valid_password?" do
    context "when password is nil" do
      it "returns false" do
        expect(valid_password?(nil)).to be(false)
      end
    end

    context "when password is less than 8 characters long" do
      it "returns false" do
        expect(valid_password?("Admin1!")).to be(false)
      end
    end

    context "when password has no digit" do
      it "returns false" do
        expect(valid_password?("Password!!!")).to be(false)
      end
    end

    context "when password has no uppercase letter" do
      it "returns false" do
        expect(valid_password?("password17!")).to be(false)
      end
    end

    context "when password has no special character" do
      it "returns false" do
        expect(valid_password?("Password171")).to be(false)
      end
    end

    context "when the password satisfies all criteria" do
      it "returns true" do
        expect(valid_password?("Password17!")).to be(true)
      end
    end
  end

  describe "#valid_reference_id?" do
    context "when reference id is nil" do
      it "returns false" do
        expect(valid_reference_id?(nil)).to be(false)
      end
    end

    context "when reference id is less than 8 characters long" do
      it "returns false" do
        expect(valid_reference_id?("ABC1234")).to be(false)
      end
    end

    context "when reference id is more than 12 characters long" do
      it "returns false" do
        expect(valid_reference_id?("ABC1234567890")).to be(false)
      end
    end

    context "when the first three letters are not capital letters" do
      it "returns false" do
        expect(valid_reference_id?("AbC12345")).to be(false)
      end
    end

    context "when the characters other than the first 3 are not digits" do
      it "returns false" do
        expect(valid_reference_id?("ABC12a45")).to be(false)
      end
    end

    context "when reference id satisfies all criteria" do
      it "returns true" do
        expect(valid_reference_id?("ABC12345")).to be(true)
      end
    end
  end

  describe "#valid_name_format?" do
    context "when name is nil" do
      it "returns false" do
        expect(valid_name_format?(nil)).to be(false)
      end
    end

    context "when name only contains hyphens, apostrophes or spaces and no letters" do
      it "returns false" do
        expect(valid_name_format?("-")).to be(false)
        expect(valid_name_format?("'")).to be(false)
        expect(valid_name_format?(" ")).to be(false)
      end
    end

    context "when name contains invalid characters" do
      it "returns false" do
        expect(valid_name_format?("Kons12")).to be(false)
        expect(valid_name_format?("Kons!")).to be(false)
      end
    end

    context "when name is valid" do
      it "returns true" do
        expect(valid_name_format?("john")).to be(true)
        expect(valid_name_format?("O'Connor")).to be(true)
        expect(valid_name_format?("Knowles-Carter")).to be(true)
        expect(valid_name_format?("dos Santos Aveiro")).to be(true)
      end
    end
  end

  describe "#valid_name_capitalization?" do
    context "when name is nil" do
      it "returns false" do
        expect(valid_name_capitalization?(nil)).to be(false)
      end
    end

    context "when name does not start with a capital letter" do
      it "returns false" do
        expect(valid_name_capitalization?("john")).to be(false)
      end
    end

    context "when name starts with a capital letter" do
      it "returns true" do
        expect(valid_name_capitalization?("John")).to be(true)
      end
    end
  end
end
