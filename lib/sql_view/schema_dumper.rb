require "rails"

# Copy-pasted from scenic game. Scenic is a very nice gem

module SqlView
  # @api private
  module SchemaDumper
    class DBView < OpenStruct
      def to_schema
        <<-DEFINITION
  create_sql_view "#{viewname}", sql: <<-\SQL
    CREATE#{materialized_or_not}VIEW "#{viewname}" AS
    #{escaped_definition.indent(2)}
  SQL\n
        DEFINITION
      end

      private

      def materialized?
        kind == "m"
      end

      def materialized_or_not
        materialized? ? " MATERIALIZED " : " "
      end

      def escaped_definition
        definition.gsub("\\", "\\\\\\")
      end
    end

    def tables(stream)
      super
      views(stream)
    end

    def views(stream)
      stream.puts if sql_views.any?

      sql_views.each do |view|
        stream.puts(view.to_schema)
        indexes(view.viewname, stream)
      end
    end

    private

    def sql_views
      @sql_views ||= ActiveRecord::Base.connection.execute(<<-SQL)
        SELECT
          c.relname as viewname,
          pg_get_viewdef(c.oid) AS definition,
          c.relkind AS kind,
          n.nspname AS namespace
        FROM pg_class c
          LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE
          c.relkind IN ('m', 'v')
          AND c.relname NOT IN (SELECT extname FROM pg_extension)
          AND c.relname != 'pg_stat_statements_info'
          AND n.nspname = ANY (current_schemas(false))
        ORDER BY c.oid
      SQL
    .to_a.map(&DBView.method(:new)).reject { |view| ignored?(view.viewname) }
    end

    unless ActiveRecord::SchemaDumper.private_instance_methods(false).include?(:ignored?)
      # This method will be present in Rails 4.2.0 and can be removed then.
      def ignored?(table_name)
        ["schema_migrations", ignore_tables].flatten.any? do |ignored|
          case ignored
          when String then remove_prefix_and_suffix(table_name) == ignored
          when Regexp then remove_prefix_and_suffix(table_name) =~ ignored
          else
            raise StandardError, "ActiveRecord::SchemaDumper.ignore_tables accepts an array of String and / or Regexp values."
          end
        end
      end
    end
  end
end

SQLView = SqlView
