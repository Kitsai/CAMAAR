# Template reutilizável de formulários criado por admin
# Contém um QuestionSet que pode ser usado para criar múltiplos Forms
class Template < ApplicationRecord
  belongs_to :admin
  belongs_to :question_set

  accepts_nested_attributes_for :question_set

  validates :name, presence: true
  validates :question_set, presence: true
  validate :question_set_must_have_questions

  private

  def question_set_must_have_questions
    return unless question_set

    if question_set.data.blank? || question_set.data.empty?
      errors.add(:question_set, "must have at least one question")
    end
  end
end
