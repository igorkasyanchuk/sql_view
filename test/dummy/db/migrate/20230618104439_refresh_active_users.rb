class RefreshActiveUsers < ActiveRecord::Migration[7.0]
  def change
    ActiveUserView.sql_view.down
    ActiveUserView.sql_view.up
  end
end
