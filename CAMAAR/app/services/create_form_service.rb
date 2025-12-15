# Service responsável por criar formulários a partir de template e curso 
class CreateFormService

    # Classes de erro customizadas
    class Error < StandardError; end
    # Classe de erro para template ausente
    class MissingTemplate < Error; end
    # Classe de erro para turmas ausentes
    class MissingCourses < Error; end

    def self.call(**args)
      new(**args).call
    end

    def initialize(admin:, template_id:, course_ids:)
      @admin = admin
      @template_id = template_id
      @course_ids = Array(course_ids).reject(&:blank?)
    end

    # Método principal para criar formulários
    # Valida os dados antes de realizar a criação
    # Também cria as solicitações de formulário aos usuários envolvidos
    def call
      validate!
      create_forms
      true
    end

    # Cria formulários para todas as turmas selecionadas
    def create_forms
        ActiveRecord::Base.transaction do
            courses.each { |course| create_form_for(course) }
        end
    end

    # Cria um formulário para uma turma específica
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
    def validate!
      raise MissingTemplate, "Template não selecionado" if template_id.blank?
      raise MissingCourses, "Nenhuma turma selecionada" if course_ids.empty?
    end

    def template
      @template ||= Template.find(template_id)
    end

    def courses
      @courses ||= Course.where(id: course_ids).tap do |found|
        raise MissingCourses, "Nenhuma turma válida selecionada" if found.empty?
      end
    end

    # Cria solicitações de formulário para todos os alunos e o professor da turma
    def create_requests(form, course)
      recipients = course.students.to_a
      teacher = course.teacher
      recipients << teacher if teacher.present?

      recipients.each do |user|
        FormRequest.find_or_create_by!(user: user, form: form)
      end
    end
end