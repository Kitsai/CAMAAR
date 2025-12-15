module ImportServiceHelpers
  def create_import_service(classes_path: nil, members_path: nil)
    classes_path ||= Rails.root.join('spec/fixtures/test_classes.json')
    members_path ||= Rails.root.join('spec/fixtures/test_class_members.json')
    JsonImportService.new(classes_path: classes_path, members_path: members_path)
  end

  def expect_import_statistics(result, **stats)
    expect(result[:success]).to be true
    stats.each do |key, value|
      expect(result[:data][key]).to eq(value) if value
    end
  end

  def expect_import_error(result, message_fragment)
    expect(result[:success]).to be false
    expect(result[:error]).to include(message_fragment)
  end

  def create_temp_json_file(basename, content)
    path = Rails.root.join("spec/fixtures/temp_#{basename}.json")
    File.write(path, JSON.generate(content))
    path
  end

  def cleanup_temp_files(*paths)
    paths.each { |path| FileUtils.rm_f(path) }
  end

  def find_course(code:, class_code: nil, semester: nil)
    conditions = { code: code }
    conditions[:classCode] = class_code if class_code
    conditions[:semester] = semester if semester
    Course.find_by(conditions)
  end

  def expect_course_created(code:, name: nil, class_code: nil, semester: nil, teacher_email: nil)
    course = find_course(code: code, class_code: class_code, semester: semester)
    expect(course).to be_present
    expect(course.name).to eq(name) if name
    expect(course.teacher.email).to eq(teacher_email) if teacher_email
  end

  def expect_user_count_by_email(email, expected_count)
    users = User.where(email: email)
    expect(users.count).to eq(expected_count)
    users
  end

  def expect_user_attribute(email, attribute, value)
    user = User.find_by(email: email)
    expect(user.send(attribute)).to eq(value)
  end

  def expect_successful_import_with_stat_gt(result, stat_key, min_value = 0)
    expect(result[:success]).to be true
    expect(result[:data][stat_key]).to be > min_value
  end

  def expect_successful_import_with_stat_gte(result, stat_key, min_value)
    expect(result[:success]).to be true
    expect(result[:data][stat_key]).to be >= min_value
  end

  def call_and_expect_success(service)
    result = service.call
    expect(result[:success]).to be true
    result
  end

  def build_simple_class_data(code, name, class_code, semester, time)
    {
      "code" => code,
      "name" => name,
      "class" => {
        "classCode" => class_code,
        "semester" => semester,
        "time" => time
      }
    }
  end

  def build_simple_members_data(code, class_code, semester, teacher_data, students_data)
    {
      "code" => code,
      "classCode" => class_code,
      "semester" => semester,
      "docente" => teacher_data,
      "dicente" => students_data
    }
  end

  def build_teacher_data(name, email)
    { "nome" => name, "email" => email }
  end

  def build_student_data(name, email)
    { "nome" => name, "email" => email }
  end
end

RSpec.configure do |config|
  config.include ImportServiceHelpers, type: :service
end
