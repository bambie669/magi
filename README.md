# Magi QA - Test Management Tool

Magi QA is a web application built with Ruby on Rails for managing software testing processes, including projects, test suites, test cases, and test runs.

## Key Technologies

- **Backend:** Ruby on Rails
- **Database:** PostgreSQL (or specify if different)
- **Authentication:** Devise
- **Authorization:** Pundit
- **Frontend Styling:** Tailwind CSS
- **JavaScript:** Turbo (Hotwire)

## Prerequisites

- Ruby (version, 7.1 - check `.ruby-version` file)
- Bundler (`gem install bundler`)
- Node.js and Yarn (for JavaScript/CSS bundling)
- PostgreSQL running

## Getting Started

1.  **Clone the repository:**

    ```bash
    git clone git@github.com:bambie669/magi.git
    cd magi
    ```

2.  **Install Ruby dependencies:**

    ```bash
    bundle install
    ```

3.  **Install JavaScript dependencies:**

    ```bash
    node install
    ```

4.  **Set up the database:**
    - Ensure your database server (e.g., PostgreSQL) is running.
    - Configure `/Users/radur/work/magi/magi/config/database.yml` if necessary (e.g., with your database username/password).
    - Create the database, run migrations, and seed initial data (if any):
      ```bash
      rails db:setup
      # Or individually:
      # rails db:create
      # rails db:migrate
      # rails db:seed
      ```

## Running the Application

Start the development server (which includes Rails server and asset watchers):

```bash
bin/dev
```

Then, open your browser and navigate to `http://localhost:2507`.

## Admin User

To create an admin user, run `rails console` and execute:

```ruby
# Find existing user
user = User.find_by(email: 'your_email@example.com')
# Or create a new one
# user = User.create(email: 'admin@example.com', password: 'password', password_confirmation: 'password')

# Set role (assuming 'role' enum or similar)
user.update(role: :admin)
```
