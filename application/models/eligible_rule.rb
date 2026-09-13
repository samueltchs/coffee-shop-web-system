class EligibleRule < Sequel::Model
  def self.test(min, actual)
    actual >= min
  end

  def self.get_rule_text(id)
    EligibleRule.first(id: id).rule
  end
end