require "rails/generators"
require "rails/generators/active_record"

module SqlView
  module Generators
    class ViewGenerator < Rails::Generators::NamedBase
      include Rails::Generators::Migration

      class_option :"view-name", type: :string, default: nil
      class_option :materialized, type: :boolean, default: false

      def create_everything
        create_file "app/sql_views/#{file_name}_view.rb", <<-FILE
class #{class_name}View < SqlView::Model
#{top_code}

  schema -> #{schema_code}

  extend_model_with do
    # sample how you can extend it, similar to regular AR model
    #
    # include SomeConcern
    #
    # belongs_to :user
    # has_many :posts
    #
    # scope :ordered, -> { order(:created_at) }
    # scope :by_role, ->(role) { where(role: role) }
  end
end
FILE

        create_file "db/migrate/#{self.class.next_migration_number("db/migrate")}_create_#{file_name}_view.rb", <<-FILE
class #{migration_class_name} < #{activerecord_migration_class}
  def up
    #{class_name}View.sql_view.up
  end

  def down
    #{class_name}View.sql_view.down
  end
end
FILE
      end

      def self.next_migration_number(dir)
        ::ActiveRecord::Generators::Base.next_migration_number(dir)
      end

      no_tasks do
        def top_code
          [view_name_code, materialized_code].compact.join("\n\n")
        end

        def view_name_code
          options["view-name"] ? "  self.view_name = '#{options["view-name"]}'" : nil
        end

        def materialized_code
          options[:materialized] ? "  materialized" : nil
        end

        def schema_code
          if args[0].present?
            "{ #{args[0]} }"
          else
            " { #{ "\n    # ActiveRecord::Relation or SQL\n    # for example: User.where(active: true)\n  }" }"
          end
        end

        def migration_class_name
          "Create#{class_name.tr('.', '')}View"
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

    end
  end
end