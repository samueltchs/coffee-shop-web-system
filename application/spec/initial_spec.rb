RSpec.describe "Initial Setup" do
  it "runs spec_before correctly" do
    expect(SuspensionReason.count).to eq(2)
    expect(DeletionReason.count).to eq(2)
  end
end
