class AddFullTextIndexes < ActiveRecord::Migration[7.0]
  def change
    add_index :users, :name, type: :fulltext
    add_index :posts, :message, type: :fulltext
  end
end
