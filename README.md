# MAGI QA

<div align="center">

```
    ███╗   ███╗ █████╗  ██████╗ ██╗
    ████╗ ████║██╔══██╗██╔════╝ ██║
    ██╔████╔██║███████║██║  ███╗██║
    ██║╚██╔╝██║██╔══██║██║   ██║██║
    ██║ ╚═╝ ██║██║  ██║╚██████╔╝██║
    ╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═╝
         Test Management System
```

*A comprehensive test management platform for software QA teams*

</div>

---

## Overview

MAGI QA is a web-based test management application built with Ruby on Rails. It provides a professional interface for organizing, executing, and tracking software testing activities.

- **Dark Mode** - Professional dark interface (default)
- **Light Mode** - Clean light interface

## Features

### Core Functionality

| Feature | Description |
|---------|-------------|
| **Projects** | Organize testing by project/product |
| **Test Suites** | Group related test cases |
| **Test Cases** | Individual test specifications |
| **Test Runs** | Execute tests and track results |
| **Milestones** | Track project milestones and deadlines |

### Additional Features

- **Global Search** - Search across all entities (projects, suites, cases, runs)
- **Analysis Dashboard** - Comprehensive statistics and quality reports
- **User Management** - Role-based access (Admin, Manager, Tester)
- **Theme Switching** - Toggle between dark and light themes
- **API Integration** - REST API for Cypress and external tool integration
- **CSV/Excel Import/Export** - Bulk import/export test cases

### Test Status Types

| Status | Color | Description |
|--------|-------|-------------|
| Passed | Green | Test executed successfully |
| Failed | Red | Test failed with errors |
| Blocked | Amber | Test blocked by dependencies |
| Not Run | Gray | Test not yet executed |

---

## Technology Stack

| Component | Technology |
|-----------|------------|
| Backend | Ruby 3.2.2 / Rails 7.1 |
| Database | PostgreSQL |
| Authentication | Devise |
| Authorization | Pundit (Policy-based) |
| Frontend | Hotwire (Turbo + Stimulus) |
| Styling | Tailwind CSS v4 |
| Testing | RSpec, FactoryBot, Capybara |
| E2E Testing | Cypress |

---

## Getting Started

### Prerequisites

- Ruby 3.2.2 (use `rbenv` or `rvm`)
- PostgreSQL 14+
- Node.js 18+ (for Tailwind CSS)
- Bundler (`gem install bundler`)

### Installation

```bash
# Clone the repository
git clone git@github.com:bambie669/magi.git
cd magi

# Install Ruby dependencies
bundle install

# Setup database
rails db:setup

# Build Tailwind CSS
rails tailwindcss:build
```

### Running the Application

```bash
# Start development server (Rails + Tailwind watcher)
bin/dev

# Or start only Rails server
rails server -p 2507
```

Access the application at: **http://localhost:2507**

### Creating an Admin User

```bash
rails console
```

```ruby
User.create!(
  email: 'admin@company.com',
  password: 'password123',
  password_confirmation: 'password123',
  role: :admin
)
```

---

## Project Structure

```
magi/
├── app/
│   ├── controllers/
│   │   ├── analysis_controller.rb    # Statistics & reports
│   │   ├── dashboard_controller.rb   # Main dashboard
│   │   ├── projects_controller.rb    # Project management
│   │   ├── search_controller.rb      # Global search
│   │   ├── system_config_controller.rb # Settings & users
│   │   ├── test_cases_controller.rb  # Test case management
│   │   ├── test_runs_controller.rb   # Test run execution
│   │   └── test_suites_controller.rb # Test suite management
│   ├── models/
│   │   ├── user.rb                   # Users
│   │   ├── project.rb                # Projects
│   │   ├── test_suite.rb             # Test Suites
│   │   ├── test_scope.rb             # Test organization
│   │   ├── test_case.rb              # Test Cases
│   │   ├── test_run.rb               # Test Runs
│   │   ├── test_run_case.rb          # Execution results
│   │   └── milestone.rb              # Milestones
│   ├── policies/                     # Pundit authorization
│   ├── views/
│   │   ├── layouts/application.html.erb
│   │   ├── shared/_sidebar.html.erb
│   │   ├── dashboard/
│   │   ├── analysis/
│   │   ├── search/
│   │   └── ...
│   └── assets/
│       └── tailwind/
│           └── application.css       # Tailwind v4 config
├── config/
│   ├── routes.rb
│   └── tailwind.config.js
├── db/
│   ├── migrate/
│   └── schema.rb
├── spec/                             # RSpec tests
│   ├── models/
│   ├── requests/
│   ├── policies/
│   ├── system/
│   └── factories/
└── cypress/                          # E2E tests
    ├── e2e/
    ├── fixtures/
    └── support/
```

---

## Domain Model

```
User
├── role: [admin, manager, tester]
└── theme: [dark, light]

Project
├── owner: User
├── Milestones
├── TestSuites
│   └── TestScopes (hierarchical organization)
│       └── TestCases
│           ├── title
│           ├── preconditions
│           ├── steps
│           └── expected_result
└── TestRuns
    └── TestRunCases (Execution Results)
        ├── status: [passed, failed, blocked, untested]
        ├── comments
        └── attachments (ActiveStorage)
```

---

## API Reference

### Authentication

API requests require a valid API token in the header:

```
Authorization: Bearer <api_token>
```

Generate tokens in **Settings > API Tokens**.

### Endpoints

#### Cypress Results Integration

```http
POST /api/v1/test_runs/:test_run_id/cypress_results
Content-Type: application/json
Authorization: Bearer <token>

{
  "results": [
    {
      "cypress_id": "TC-001",
      "status": "passed",
      "duration": 1234,
      "error_message": null
    }
  ]
}
```

---

## Testing

### Running Tests

```bash
# Run all tests
bundle exec rspec

# Run specific test types
bundle exec rspec spec/models/
bundle exec rspec spec/requests/
bundle exec rspec spec/policies/
bundle exec rspec spec/system/

# Run single test file
bundle exec rspec spec/models/project_spec.rb

# Run with verbose output
bundle exec rspec --format documentation
```

### Test Coverage

The test suite includes:

- **Model specs** - Validations, associations, methods
- **Request specs** - Controller actions, API endpoints
- **Policy specs** - Authorization rules
- **System specs** - Full integration tests with Capybara

### E2E Tests with Cypress

```bash
# Install Cypress
npm install cypress --save-dev

# Open Cypress Test Runner
npx cypress open

# Run headless
npx cypress run
```

---

## Themes

### Dark Mode (Default)

A professional dark theme optimized for extended use:

- **Background**: Deep slate (`#0F172A`)
- **Primary**: Blue (`#3B82F6`)
- **Accent**: Emerald (`#10B981`)
- **Text**: High contrast off-white

### Light Mode

A clean light theme for bright environments:

- **Background**: Soft white (`#F8FAFC`)
- **Primary**: Blue (`#2563EB`)
- **Accent**: Emerald (`#059669`)
- **Text**: Dark slate

Switch themes in **Settings > Theme**.

---

## Configuration

### Environment Variables

```bash
# Database
DATABASE_URL=postgres://user:pass@localhost/magi_development

# Rails
RAILS_ENV=development
SECRET_KEY_BASE=your_secret_key

# Optional
RAILS_LOG_LEVEL=debug
```

### Tailwind CSS v4

Tailwind configuration is in `app/assets/tailwind/application.css` using the `@theme` directive:

```css
@import "tailwindcss";

@theme {
  --color-dark-base: #0F172A;
  --color-primary: #3B82F6;
  --color-accent: #10B981;
  /* ... */
}
```

---

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Write tests for new functionality
4. Ensure all tests pass (`bundle exec rspec`)
5. Commit changes (`git commit -m 'Add amazing feature'`)
6. Push to branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

---

## License

This project is licensed under the MIT License.

---

<div align="center">

**MAGI QA - Test Management System**

</div>
# magi-qa
