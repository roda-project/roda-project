class Tttt
  hash_branch "foo" do |r|
    r.get "bar" do
      view("bar")
    end
  end
end
