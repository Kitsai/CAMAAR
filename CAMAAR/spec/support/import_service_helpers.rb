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
end

RSpec.configure do |config|
  config.include ImportServiceHelpers, type: :service
end
