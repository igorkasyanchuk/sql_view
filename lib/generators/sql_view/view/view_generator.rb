require "rails/generators"
require "rails/generators/active_record"

module SqlView
  module Generators
    # @api private
    class ViewGenerator < Rails::Generators::NamedBase
      include Rails::Generators::Migration
      source_root File.expand_path("templates", __dir__)

      def create_views_directory
        unless views_directory_path.exist?
          empty_directory(views_directory_path)
        end
      end

      def create_view_definition
        create_file definition.path
      end

      def create_migration_file
        migration_template(
          "db/migrate/create_view.erb",
          "db/migrate/create_#{plural_file_name}.rb",
        )
      end

      def self.next_migration_number(dir)
        ::ActiveRecord::Generators::Base.next_migration_number(dir)
      end

      no_tasks do
        def migration_class_name
          "Create#{class_name.tr('.', '').pluralize}"
        end

        def activerecord_migration_class
          if ActiveRecord::Migration.respond_to?(:current_version)
            "ActiveRecord::Migration[#{ActiveRecord::Migration.current_version}]"
          else
            "ActiveRecord::Migration"
          end
        end
      end

      private

      alias singular_name file_name

      def file_name
        super.tr(".", "_")
      end

      def views_directory_path
        @views_directory_path ||= Rails.root.join("db", "views")
      end

      def formatted_plural_name
        if plural_name.include?(".")
          "\"#{plural_name}\""
        else
          ":#{plural_name}"
        end
      end

      def create_view_options
        if materialized?
          ", materialized: #{no_data? ? '{ no_data: true }' : true}"
        else
          ""
        end
      end
    end
  end
end
