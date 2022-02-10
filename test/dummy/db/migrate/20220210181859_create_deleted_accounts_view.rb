class CreateDeletedAccountsView < ActiveRecord::Migration[7.0]
  def up
    DeletedAccountView.sql_view.up
  end

  def down
    DeletedAccountView.sql_view.down
  end
end
