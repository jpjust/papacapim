class CreateFollowers < ActiveRecord::Migration[7.0]
  def change
    create_table :followers do |t|
      t.references :follower, :null => false
      t.references :followed, :null => false

      t.timestamps
    end

    add_foreign_key :followers, :users, column: :follower_id
    add_foreign_key :followers, :users, column: :followed_id

    add_index :followers, [:follower_id, :followed_id], :unique => true, :using => :hash
  end
end
