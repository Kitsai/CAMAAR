# app/controllers/courses_controller.rb
class CoursesController < ApplicationController
  before_action :require_login
  before_action :set_course, only: [:show, :import_members]
  before_action :require_teacher!, only: [:new, :create, :import_members]

  def index
    # mostra todas as turmas
    @courses = Course.order(:name)
  end

  def show
    # eager-load forms & students
    @course = Course.includes(:students, :forms).find(params[:id])
  end

  def new
    @course = Course.new
  end

  def create
    # o teacher é o current_user
    @course = current_user.taught_courses.build(course_params)
    if @course.save
      redirect_to turmas_path, notice: "Turma criada com sucesso."
    else
      flash.now[:alert] = "Erro ao criar turma."
      render :new, status: :unprocessable_entity
    end
  end

  # POST /turmas/:id/import_members
  # Recebe um arquivo JSON no param :members_file
  # Suporta:
  #  - array de strings/emails
  #  - array de objetos { "email": ..., "name": ... }
  #  - o JSON complexo que você enviou (array de cursos com keys: code, classCode, semester, dicente, docente)
  def import_members
    uploaded = params[:members_file]
    unless uploaded
      redirect_to turma_path(@course), alert: "Nenhum arquivo selecionado."
      return
    end

    begin
      content = uploaded.read
      data = JSON.parse(content)
    rescue JSON::ParserError
      redirect_to turma_path(@course), alert: "Arquivo JSON inválido."
      return
    end

    # Se o JSON for um array de "course objects" (como seu class_members.json),
    # encontramos a entrada que corresponde a esta turma (match por code + classCode ou code + semester)
    if data.is_a?(Array) && data.first.is_a?(Hash) && (data.first.key?('code') || data.first.key?('dicente'))
      # tentar localizar a entrada que corresponde à @course
      match = data.find do |entry|
        next false unless entry.is_a?(Hash)
        code_matches = entry['code'].present? && @course.code.present? && entry['code'].to_s.strip.casecmp(@course.code.to_s.strip) == 0
        classcode_matches = entry['classCode'].present? && @course.classCode.present? && entry['classCode'].to_s.strip.casecmp(@course.classCode.to_s.strip) == 0
        semester_matches = entry['semester'].present? && @course.semester.present? && entry['semester'].to_s.strip == @course.semester.to_s.strip
        # prefer code+classCode, fallback to code+semester or single code
        (code_matches && classcode_matches) || (code_matches && semester_matches) || code_matches
      end

      unless match
        # se não encontramos correspondente, talvez o arquivo contém apenas 1 curso que deveria ser importado aqui:
        match = data.first if data.size == 1 && data.first.is_a?(Hash)
      end

      if match
        # se existe docente, cria/atualiza teacher e associa à turma (somente se current_user for teacher/admin)
        if match['docente'].is_a?(Hash) && match['docente']['email'].present?
          teacher_email = match['docente']['email'].strip.downcase
          teacher_name  = match['docente']['nome'] || match['docente']['name']
          teacher = User.find_by(email: teacher_email)
          if teacher.nil?
            # cria professor caso não exista
            password = SecureRandom.hex(8)
            teacher = User.create!(email: teacher_email, name: teacher_name, password: password, role: 'teacher')
          else
            # garante role teacher (não sobrescreve se admin)
            teacher.update!(role: 'teacher') unless teacher.admin? || teacher.teacher?
          end

          # associa à turma se ainda não estiver associada
          if @course.teacher_id != teacher.id
            @course.update!(teacher: teacher)
          end
        end

        students_array = match['dicente'] || match['students'] || []
      else
        # nenhum match — não temos dados para importar
        redirect_to turma_path(@course), alert: "Nenhuma entrada correspondente à turma encontrada no JSON."
        return
      end

    else
      # formato simples: array de emails ou array de hashes { "email": ..., "name": ... }
      students_array = data
    end

    added = 0
    ActiveRecord::Base.transaction do
      Array(students_array).each do |entry|
        if entry.is_a?(String)
          email = entry.strip.downcase
          name  = nil
        elsif entry.is_a?(Hash)
          # Adaptar para o formato do seu JSON: 'nome' / 'email' / 'usuario' / 'matricula'
          email = (entry['email'] || entry['usuario'] || entry['matricula']).to_s.strip.downcase
          name  = entry['nome'] || entry['name']
        else
          next
        end

        next unless email.present?

        user = User.find_by(email: email)
        if user.nil?
          # cria usuário aluno com senha aleatória
          password = SecureRandom.hex(8)
          user = User.create!(email: email, name: name, password: password, role: 'student')
        else
          # se user já existir e não for teacher/admin, garante role student
          user.update!(role: 'student') unless user.admin? || user.teacher?
        end

        # cria enrollment se não existir
        unless @course.students.exists?(user.id)
          @course.enrollments.create!(student: user)
          added += 1
        end
      end
    end

    redirect_to turma_path(@course), notice: "Importação concluída — #{added} membros adicionados."
  end

  private

  def set_course
    @course = Course.find(params[:id])
  end

  def course_params
    params.require(:course).permit(:name, :code, :semester, :classCode)
  end

  def require_teacher!
    unless current_user&.teacher? || current_user&.admin?
      redirect_to root_path, alert: "Você não tem permissão para realizar essa ação."
    end
  end
end