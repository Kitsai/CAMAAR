class CreateEnrollments < ActiveRecord::Migration[8.1]
  def change
    create_table :enrollments, id: false do |t|
      t.references :student, null: false, foreign_key: { to_table: :users }
      t.references :course, null: false, foreign_key: { to_table: :courses }

      t.timestamps
    end

    add_index :enrollments, [ :student_id, :course_id ], unique: true
  end
end
