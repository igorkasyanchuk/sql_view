class CreateParents < ActiveRecord::Migration[7.0]
  def change
    create_table :parents do |t|
      t.string :name
      t.string :type

      t.timestamps
    end
  end
end
