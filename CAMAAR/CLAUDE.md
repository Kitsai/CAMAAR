# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CAMAAR is a Rails 8.1 application for managing forms, templates, and educational assessments. The system allows admins to create form templates and distribute them to courses/classes, with students receiving and responding to forms.

## Development Commands

### Setup
```bash
bin/setup              # Initial setup (install dependencies, create DB, run migrations)
bin/rails db:migrate   # Run database migrations
bin/rails db:seed      # Seed database (if seed file exists)
```

### Running the Application
```bash
bin/dev                # Start development server (Puma + asset pipeline)
bin/rails server       # Start Rails server only
bin/rails console      # Open Rails console for interactive debugging
```

### Testing
```bash
bin/rails test                    # Run all minitest unit tests
bin/rails test test/models/user_test.rb            # Run specific test file
bin/rails test test/models/user_test.rb:10         # Run specific test at line 10
bin/rails test:system             # Run system tests (Capybara/Selenium)
bin/cucumber                      # Run all Cucumber BDD tests
bin/cucumber features/create_form.feature          # Run specific feature file
bin/cucumber features/create_form.feature:3        # Run specific scenario at line 3
```

### Code Quality
```bash
bin/rubocop                # Run RuboCop linter
bin/rubocop -a             # Auto-correct RuboCop offenses
bin/brakeman              # Security vulnerability scan
bin/bundler-audit         # Check gems for known vulnerabilities
bin/importmap audit       # Check JavaScript dependencies for vulnerabilities
```

## Architecture

### Data Model Hierarchy

The application has three main domain areas:

**1. User & Course Management**
- `User`: Base entity with authentication (bcrypt), can be teacher, student, or admin
  - Teachers: `has_many :taught_courses`
  - Students: Many-to-many with courses through `Enrollment`
  - Admins: One-to-one with `Admin` model (uses `user_id` as primary key)

**2. Template System**
- `QuestionSet`: Stores questions as JSON data (`data` field)
- `Template`: Links admin + question_set for reusable form templates
- **Copy-on-write pattern**: When a `QuestionSet` used by forms is updated, it creates a new copy and updates the template reference, preserving the original for existing forms (see `QuestionSet#copy_on_write_if_used_by_forms`)

**3. Form Distribution & Responses**
- `Form`: Admin creates form for a course using a question_set
  - Has many `FormRequest` (one per student in course)
  - Has many `Answer` records (response data stored as text in `data` field)
- `FormRequest`: Join table between user and form, tracks which students received forms

### Key Relationships

```
Admin (user_id PK)
├── has_many :templates
└── has_many :forms

Template
├── belongs_to :admin
└── belongs_to :question_set

QuestionSet
├── has_one :template
└── has_many :forms

Form
├── belongs_to :admin
├── belongs_to :course
├── belongs_to :question_set
├── has_many :form_requests
├── has_many :users (through form_requests)
└── has_many :answers

Course
├── belongs_to :teacher (User)
├── has_many :enrollments
├── has_many :students (through enrollments)
└── has_many :forms
```

### Important Patterns

**Copy-on-Write for QuestionSets**:
- When updating a `QuestionSet` that's used by existing forms, the system automatically creates a new copy with the changes and updates the template to point to the new version
- Original `QuestionSet` remains unchanged for forms already using it
- Implemented via `before_update` callback in `app/models/question_set.rb:5-29`

**Multi-Database Setup (Production)**:
- Primary DB: Application data
- Cache DB: Solid Cache (Rails.cache backend)
- Queue DB: Solid Queue (Active Job backend)
- Cable DB: Solid Cable (Action Cable backend)

## Technology Stack

- **Ruby**: 3.4.7 (managed with rbenv recommended)
- **Rails**: 8.1.1
- **Database**: SQLite3 (development/test), multi-database setup in production
- **Authentication**: bcrypt (has_secure_password)
- **Frontend**: Hotwire (Turbo + Stimulus), Importmap for JS
- **Testing**: Minitest (unit), Capybara/Selenium (system), Cucumber (BDD)
- **Deployment**: Docker + Kamal

## Testing Strategy

The project uses both Minitest and Cucumber:
- **Minitest**: Model validations, unit logic (in `test/` directory)
- **Cucumber**: BDD acceptance tests with Gherkin features (in `features/` directory)
- **System Tests**: Capybara browser tests for full user flows

When writing tests, match the existing pattern for the component being tested.

## Database Notes

- Run `bin/rails db:migrate` after pulling schema changes
- Schema is in `db/schema.rb` (do not edit directly)
- SQLite databases stored in `storage/` directory
- QuestionSets and Answers store complex data as JSON/text in `data` fields
