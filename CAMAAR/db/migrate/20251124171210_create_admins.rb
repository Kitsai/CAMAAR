class CreateAdmins < ActiveRecord::Migration[8.1]
  def change
    create_table :admins, id: false do |t|
      t.integer :user_id, null: false, primary_key: true

      t.timestamps
    end

    add_foreign_key :admins, :users, column: :user_id
    add_index :admins, :user_id, unique: true
  end
end
