# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create default admin user
admin_user = User.find_by(email: 'admin@camaar.com')
unless admin_user
  admin_user = User.create!(
    email: 'admin@camaar.com',
    password: 'admin123',
    password_confirmation: 'admin123',
    name: 'Admin User'
  )

  Admin.create!(user: admin_user)

  puts "✓ Created admin user: admin@camaar.com / admin123"
end

# Create sample templates for development
if Rails.env.development? && Admin.exists?
  admin = Admin.first

  unless Template.exists?(name: 'Student Feedback Form')
    question_set = QuestionSet.create!(
      data: [
        { question: "How would you rate this course?", type: "rating" },
        { question: "What did you like most about this course?", type: "text" },
        { question: "What could be improved?", type: "text" }
      ]
    )

    Template.create!(
      name: 'Student Feedback Form',
      admin: admin,
      question_set: question_set
    )

    puts "✓ Created sample template: Student Feedback Form"
  end

  unless Template.exists?(name: 'Course Evaluation')
    question_set = QuestionSet.create!(
      data: [
        { question: "Rate the instructor's teaching", type: "rating" },
        { question: "Was the course material clear?", type: "boolean" },
        { question: "Additional comments", type: "text" }
      ]
    )

    Template.create!(
      name: 'Course Evaluation',
      admin: admin,
      question_set: question_set
    )

    puts "✓ Created sample template: Course Evaluation"
  end

  # Create sample courses and forms
  unless Course.exists?(code: 'CS101')
    teacher_user = User.find_or_create_by!(email: 'teacher@camaar.com') do |u|
      u.password = 'teacher123'
      u.password_confirmation = 'teacher123'
      u.name = 'Professor João Silva'
    end

    course1 = Course.create!(
      name: 'Introdução à Programação',
      code: 'CS101',
      classCode: 'A',
      semester: '2024.2',
      teacher: teacher_user
    )

    course2 = Course.create!(
      name: 'Estruturas de Dados',
      code: 'CS201',
      classCode: 'B',
      semester: '2024.2',
      teacher: teacher_user
    )

    course3 = Course.create!(
      name: 'Banco de Dados',
      code: 'CS301',
      classCode: 'A',
      semester: '2024.2',
      teacher: teacher_user
    )

    # Create a course where admin_user will be enrolled as student
    course4 = Course.create!(
      name: 'Álgebra Linear',
      code: 'MAT101',
      classCode: 'A',
      semester: '2024.2',
      teacher: teacher_user
    )

    puts "✓ Created sample courses"

    # Create forms using existing templates
    template = Template.first
    if template
      form1 = Form.create!(
        admin: admin,
        course: course1,
        question_set: template.question_set
      )

      form2 = Form.create!(
        admin: admin,
        course: course2,
        question_set: template.question_set
      )

      form3 = Form.create!(
        admin: admin,
        course: course3,
        question_set: template.question_set
      )

      # Create form for course4 where admin will respond
      form4 = Form.create!(
        admin: admin,
        course: course4,
        question_set: template.question_set
      )

      puts "✓ Created sample forms for courses"

      # Create sample students and assign forms to them
      student1 = User.find_or_create_by!(email: 'student1@camaar.com') do |u|
        u.password = 'student123'
        u.password_confirmation = 'student123'
        u.name = 'Maria Santos'
      end

      student2 = User.find_or_create_by!(email: 'student2@camaar.com') do |u|
        u.password = 'student123'
        u.password_confirmation = 'student123'
        u.name = 'Pedro Oliveira'
      end

      # Enroll students in courses
      Enrollment.find_or_create_by!(student: student1, course: course1)
      Enrollment.find_or_create_by!(student: student1, course: course2)
      Enrollment.find_or_create_by!(student: student2, course: course2)
      Enrollment.find_or_create_by!(student: student2, course: course3)

      # Enroll admin_user in course4 as a student
      Enrollment.find_or_create_by!(student: admin_user, course: course4)

      # Create form requests (assign forms to students)
      FormRequest.find_or_create_by!(user: student1, form: form1)
      FormRequest.find_or_create_by!(user: student1, form: form2)
      FormRequest.find_or_create_by!(user: student2, form: form2)
      FormRequest.find_or_create_by!(user: student2, form: form3)

      # Assign forms to teachers (they also evaluate their courses)
      FormRequest.find_or_create_by!(user: teacher_user, form: form1)
      FormRequest.find_or_create_by!(user: teacher_user, form: form2)
      FormRequest.find_or_create_by!(user: teacher_user, form: form3)

      # Assign form4 to admin_user (enrolled in course4)
      FormRequest.find_or_create_by!(user: admin_user, form: form4)

      puts "✓ Created sample students and form assignments"
    end
  end
end

puts "Seeds completed successfully!"
