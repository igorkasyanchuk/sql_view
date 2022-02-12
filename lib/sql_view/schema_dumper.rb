require "rails"

# Copy-pasted from scenic game. Scenic is a very nice gem

module SqlView
  # @api private
  module SchemaDumper
    class DBView < OpenStruct
      def to_schema
        <<-DEFINITION
  create_sql_view "#{self.viewname}", sql: <<-\SQL
    CREATE #{materialized_or_not} VIEW "#{self.viewname}" AS
    #{escaped_definition.indent(2)}
  SQL\n
        DEFINITION
      end

      private
      def materialized?
        self.kind == "m"
      end

      def materialized_or_not
        materialized? ? " MATERIALIZED " : nil
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
      if dumpable_views_in_database.any?
        stream.puts
      end

      dumpable_views_in_database.each do |viewname|
        next if already_indexed?(viewname)
        view = DBView.new(get_view_info(viewname))
        stream.puts(view.to_schema)
        indexes(viewname, stream)
      end
    end

    private

    # make sure view was added one time, because somehow was adding views two times
    def already_indexed?(viewname)
      @already_indexed ||= []
      return true if @already_indexed.include?(viewname)
      @already_indexed << viewname
      false
    end

    def dumpable_views_in_database
      @dumpable_views_in_database ||= ActiveRecord::Base.connection.views.reject do |viewname|
        ignored?(viewname)
      end
    end

    def get_view_info(viewname)
      views_schema.detect{|e| e['viewname'] == viewname}
    end

    def views_schema
      @views_schema ||= ActiveRecord::Base.connection.execute(<<-SQL)
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
          AND n.nspname = ANY (current_schemas(false))
        ORDER BY c.oid
      SQL
    .to_a
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
