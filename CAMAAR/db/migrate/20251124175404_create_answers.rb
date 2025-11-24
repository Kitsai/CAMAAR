class CreateAnswers < ActiveRecord::Migration[8.1]
  def change
    create_table :answers do |t|
      t.text :data
      t.references :form, null: false, foreign_key: { to_table: :forms }

      t.timestamps
    end
  end
end
