class CreateMontherAnnaView < ActiveRecord::Migration[7.0]
  def up
    MontherAnnaView.sql_view.up
  end

  def down
    MontherAnnaView.sql_view.down
  end
end
