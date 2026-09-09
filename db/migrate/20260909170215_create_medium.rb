class CreateMedium < ActiveRecord::Migration[7.0]
  def change
    create_table :media do |t|
      t.references :post, null: false, foreign_key: true
      t.string :uuid, null: false, unique: true
      t.string :medium_type, null: false
      t.timestamps
    end
  end
end
