class CreateSessions < ActiveRecord::Migration[7.0]
  def change
    create_table :sessions do |t|
      t.references :user, :null => false, :foreign_key => true
      t.string :token, :null => false
      t.string :ip, :null => false

      t.timestamps
    end

    add_index :sessions, :token, :unique => true, :using => :hash
  end
end
