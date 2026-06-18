class AddUuidToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :uuid, :uuid
    add_index :users, :uuid, unique: true, using: :hash
  end
end
