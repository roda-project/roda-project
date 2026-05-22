require_relative "../../spec_helper"

describe "Routes for foo" do
  it "responds to GET /foo/bar" do
    get "/foo/bar"
    _(last_response.status).must_equal 200
  end
end
