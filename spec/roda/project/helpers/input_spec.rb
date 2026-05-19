RSpec.describe Roda::Project::Helpers::Input do
  # Create a dummy class to include the module for testing
  let(:dummy_class) do
    Class.new do
      include Roda::Project::Helpers::Input
    end
  end
  let(:instance) { dummy_class.new }
  let(:reader_double) { instance_double(TTY::Reader) }

  before do
    allow(TTY::Reader).to receive(:new).and_return(reader_double)
  end

  describe "#read_line" do
    let(:prompt) { "Enter something: " }
    let(:default_value) { "default" }

    context "when user enters an empty string" do
      it "returns the default value" do
        allow(reader_double).to receive(:read_line).with(prompt).and_return("")
        expect(instance.read_line(prompt, default_value)).to eq(default_value)
      end
    end

    context "when user enters 'n'" do
      it "returns false" do
        allow(reader_double).to receive(:read_line).with(prompt).and_return("n")
        expect(instance.read_line(prompt, default_value)).to be(false)
      end
    end

    context "when user enters a non-empty, non-'n' string" do
      it "returns the entered string" do
        user_input = "some value"
        allow(reader_double).to receive(:read_line).with(prompt).and_return(user_input)
        expect(instance.read_line(prompt, default_value)).to eq(user_input)
      end

      it "chomps the input" do
        user_input_with_newline = "some value\n"
        user_input_chomped = "some value"
        allow(reader_double).to receive(:read_line).with(prompt).and_return(user_input_with_newline)
        expect(instance.read_line(prompt, default_value)).to eq(user_input_chomped)
      end
    end

    context "when reader is called" do
      it "initializes TTY::Reader once" do
        instance.reader
        instance.reader # Call again to ensure memoization
        expect(TTY::Reader).to have_received(:new).once
      end
    end
  end
end
