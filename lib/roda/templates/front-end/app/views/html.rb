module Views
  class Html
    include HtmlSlice

    # for more component classes
    attr_reader :foo

    def initialize(t)
      @t = t
      @foo = Views::Foo::Html.new
    end

    def navbar
      html_slice do
        div class: "navbar" do
          a "home", href: "/"
          a "foo/bar", href: "/foo/bar"
        end
      end
    end
  end
end
