class CreateWorkers < ActiveRecord::Migration[7.0]
  def change
    create_table :workers do |t|
      t.string :title
      t.integer :jobable_id
      t.string :jobable_type

      t.timestamps
    end
  end
end
