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

puts "Seeds completed successfully!"
