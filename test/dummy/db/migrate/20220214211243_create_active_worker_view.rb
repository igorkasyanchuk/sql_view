class CreateActiveWorkerView < ActiveRecord::Migration[7.0]
  def up
    ActiveWorkerView.sql_view.up
  end

  def down
    ActiveWorkerView.sql_view.down
  end
end
