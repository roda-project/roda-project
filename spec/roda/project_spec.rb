# frozen_string_literal: true

RSpec.describe Roda::Project do
  it "has a version number" do
    expect(Roda::Project::VERSION).not_to be nil
  end
end
