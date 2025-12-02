# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create default admin user
unless User.exists?(email: 'admin@camaar.com')
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
end

puts "Seeds completed successfully!"
