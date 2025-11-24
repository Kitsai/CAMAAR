class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users, id: false  do |t|
      t.integer :id, null: false, primary_key: true
      t.string :email, null: false
      t.string :name
      t.string :password_digest

      t.timestamps
    end

    add_index :users, :email, unique: true
  end
end
