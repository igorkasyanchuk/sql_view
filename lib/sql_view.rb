require 'singleton'
require "sql_view/version"
require "sql_view/railtie"

module SqlView
  class Model
    class_attribute :view, :sql_view_options

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

    def self.extend_with(&block)
      self.sql_view_options[:extend_with] = block
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
      ActiveRecord::Base.connection.execute sql#.wp
    end

    def down
      sql = <<-SQL
      drop #{materialized_or_not} view if exists #{parent.view_name};
    SQL
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
      klass.class_eval(&parent.sql_view_options[:extend_with]) if parent.sql_view_options[:extend_with].present?
      klass
    end
  end

end

  # it 'has dsl' do
  #   Dsl.schema do
  #     materialized_view "short_view" do
  #       source do
  #         User
  #       end
  #       extend_model_with do
  #         scope :ordered, -> { order(:id) }
  #       end
  #       migration do
  #         User.order(:login)
  #       end
  #     end
  #   end
  # end

  
  # class Dsl
  #   include Singleton

  #   delegate_missing_to :instance

  #   def self.schema(&block)
  #     instance.class_eval(&block)
  #   end

  #   def self.materialized_view(name, &block)
  #     puts name
  #     block.call
  #   end

  #   def self.extend_model_with(&block)
  #     puts 111
  #   end

  #   def self.migration(&block)
  #     puts 222
  #   end
  # end

  
  # class Collection
  #   include Singleton

  #   attr_reader :models

  #   def initialize
  #     reset
  #   end

  #   def [](name)
  #     models[name]
  #   end

  #   def reset
  #     @models = {}
  #   end

  #   def register_view(name, options = {}, &block)
  #     models[name] = SqlView.new(name, *options, &block)
  #   end
  # end