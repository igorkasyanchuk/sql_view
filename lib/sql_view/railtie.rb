module SqlView
  class Railtie < ::Rails::Railtie
    initializer "sql_view.load" do
      ActiveSupport.on_load :active_record do
        ActiveRecord::ConnectionAdapters::AbstractAdapter.include SqlView::Statements
        ActiveRecord::SchemaDumper.prepend SqlView::SchemaDumper
      end
    end
  end
end
