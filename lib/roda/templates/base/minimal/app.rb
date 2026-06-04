class App < Roda
  # Routing
  plugin :all_verbs
  plugin :not_found

  # Request / Response
  plugin :halt
  plugin :json
  plugin :exception_page

  # Other
  plugin :common_logger
  plugin :json_parser

  route do |r|
    r.root do
      { message: "Hello world" }
    end
  end

  error do |e|
    next exception_page(e, css_file: "/public/exception_page.css") if NOT_PRODUCTION
  end

  not_found do
    "not found"
  end
end
