require_relative "spec_helper"

describe "hello" do
  it "test requests" do
    get "/"
    _(last_response.status).must_equal 200
  end
end
