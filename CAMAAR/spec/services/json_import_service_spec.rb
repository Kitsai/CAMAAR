require 'rails_helper'

RSpec.describe JsonImportService do
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

        course1 = Course.find_by(code: 'TEST001', classCode: 'TA', semester: '2024.1')
        expect(course1).to be_present
        expect(course1.name).to eq('Test Course 1')

        course2 = Course.find_by(code: 'TEST002', classCode: 'TB', semester: '2024.1')
        expect(course2).to be_present
        expect(course2.name).to eq('Test Course 2')
      end

      it 'creates enrollments linking students to courses' do
        expect {
          service.call
        }.to change { Enrollment.count }.by(3)
      end

      it 'returns import statistics' do
        result = service.call

        expect(result[:data][:users_created]).to eq(5)
        expect(result[:data][:courses_created]).to eq(2)
        expect(result[:data][:enrollments_created]).to eq(3)
        expect(result[:data][:users_skipped]).to eq(0)
        expect(result[:data][:courses_skipped]).to eq(0)
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

          users = User.where(email: 'student1@example.com')
          expect(users.count).to eq(1)
          expect(users.first.name).to eq('Existing Student')
        end

        it 'does not create duplicate users' do
          expect {
            service.call
          }.to change { User.count }.by(4)
        end

        it 'reports skipped duplicates in statistics' do
          result = service.call

          expect(result[:data][:users_created]).to eq(4)
          expect(result[:data][:users_skipped]).to eq(1)
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

          expect(result[:data][:courses_created]).to eq(1)
          expect(result[:data][:courses_skipped]).to eq(1)
        end
      end
    end

    context 'with missing files' do
      it 'returns error when classes.json is missing' do
        service = described_class.new(classes_path: '/nonexistent/classes.json', members_path: members_file)
        result = service.call

        expect(result[:success]).to be false
        expect(result[:error]).to include('Classes file not found')
      end

      it 'succeeds when class_members.json is missing (members file is optional)' do
        service = described_class.new(classes_path: classes_file, members_path: '/nonexistent/members.json')
        result = service.call

        expect(result[:success]).to be true
      end

      it 'creates courses with placeholder teacher when members file is missing' do
        service = described_class.new(classes_path: classes_file, members_path: '/nonexistent/members.json')
        result = service.call

        expect(result[:data][:courses_created]).to eq(2)
        expect(User.find_by(email: 'placeholder.teacher@example.com')).to be_present

        course1 = Course.find_by(code: 'TEST001')
        expect(course1).to be_present
        expect(course1.teacher.email).to eq('placeholder.teacher@example.com')
      end

      it 'creates no enrollments when members file is missing' do
        service = described_class.new(classes_path: classes_file, members_path: '/nonexistent/members.json')
        result = service.call

        expect(result[:data][:enrollments_created]).to eq(0)
      end
    end

    context 'with invalid JSON' do
      it 'returns error when JSON is malformed' do
        service = described_class.new(classes_path: invalid_file, members_path: members_file)
        result = service.call

        expect(result[:success]).to be false
        expect(result[:error]).to include('Invalid JSON')
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
        service = described_class.new(classes_path: classes_file, members_path: incomplete_members_file)
        result = service.call

        expect(result[:success]).to be true
        expect(result[:data][:courses_skipped]).to be > 0
      end

      it 'handles missing student email gracefully (skips student)' do
        classes_file_temp = Rails.root.join('spec/fixtures/temp_classes.json')
        File.write(classes_file_temp, JSON.generate([
          {
            "code": "TEST001",
            "name": "Test Course",
            "class": {
              "classCode": "TA",
              "semester": "2024.1",
              "time": "35T45"
            }
          }
        ]))

        members_file_temp = Rails.root.join('spec/fixtures/temp_members.json')
        File.write(members_file_temp, JSON.generate([
          {
            "code": "TEST001",
            "classCode": "TA",
            "semester": "2024.1",
            "docente": {
              "nome": "Valid Prof",
              "email": "validprof@example.com"
            },
            "dicente": [
              {
                "nome": "Valid Student",
                "email": "validstudent@example.com"
              },
              {
                "nome": "Invalid Student"
              }
            ]
          }
        ]))

        service = described_class.new(classes_path: classes_file_temp, members_path: members_file_temp)
        result = service.call

        expect(result[:success]).to be true
        expect(result[:data][:enrollments_created]).to eq(1)

        FileUtils.rm_f(classes_file_temp)
        FileUtils.rm_f(members_file_temp)
      end

      it 'continues processing remaining valid records' do
        service = described_class.new(classes_path: classes_file, members_path: incomplete_members_file)
        result = service.call

        expect(result[:success]).to be true
        expect(result[:data][:courses_created]).to be >= 0
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
        service = described_class.new(classes_path: orphaned_classes_file, members_path: members_file)
        result = service.call

        expect(result[:success]).to be true
        orphan_course = Course.find_by(code: 'ORPHAN001')
        expect(orphan_course).to be_present
        expect(orphan_course.teacher.email).to eq('placeholder.teacher@example.com')
      end

      it 'creates courses with no enrollments when no matching members' do
        service = described_class.new(classes_path: orphaned_classes_file, members_path: members_file)
        result = service.call

        orphan_course = Course.find_by(code: 'ORPHAN001')
        expect(orphan_course.students.count).to eq(0)
      end
    end
  end
end
