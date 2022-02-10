class AddActiveView < ActiveRecord::Migration[7.0]
  def change
    ActiveAccountView.sql_view.up
  end
end
