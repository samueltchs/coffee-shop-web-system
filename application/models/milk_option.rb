class MilkOption < Sequel::Model
  def self.get_milk_name(milk_id)
    milk_row = self[milk_id]

    return "" unless milk_row

    milk_row.milk
  end

  def self.get_all_milk_names()
    milks = []
    MilkOption.all().each do |option|
      milks.append(option.milk)
    end
    return milks
  end

  def self.get_id(name)
    milk_option = self.first(milk: name)
    return -1 unless milk_option
    milk_option.id
  end
end
