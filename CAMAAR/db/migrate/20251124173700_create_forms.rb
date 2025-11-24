class CreateForms < ActiveRecord::Migration[8.1]
  def change
    create_table :forms do |t|
      t.references :admin, null: false, foreign_key: { to_table: :admins }
      t.references :course, null: false, foreign_key: { to_table: :courses }
      t.references :question_set, null: false, foreign_key: { to_table: :question_sets }

      t.timestamps
    end
  end
end
