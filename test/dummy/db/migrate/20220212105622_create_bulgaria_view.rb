class CreateBulgariaView < ActiveRecord::Migration[7.0]
  def up
    BulgariaView.sql_view.up
  end

  def down
    BulgariaView.sql_view.down
  end
end
