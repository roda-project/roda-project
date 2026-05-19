class App
  branch "foo" do |r|
    r.get "bar" do
      view("bar")
    end
  end
end
