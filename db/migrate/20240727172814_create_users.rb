class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :login, :null => false, :unique => true
      t.string :password_digest, :null => false
      t.string :name, :null => false

      t.timestamps
    end
  end
end
