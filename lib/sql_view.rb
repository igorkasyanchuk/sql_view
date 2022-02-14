require "singleton"
require_relative "./sql_view/schema_dumper.rb"
require_relative "./sql_view/statements.rb"
require "sql_view/version"
require "sql_view/railtie"

#
#
# TODO for now in a single file
# move to separate files
#
#

module SqlView
  def SqlView.log(message)
    puts message
  end

  class Model
    class_attribute :view, :sql_view_options

    class << self
      delegate_missing_to :model
    end

    def self.inherited(subclass)
      subclass.sql_view_options = {}
    end

    def self.view_name=(name)
      @view_name = name
    end

    def self.view_name
      @view_name.presence || (self.view_name=self.to_s.underscore.pluralize)
    end

    def self.model
      @model ||= ClassBuilder.create_model(self)
    end

    def self.sql_view
      @sql_view ||= Migration.new(self)
    end

    def self.materialized
      self.sql_view_options[:materialized] = true
    end

    def self.schema(sql_or_proc)
      self.sql_view_options[:sql_or_proc] = sql_or_proc
    end

    def self.extend_model_with(&block)
      self.sql_view_options[:extend_model_with] = block
    end
  end

  class Migration
    attr_reader :parent

    def initialize(parent)
      @parent = parent
    end

    def refresh(concurrently: false)
      concurrently_or_not = concurrently ? " CONCURRENTLY " : " "
      sql = <<-SQL
      REFRESH#{materialized_or_not}VIEW#{concurrently_or_not}#{parent.view_name};
      SQL
      execute(sql)
    end

    def up
      view_sql = parent.sql_view_options[:sql_or_proc].call
      raise "Please configure schema for #{parent} (association or SQL) for the view" if view_sql.to_s == ""
      sql = <<-SQL
      CREATE#{materialized_or_not}VIEW #{parent.view_name} AS
      #{view_sql.respond_to?(:to_sql) ? view_sql.to_sql : view_sql };
    SQL
      execute(sql)
    end

    def down
      sql = <<-SQL
      DROP#{materialized_or_not}VIEW IF EXISTS #{parent.view_name};
    SQL
      execute(sql)
    end

    def execute(sql)
      SqlView.log sql
      ActiveRecord::Base.connection.execute sql#.wp
    end

    private

    def materialized_or_not
      parent.sql_view_options[:materialized] ? " MATERIALIZED " : " "
    end

  end

  class ClassBuilder
    def ClassBuilder.create_model(parent)
      klass = Class.new(ActiveRecord::Base) do
        def self.model_name
          ActiveModel::Name.new(self, nil, parent.view_name)
        end
        def readonly?
          true
        end
        self.table_name = parent.view_name
        self.inheritance_column = nil
      end
      if parent.sql_view_options[:extend_model_with].present?
        klass.class_eval(&parent.sql_view_options[:extend_model_with])
      end
      # to use e.associations.count for example
      # because of the error undefined scan for nil class
      klass.class_eval %Q{
        def self.name
          "#{parent.class}"
        end
      }
      klass
    end
  end

end
