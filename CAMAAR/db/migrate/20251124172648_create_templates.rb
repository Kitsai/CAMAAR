class CreateTemplates < ActiveRecord::Migration[8.1]
  def change
    create_table :templates do |t|
      t.references :question_set, null: false, foreign_key: { to_table: :question_sets }
      t.references :admin, null: false, foreign_key: { to_table: :admins }

      t.timestamps
    end
  end
end
