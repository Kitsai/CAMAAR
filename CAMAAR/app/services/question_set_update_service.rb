# Service responsável por atualizar o question_set de um template.
#
# Este service implementa copy-on-write: se o question_set já está sendo usado
# por forms existentes, cria uma cópia antes de atualizar.
class QuestionSetUpdateService
  # Inicializa o service com o template e os novos dados do question_set.
  #
  # Parâmetros:
  #   template: Template a ser atualizado
  #   question_set_data: Novos dados do question_set (array JSON)
  def initialize(template, question_set_data)
    @template = template
    @question_set_data = question_set_data
  end

  # Executa a atualização do question_set.
  #
  # Se o question_set já está em uso por forms, cria uma cópia antes de atualizar.
  # Caso contrário, atualiza o question_set existente.
  #
  # Este método não recebe argumentos.
  #
  # Retorna um hash com { success: true, template: template atualizado }.
  #
  # Efeitos colaterais: Pode criar um novo QuestionSet ou atualizar o existente.
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

  # Verifica se o question_set já está sendo usado por forms.
  #
  # Este método não recebe argumentos.
  #
  # Este método retorna um valor booleano: true se deve criar uma cópia, false caso contrário.
  #
  # Este método não possui efeitos colaterais.
  def should_copy_on_write?
    @template.question_set.forms.exists?
  end

  # Cria um novo question_set e associa ao template.
  #
  # Este método não recebe argumentos.
  #
  # Este método não retorna valor.
  #
  # Efeitos colaterais: Cria um novo QuestionSet e atualiza o template.
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
