module ImportServiceHelpers
  def create_import_service(classes_path: nil, members_path: nil)
    classes_path ||= Rails.root.join('spec/fixtures/test_classes.json')
    members_path ||= Rails.root.join('spec/fixtures/test_class_members.json')
    JsonImportService.new(classes_path: classes_path, members_path: members_path)
  end

  def expect_import_statistics(result, users_created: nil, courses_created: nil,
                                enrollments_created: nil, users_skipped: nil, courses_skipped: nil)
    expect(result[:success]).to be true
    expect(result[:data][:users_created]).to eq(users_created) if users_created
    expect(result[:data][:courses_created]).to eq(courses_created) if courses_created
    expect(result[:data][:enrollments_created]).to eq(enrollments_created) if enrollments_created
    expect(result[:data][:users_skipped]).to eq(users_skipped) if users_skipped
    expect(result[:data][:courses_skipped]).to eq(courses_skipped) if courses_skipped
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
