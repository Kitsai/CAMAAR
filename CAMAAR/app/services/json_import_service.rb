class JsonImportService
  def initialize(classes_path: nil, members_path: nil)
    @classes_path = classes_path || Rails.root.join('..', 'classes.json')
    @members_path = members_path || Rails.root.join('..', 'class_members.json')
    @stats = initialize_stats
  end

  def call
    # Validation phase
    return error_result("Classes file not found") unless File.exist?(@classes_path)

    # Parsing phase
    classes_data = parse_json_file(@classes_path)
    return classes_data unless classes_data[:success]

    # Members file is optional
    members_data = if @members_path && File.exist?(@members_path)
      result = parse_json_file(@members_path)
      return result unless result[:success]
      result[:data]
    else
      []
    end

    # Import phase (NO transaction wrapper - process each record independently)
    import_data(classes_data[:data], members_data)

    success_result
  rescue => e
    error_result("Import failed: #{e.message}")
  end

  private

  def initialize_stats
    {
      users_created: 0,
      users_skipped: 0,
      courses_created: 0,
      courses_skipped: 0,
      enrollments_created: 0,
      errors: []
    }
  end

  def parse_json_file(path)
    data = JSON.parse(File.read(path))
    { success: true, data: data }
  rescue JSON::ParserError => e
    error_result("Invalid JSON in #{File.basename(path)}: #{e.message}")
  end

  def import_data(classes, members)
    # Build lookup hash: "code-classCode-semester" => members_entry
    members_lookup = build_members_lookup(members)

    classes.each do |class_entry|
      import_course(class_entry, members_lookup)
    end
  end

  def build_members_lookup(members)
    members.each_with_object({}) do |entry, hash|
      code = entry['code']
      class_code = entry['classCode']
      semester = entry['semester']

      next if [code, class_code, semester].any?(&:blank?)

      key = "#{code}-#{class_code}-#{semester}"
      hash[key] = entry
    end
  end

  def import_course(class_entry, members_lookup)
    code = class_entry['code']
    class_code = class_entry.dig('class', 'classCode')
    semester = class_entry.dig('class', 'semester')

    # Validate required fields
    if [code, class_code, semester].any?(&:blank?)
      skip_course("Missing code or class info")
      return
    end

    # Find matching members entry (optional)
    lookup_key = "#{code}-#{class_code}-#{semester}"
    members_entry = members_lookup[lookup_key]

    # Check for duplicate course
    if Course.exists?(code: code, classCode: class_code, semester: semester)
      @stats[:courses_skipped] += 1
      return
    end

    # Create/find teacher (from members if available, otherwise create placeholder)
    teacher = if members_entry && members_entry['docente']
      find_or_create_user(members_entry['docente'])
    else
      # Create a placeholder teacher if no members data
      find_or_create_placeholder_teacher
    end

    unless teacher
      skip_course("Missing teacher for #{code}")
      return
    end

    # Create course
    course = Course.create!(
      code: code,
      name: class_entry['name'],
      classCode: class_code,
      semester: semester,
      teacher: teacher
    )
    @stats[:courses_created] += 1

    # Create student enrollments (only if members_entry exists)
    if members_entry
      import_enrollments(course, members_entry['dicente'] || [])
    end
  rescue => e
    skip_course("Error importing #{code}: #{e.message}")
  end

  def import_enrollments(course, students)
    students.each do |student_data|
      student = find_or_create_user(student_data)
      next unless student

      # Skip if already enrolled
      next if Enrollment.exists?(student_id: student.id, course_id: course.id)

      Enrollment.create!(student: student, course: course)
      @stats[:enrollments_created] += 1
    rescue => e
      @stats[:errors] << "Failed to enroll student #{student_data['email']}: #{e.message}"
    end
  end

  def find_or_create_user(user_data)
    return nil if user_data.nil? || user_data['email'].blank?

    email = user_data['email'].downcase.strip
    user = User.find_by(email: email)

    if user
      @stats[:users_skipped] += 1
      return user
    end

    # Create new user with nil password (integrates with password setup feature)
    user = User.create!(
      email: email,
      name: user_data['nome'] || email,
      password: nil
    )
    @stats[:users_created] += 1
    user
  rescue => e
    @stats[:errors] << "Failed to create user #{email}: #{e.message}"
    nil
  end

  def find_or_create_placeholder_teacher
    # Use a standard placeholder email for courses without teacher data
    placeholder_email = 'placeholder.teacher@example.com'
    user = User.find_by(email: placeholder_email)

    if user
      @stats[:users_skipped] += 1
      return user
    end

    user = User.create!(
      email: placeholder_email,
      name: 'Placeholder Teacher',
      password: nil
    )
    @stats[:users_created] += 1
    user
  rescue => e
    @stats[:errors] << "Failed to create placeholder teacher: #{e.message}"
    nil
  end

  def skip_course(reason)
    @stats[:courses_skipped] += 1
    @stats[:errors] << reason
  end

  def success_result
    {
      success: true,
      data: @stats
    }
  end

  def error_result(message)
    {
      success: false,
      error: message
    }
  end
end
