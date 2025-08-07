RSpec.describe StringHelper, type: :helper do
  describe "#remove_underscores" do
    it "removes underscores from a string" do
      expect(remove_underscores("hello_world")).to eq("hello world")
    end

    it "replaces underscores with a custom character" do
      expect(remove_underscores("hello_world", replace_with: "-")).to eq("hello-world")
    end

    it "raises an error if the input is not a string" do
      expect { remove_underscores(123) }.to raise_error(ArgumentError)
    end
  end
end
