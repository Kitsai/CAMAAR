# Service responsável por criar formulários a partir de um template
# e associá-los às turmas selecionadas.
#
# Este service também cria solicitações de formulário (FormRequest)
# para todos os alunos e para o professor de cada turma.
class CreateFormService

    # Classes de base para erros do service
    class Error < StandardError; end
    # Erro levantado quando nenhum template é selecionado
    class MissingTemplate < Error; end
    # Erro levantado quando nenhuma turma é selecionada
    class MissingCourses < Error; end

    def self.call(**args)
      new(**args).call
    end


    # Inicializa o service com os parâmetros necessários
    #
    # Parâmetros:
    #   admin: Usuário administrador que está criando os formulários
    #   template_id: ID do template a partir do qual os formulários serão criados
    #   course_ids: Array de IDs das turmas para as quais os formulários serão criados
    def initialize(admin:, template_id:, course_ids:)
      @admin = admin
      @template_id = template_id
      @course_ids = Array(course_ids).reject(&:blank?)
    end

    
    # Método principal do service
    #
    # Valida os dados de entrada e cria os formulários para as turmas.
    # Também cria as solicitações de formulário para alunos e professores.
    #
    # Retorno: true se a operação for concluída com sucesso
    # Levanta erro se o template não for informado
    # Levanta erro se nenhuma turma válida for informada
    #
    # Efeito Colateral: Cria registros nas tabelas Form e FormRequest
    def call
      validate!
      create_forms
      true
    end

    # Cria formulários para todas as turmas selecionadas
    #
    # Efeito Colateral: Cria registros na tabela Form
    def create_forms
        ActiveRecord::Base.transaction do
            courses.each { |course| create_form_for(course) }
        end
    end

    # Cria um formulário para uma turma específica
    # Recebe a turma para qual o formulário será criado como parâmetro
    #
    # Efeito Colateral: 
    #       - Cria um registro na tabela Form
    #       - Cria registros na tabela FormRequest
    def create_form_for(course)
        form = Form.create!(
            question_set: template.question_set,
            course: course,
            admin: admin
        )
        create_requests(form, course)
    end

    private

    attr_reader :admin, :template_id, :course_ids

    # Valida a presença do template e das turmas
    #
    # Levanta MissingTemplate se o template não for informado
    # Levanta MissingCourses se nenhuma turma for informada
    def validate!
      raise MissingTemplate, "Template não selecionado" if template_id.blank?
      raise MissingCourses, "Nenhuma turma selecionada" if course_ids.empty?
    end

    # Busca o template pelo ID fornecido
    def template
      @template ||= Template.find(template_id)
    end

    # Busca as turmas pelos IDs fornecidos
    #
    # Levanta MissingCourses se nenhuma turma válida for encontrada
    def courses
      @courses ||= Course.where(id: course_ids).tap do |found|
        raise MissingCourses, "Nenhuma turma válida selecionada" if found.empty?
      end
    end

    # Cria solicitações de formulário para todos os alunos e o professor da turma
    # Recebe o formulário e a turma como parâmetros
    #
    # Efeito Colateral: Cria registros na tabela FormRequest
    def create_requests(form, course)
      recipients = course.students.to_a
      teacher = course.teacher
      recipients << teacher if teacher.present?

      recipients.each do |user|
        FormRequest.find_or_create_by!(user: user, form: form)
      end
    end
end