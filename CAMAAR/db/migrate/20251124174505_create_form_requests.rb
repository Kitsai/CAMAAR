class CreateFormRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :form_requests, id: false do |t|
      t.references :user, null: false, foreign_key: { to_table: :users }
      t.references :form, null: false, foreign_key: { to_table: :forms }

      t.timestamps
    end

    add_index :form_requests, [ :user_id, :form_id ], unique: true
  end
end
