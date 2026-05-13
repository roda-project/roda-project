# frozen_string_literal: true

RSpec.describe Roda::Project do
  it "has a version number" do
    expect(Roda::Project::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
