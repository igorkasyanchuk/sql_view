module SqlView
  module Statements
    def create_sql_view(viewname, sql:)
      ActiveRecord::Base.connection.execute(sql)
    end
  end
end
