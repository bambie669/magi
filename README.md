# MAGI QA System

<div align="center">

```
    ███╗   ███╗ █████╗  ██████╗ ██╗
    ████╗ ████║██╔══██╗██╔════╝ ██║
    ██╔████╔██║███████║██║  ███╗██║
    ██║╚██╔╝██║██╔══██║██║   ██║██║
    ██║ ╚═╝ ██║██║  ██║╚██████╔╝██║
    ╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═╝
         QA SYSTEM v1.0
```

**"GOD'S IN HIS HEAVEN. ALL'S RIGHT WITH THE WORLD."**

*A NERV-themed Test Management System inspired by Neon Genesis Evangelion*

</div>

---

## Overview

MAGI QA is a comprehensive test management web application built with Ruby on Rails. It features a unique **NERV Command Center** aesthetic with two themes inspired by Evangelion units:

- **EVA-01 (Dark Theme)** - Shinji's Unit: Purple & Green
- **EVA-00 (Light Theme)** - Rei's Unit: Blue, White & Orange

## Features

### Core Functionality

| Feature | NERV Terminology | Description |
|---------|------------------|-------------|
| **Projects** | Missions | Organize testing by project/product |
| **Test Suites** | Protocol Banks | Group related test cases |
| **Test Cases** | Protocols | Individual test specifications |
| **Test Runs** | Operations | Execute tests and track results |
| **Milestones** | Mission Deadlines | Track project milestones |

### Additional Features

- **Global Search** - Search across all entities (projects, suites, cases, runs)
- **Analysis Dashboard** - Comprehensive statistics and MAGI consensus reports
- **User Management** - Role-based access (Admin, Tester)
- **Theme Switching** - Toggle between EVA-01 (dark) and EVA-00 (light) themes
- **API Integration** - REST API for Cypress and external tool integration
- **CSV Import/Export** - Bulk import/export test cases

### Status Terminology

| Standard Term | NERV Term | Color |
|--------------|-----------|-------|
| Passed | NOMINAL | Green |
| Failed | BREACH | Red |
| Blocked | PATTERN BLUE | Amber |
| Untested | STANDBY | Gray |

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
  email: 'commander@nerv.org',
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
│   │   ├── projects_controller.rb    # Mission management
│   │   ├── search_controller.rb      # Global search
│   │   ├── system_config_controller.rb # Settings & users
│   │   ├── test_cases_controller.rb  # Protocol management
│   │   ├── test_runs_controller.rb   # Operation execution
│   │   └── test_suites_controller.rb # Protocol bank mgmt
│   ├── models/
│   │   ├── user.rb                   # Operators
│   │   ├── project.rb                # Missions
│   │   ├── test_suite.rb             # Protocol Banks
│   │   ├── test_scope.rb             # Test organization
│   │   ├── test_case.rb              # Protocols
│   │   ├── test_run.rb               # Operations
│   │   ├── test_run_case.rb          # Execution results
│   │   └── milestone.rb              # Deadlines
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
│   └── tailwind.config.js            # (legacy, not used in v4)
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
User (Operator)
├── role: [admin, tester]
└── theme: [nerv, light]

Project (Mission)
├── owner: User
├── Milestones (Deadlines)
├── TestSuites (Protocol Banks)
│   └── TestScopes (hierarchical organization)
│       └── TestCases (Protocols)
│           ├── title
│           ├── preconditions
│           ├── steps
│           └── expected_result
└── TestRuns (Operations)
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

Generate tokens in **System Config > API Tokens**.

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

### EVA-01 Dark Theme (Default)

A professional, WCAG AA compliant dark theme inspired by EVA-01:

- **Background**: Deep charcoal with purple undertones (`#0C0C10`)
- **Primary**: Muted purple (`#6B5B95`)
- **Accent**: Soft green for active states (`#4ADE80`)
- **Text**: High contrast off-white (`#EAEAF0`)

### EVA-00 Light Theme

A clean light theme inspired by EVA-00:

- **Background**: Soft white/cream (`#F8FAFC`)
- **Primary**: Sky blue (`#0EA5E9`)
- **Accent**: Orange highlights (`#F97316`)
- **Text**: Dark gray (`#475569`)

Switch themes in **System Config > Theme**.

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
  --color-dark-base: #0C0C10;
  --color-eva-purple: #6B5B95;
  --color-eva-green: #4ADE80;
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

## Acknowledgments

- Inspired by **Neon Genesis Evangelion** and NERV's command interfaces
- Built with Ruby on Rails and the amazing Rails community
- UI components styled with Tailwind CSS

---

<div align="center">

**NERV HEADQUARTERS - MAGI QA INTERFACE v1.0**

*"The fate of destruction is also the joy of rebirth."*

</div>
