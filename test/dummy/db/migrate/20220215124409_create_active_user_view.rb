class CreateActiveUserView < ActiveRecord::Migration[7.0]
  def up
    ActiveUserView.sql_view.up
  end

  def down
    ActiveUserView.sql_view.down
  end
end
