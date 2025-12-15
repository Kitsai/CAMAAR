require 'rails_helper'

RSpec.describe JsonImportService, type: :service do
  let(:classes_file) { Rails.root.join('spec/fixtures/test_classes.json') }
  let(:members_file) { Rails.root.join('spec/fixtures/test_class_members.json') }
  let(:invalid_file) { Rails.root.join('spec/fixtures/invalid.json') }

  describe '#call' do
    context 'with valid JSON files' do
      let(:service) { described_class.new(classes_path: classes_file, members_path: members_file) }

      it 'returns success result' do
        result = service.call
        expect(result[:success]).to be true
      end

      it 'creates new teacher users' do
        expect {
          service.call
        }.to change { User.where(email: ['prof.test@example.com', 'prof2@example.com']).count }.by(2)
      end

      it 'creates new student users' do
        expect {
          service.call
        }.to change { User.where(email: ['student1@example.com', 'student2@example.com', 'student3@example.com']).count }.by(3)
      end

      it 'creates courses with correct attributes' do
        service.call

        expect_course_created(code: 'TEST001', name: 'Test Course 1', class_code: 'TA', semester: '2024.1')
        expect_course_created(code: 'TEST002', name: 'Test Course 2', class_code: 'TB', semester: '2024.1')
      end

      it 'creates enrollments linking students to courses' do
        expect {
          service.call
        }.to change { Enrollment.count }.by(3)
      end

      it 'returns import statistics' do
        result = service.call
        expect_import_statistics(result,
          users_created: 5,
          courses_created: 2,
          enrollments_created: 3,
          users_skipped: 0,
          courses_skipped: 0
        )
      end

      it 'creates users with nil password_digest' do
        service.call

        user = User.find_by(email: 'prof.test@example.com')
        expect(user.password_digest).to be_nil
      end

      it 'assigns teachers to courses correctly' do
        service.call

        course1 = Course.find_by(code: 'TEST001')
        teacher = User.find_by(email: 'prof.test@example.com')

        expect(course1.teacher).to eq(teacher)
      end

      it 'teachers are NOT admins' do
        service.call

        teacher = User.find_by(email: 'prof.test@example.com')
        expect(teacher.admin?).to be false
      end

      context 'with duplicate users' do
        before do
          User.create!(email: 'student1@example.com', name: 'Existing Student', password: nil)
        end

        it 'reuses existing users by email' do
          service.call

          users = expect_user_count_by_email('student1@example.com', 1)
          expect_user_attribute('student1@example.com', :name, 'Existing Student')
        end

        it 'does not create duplicate users' do
          expect {
            service.call
          }.to change { User.count }.by(4)
        end

        it 'reports skipped duplicates in statistics' do
          result = service.call
          expect_import_statistics(result,
            users_created: 4,
            users_skipped: 1
          )
        end
      end

      context 'with duplicate courses' do
        let!(:teacher) { create(:user, email: 'prof.test@example.com', password: nil) }
        let!(:existing_course) { create(:course, code: 'TEST001', classCode: 'TA', semester: '2024.1', teacher: teacher) }

        it 'skips duplicate courses (same code + classCode + semester)' do
          service.call

          courses = Course.where(code: 'TEST001', classCode: 'TA', semester: '2024.1')
          expect(courses.count).to eq(1)
        end

        it 'reports skipped courses in statistics' do
          result = service.call
          expect_import_statistics(result,
            courses_created: 1,
            courses_skipped: 1
          )
        end
      end
    end

    context 'with missing files' do
      it 'returns error when classes.json is missing' do
        service = create_import_service(classes_path: '/nonexistent/classes.json', members_path: members_file)
        result = service.call

        expect_import_error(result, 'Classes file not found')
      end

      it 'succeeds when class_members.json is missing (members file is optional)' do
        service = create_import_service(classes_path: classes_file, members_path: '/nonexistent/members.json')
        result = service.call

        expect(result[:success]).to be true
      end

      it 'creates courses with placeholder teacher when members file is missing' do
        service = create_import_service(classes_path: classes_file, members_path: '/nonexistent/members.json')
        result = service.call

        expect_import_statistics(result, courses_created: 2)
        expect(User.find_by(email: 'placeholder.teacher@example.com')).to be_present
        expect_course_created(code: 'TEST001', name: nil, teacher_email: 'placeholder.teacher@example.com')
      end

      it 'creates no enrollments when members file is missing' do
        service = create_import_service(classes_path: classes_file, members_path: '/nonexistent/members.json')
        result = service.call

        expect_import_statistics(result, enrollments_created: 0)
      end
    end

    context 'with invalid JSON' do
      it 'returns error when JSON is malformed' do
        service = create_import_service(classes_path: invalid_file, members_path: members_file)
        result = service.call

        expect_import_error(result, 'Invalid JSON')
      end
    end

    context 'with missing required fields' do
      let(:incomplete_members_file) { Rails.root.join('spec/fixtures/incomplete_members.json') }

      before do
        File.write(incomplete_members_file, JSON.generate([
          {
            "code": "TEST001",
            "classCode": "TA",
            "semester": "2024.1",
            "docente": {
              "nome": "Professor No Email"
            },
            "dicente": [
              {
                "nome": "Student With Email",
                "email": "valid@example.com"
              },
              {
                "nome": "Student No Email"
              }
            ]
          }
        ]))
      end

      after do
        FileUtils.rm_f(incomplete_members_file)
      end

      it 'handles missing teacher email gracefully (skips course)' do
        service = create_import_service(classes_path: classes_file, members_path: incomplete_members_file)
        result = service.call

        expect_successful_import_with_stat_gt(result, :courses_skipped)
      end

      it 'handles missing student email gracefully (skips student)' do
        classes_data = [
          {
            "code" => "TEST001",
            "name" => "Test Course",
            "class" => {
              "classCode" => "TA",
              "semester" => "2024.1",
              "time" => "35T45"
            }
          }
        ]

        members_data = [
          {
            "code" => "TEST001",
            "classCode" => "TA",
            "semester" => "2024.1",
            "docente" => {
              "nome" => "Valid Prof",
              "email" => "validprof@example.com"
            },
            "dicente" => [
              {
                "nome" => "Valid Student",
                "email" => "validstudent@example.com"
              },
              {
                "nome" => "Invalid Student"
              }
            ]
          }
        ]

        classes_file = create_temp_json_file('classes_missing_student', classes_data)
        members_file = create_temp_json_file('members_missing_student', members_data)

        service = create_import_service(classes_path: classes_file, members_path: members_file)
        result = service.call

        expect_import_statistics(result, enrollments_created: 1)

        cleanup_temp_files(classes_file, members_file)
      end

      it 'continues processing remaining valid records' do
        service = create_import_service(classes_path: classes_file, members_path: incomplete_members_file)
        result = service.call

        expect_successful_import_with_stat_gte(result, :courses_created, 0)
      end
    end

    context 'with orphaned courses' do
      let(:orphaned_classes_file) { Rails.root.join('spec/fixtures/orphaned_classes.json') }

      before do
        File.write(orphaned_classes_file, JSON.generate([
          {
            "code": "ORPHAN001",
            "name": "Orphaned Course",
            "class": {
              "classCode": "TA",
              "semester": "2024.1",
              "time": "35T45"
            }
          }
        ]))
      end

      after do
        FileUtils.rm_f(orphaned_classes_file)
      end

      it 'creates courses without matching member data using placeholder teacher' do
        service = create_import_service(classes_path: orphaned_classes_file, members_path: members_file)
        result = service.call

        expect(result[:success]).to be true
        expect_course_created(code: 'ORPHAN001', name: nil, teacher_email: 'placeholder.teacher@example.com')
      end

      it 'creates courses with no enrollments when no matching members' do
        service = create_import_service(classes_path: orphaned_classes_file, members_path: members_file)
        result = service.call

        orphan_course = find_course(code: 'ORPHAN001')
        expect(orphan_course.students.count).to eq(0)
      end
    end
  end
end
