class QuestionSet < ApplicationRecord
  has_one :template
  has_many :forms

  validate :data_must_be_valid_json_array

  before_update :copy_on_write_if_used_by_forms

  private

  def data_must_be_valid_json_array
    if data.nil?
      errors.add(:data, "can't be blank")
      return
    end

    unless data.is_a?(Array)
      errors.add(:data, "must be a non-empty array of questions")
      return
    end

    if data.empty?
      errors.add(:data, "must be a non-empty array of questions")
    end
  end

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
    # Use direct query instead of association to avoid caching issues
    tmpl = Template.find_by(question_set_id: id)
    tmpl&.update_column(:question_set_id, new_qs.id)

    # Prevent the original update (keep old version for forms)
    throw :abort
  end
end
