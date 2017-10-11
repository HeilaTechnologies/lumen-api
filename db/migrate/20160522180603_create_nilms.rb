class CreateNilms < ActiveRecord::Migration[5.0]
  def change
    create_table :nilms do |t|
      t.string :name
      t.string :description
      t.string :url
      t.timestamps null: false
    end

    add_column :dbs, :nilm_id, :integer
  end
end
