class CreateAccountStatViewView < ActiveRecord::Migration[7.0]
  def up
    AccountStatViewView.sql_view.up
  end

  def down
    AccountStatViewView.sql_view.down
  end
end
