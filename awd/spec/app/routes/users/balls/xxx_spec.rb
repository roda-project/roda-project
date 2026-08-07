require_relative "../../../../spec_helper"

describe "Routes for users/balls/xxx" do
  it "responds to GET /users/balls/xxx/one" do
    get "/users/balls/xxx/one"
    expect(last_response.status).to eq(200)
  end
  it "responds to GET /users/balls/xxx/two" do
    get "/users/balls/xxx/two"
    expect(last_response.status).to eq(200)
  end
  it "responds to GET /users/balls/xxx/three" do
    get "/users/balls/xxx/three"
    expect(last_response.status).to eq(200)
  end
end
