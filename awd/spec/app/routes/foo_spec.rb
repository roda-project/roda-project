require_relative "../../spec_helper"

describe "Routes for foo" do
  it "responds to GET /foo/bar" do
    get "/foo/bar"
    expect(last_response.status).to eq(200)
  end
end
