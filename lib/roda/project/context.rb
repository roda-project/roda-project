module Roda
  module Project
    class Context
      attr_accessor(
        :project_name,
        :base,
        :database,
        :database_type,
        :rodauth,
        :db_gem,
        :dev_db_url
      )
    end
  end
end
