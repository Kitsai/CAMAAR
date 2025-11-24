class QuestionSet < ApplicationRecord
  has_one :template
  has_many :forms

  before_update :copy_on_write_if_used_by_forms

  private

  def copy_on_write_if_used_by_forms
    # If any forms are using this question_set, create a copy instead of updating
    return unless forms.exists?

    # Create a new question_set with current attributes
    new_qs = self.class.new(attributes.except("id", "created_at", "updated_at"))

    # Apply the pending changes to the new record
    changes.each do |attr, (old_val, new_val)|
      new_qs.send("#{attr}=", new_val)
    end

    # Save the new question_set
    new_qs.save!

    # Update the template to point to the new question_set
    template&.update(question_set_id: new_qs.id)

    # Prevent the original update (keep old version for forms)
    throw :abort
  end
end
