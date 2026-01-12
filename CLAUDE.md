# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Magi QA is a test management web application built with Ruby on Rails 7.1 for managing software testing processes including projects, test suites, test cases, and test runs. Includes a REST API for external integrations (e.g., Cypress test automation).

## Common Commands

### Development
```bash
bin/dev                    # Start development server (Rails + Tailwind watcher) on port 2507
bundle install             # Install Ruby dependencies
rails db:setup             # Create database, run migrations, seed data
rails db:migrate           # Run pending migrations
```

### Testing
```bash
bundle exec rspec                           # Run all specs
bundle exec rspec spec/models/              # Run model specs
bundle exec rspec spec/requests/            # Run request specs
bundle exec rspec spec/path/to/file_spec.rb # Run single spec file
bundle exec rspec spec/file_spec.rb:42      # Run spec at specific line
```

### Rails Console
```bash
rails console              # Start Rails console
```

## Architecture

### Technology Stack
- Ruby 3.2.2 / Rails 7.1
- PostgreSQL
- Devise (authentication)
- Pundit (authorization via policies)
- Hotwire (Turbo + Stimulus)
- Tailwind CSS

### Domain Model Hierarchy
```
User (role enum: tester/manager/admin)
├── ApiToken (for API authentication)
└── Project (owner: user_id)
    ├── Milestone (due_date tracking)
    ├── TestSuite
    │   └── TestScope (hierarchical via parent_id, organizes test cases)
    │       └── TestCase (title, preconditions, steps, expected_result, cypress_id)
    ├── TestRun (execution instance)
    │   └── TestRunCase (status enum: untested/passed/failed/blocked, comments, attachments)
    └── TestCaseTemplate (reusable test case templates)
```

TestCase has `ref_id` (auto-generated unique ID like "PROJ-00042") and optional `cypress_id` for matching with Cypress tests. TestCase `source` enum: manual/imported/cypress_auto.

### Authorization Pattern
All controllers inherit from `ApplicationController` which includes Pundit. Each resource has a corresponding policy in `app/policies/` (e.g., `ProjectPolicy`, `TestRunPolicy`). Policies check user permissions based on role and ownership.

### Routing Structure
- Root: Dashboard for authenticated users, login page for visitors
- Nested resources: Projects contain TestRuns, Milestones, TestSuites
- Shallow nesting: TestSuites contain TestCases, TestRuns contain TestRunCases
- API namespace: `/api/v1/` for external integrations
- Health check: `GET /up`

### API for Integrations
The `/api/v1/` namespace provides REST endpoints for external tools:
- Bearer token authentication via `ApiToken`
- Cypress results endpoint: `POST /api/v1/projects/:project_id/cypress_results` or `POST /api/v1/test_runs/:test_run_id/cypress_results`
- Auto-creates TestCases from Cypress tests when `auto_create: true`
- Maps Cypress test IDs to TestCase `cypress_id` field

### Test Organization
- RSpec with FactoryBot and Faker for test data
- Specs organized under `spec/`: models, requests, policies, helpers, views, factories
