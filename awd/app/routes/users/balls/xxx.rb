class Awd
  hash_branch :"users/balls", "xxx" do |r|
    r.get "one" do
      view('one')
    end

    r.get "two" do
      view('two')
    end

    r.get "three" do
      view('three')
    end
  end
end
