class AddQuestionSetTriggers < ActiveRecord::Migration[8.1]
  def up
    # Trigger 1: Cleanup orphaned question_sets after template deletion
    execute <<-SQL
      CREATE TRIGGER cleanup_question_set_after_template_delete
      AFTER DELETE ON templates
      FOR EACH ROW
      WHEN (
        NOT EXISTS (SELECT 1 FROM templates WHERE question_set_id = OLD.question_set_id)
        AND NOT EXISTS (SELECT 1 FROM forms WHERE question_set_id = OLD.question_set_id)
      )
      BEGIN
        DELETE FROM question_sets WHERE id = OLD.question_set_id;
      END;
    SQL

    # Trigger 2: Cleanup orphaned question_sets after form deletion
    execute <<-SQL
      CREATE TRIGGER cleanup_question_set_after_form_delete
      AFTER DELETE ON forms
      FOR EACH ROW
      WHEN (
        NOT EXISTS (SELECT 1 FROM templates WHERE question_set_id = OLD.question_set_id)
        AND NOT EXISTS (SELECT 1 FROM forms WHERE question_set_id = OLD.question_set_id)
      )
      BEGIN
        DELETE FROM question_sets WHERE id = OLD.question_set_id;
      END;
    SQL
  end

  def down
    execute "DROP TRIGGER IF EXISTS cleanup_question_set_after_template_delete"
    execute "DROP TRIGGER IF EXISTS cleanup_question_set_after_form_delete"
  end
end
