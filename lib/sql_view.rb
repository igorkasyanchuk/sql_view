require "singleton"
require_relative "./sql_view/schema_dumper.rb"
require_relative "./sql_view/statements.rb"
require "sql_view/version"
require "sql_view/railtie"

module SqlView
  # mattr_accessor :klasses
  # @@klasses = {}

  class Model
    class_attribute :view, :sql_view_options

    class << self
      delegate_missing_to :model
    end

    def self.inherited(subclass)
      # puts subclass
      subclass.sql_view_options = {}
      # SqlView.klasses[subclass] = subclass.sql_view
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

    def refresh
      down
      up
    end

    def up
      view_sql = parent.sql_view_options[:sql_or_proc].call
      sql = <<-SQL
      CREATE #{materialized_or_not} VIEW #{parent.view_name} AS
      #{view_sql.respond_to?(:to_sql) ? view_sql.to_sql : view_sql };
    SQL
      puts sql if Rails.env.development?
      ActiveRecord::Base.connection.execute sql#.wp
    end

    def down
      sql = <<-SQL
      drop #{materialized_or_not} view if exists #{parent.view_name};
    SQL
      puts sql if Rails.env.development?
      ActiveRecord::Base.connection.execute sql#.wp
    end

    private

    def materialized_or_not
      parent.sql_view_options[:materialized] ? "MATERIALIZED" : nil
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
      klass
    end
  end

end
