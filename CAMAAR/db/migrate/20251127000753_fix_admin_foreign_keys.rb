class FixAdminForeignKeys < ActiveRecord::Migration[8.1]
  def change
    # Remove existing incorrect foreign keys
    remove_foreign_key :templates, :admins
    remove_foreign_key :forms, :admins

    # Add correct foreign keys that reference user_id (the actual primary key of admins)
    add_foreign_key :templates, :admins, primary_key: :user_id
    add_foreign_key :forms, :admins, primary_key: :user_id
  end
end
