# Service para atualizar QuestionSet de templates
# Implementa copy-on-write quando QuestionSet é usado por outros templates
class QuestionSetUpdateService
  def initialize(template, question_set_data)
    @template = template
    @question_set_data = question_set_data
  end

  def call
    return success_result unless @question_set_data

    if should_copy_on_write?
      create_new_question_set
    else
      update_existing_question_set
    end

    @template.reload
    success_result
  end

  private

  # Verifica se QuestionSet já está em uso por formulários
  # Se sim, cria cópia para não afetar respostas já submetidas
  def should_copy_on_write?
    @template.question_set.forms.exists?
  end

  def create_new_question_set
    new_qs = QuestionSet.create!(data: @question_set_data)
    @template.update!(question_set_id: new_qs.id)
  end

  def update_existing_question_set
    @template.question_set.update!(data: @question_set_data)
  end

  def success_result
    {
      success: true,
      template: @template
    }
  end
end
