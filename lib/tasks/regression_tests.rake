namespace :regression do
  desc "Generate comprehensive regression test plan Excel file"
  task generate_excel: :environment do
    require 'caxlsx'

    package = Axlsx::Package.new
    workbook = package.workbook

    # Styles
    styles = workbook.styles
    header_style = styles.add_style(
      bg_color: "1A0022",
      fg_color: "FFFFFF",
      b: true,
      alignment: { horizontal: :center, vertical: :center, wrap_text: true },
      border: { style: :thin, color: "00D4FF" }
    )

    critical_style = styles.add_style(
      bg_color: "B00020",
      fg_color: "FFFFFF",
      alignment: { horizontal: :center }
    )

    high_style = styles.add_style(
      bg_color: "FF9F0A",
      fg_color: "000000",
      alignment: { horizontal: :center }
    )

    medium_style = styles.add_style(
      bg_color: "00D4FF",
      fg_color: "000000",
      alignment: { horizontal: :center }
    )

    low_style = styles.add_style(
      bg_color: "6B6B6B",
      fg_color: "FFFFFF",
      alignment: { horizontal: :center }
    )

    cell_style = styles.add_style(
      alignment: { wrap_text: true, vertical: :top },
      border: { style: :thin, color: "CCCCCC" }
    )

    # Test data organized by module
    test_modules = {
      "Authentication" => [
        ["AUTH-001", "Login", "Valid user login with correct credentials", "User account exists, Application is accessible", "1. Navigate to login page\n2. Enter email: admin@example.com\n3. Enter password: password\n4. Click 'Sign In' button", "User is successfully logged in and redirected to Command Overview dashboard", "All Roles", "Critical"],
        ["AUTH-002", "Login", "Invalid login - wrong password", "User account exists, Application is accessible", "1. Navigate to login page\n2. Enter valid email\n3. Enter wrong password\n4. Click 'Sign In' button", "Error message displayed. User remains on login page", "All Roles", "Critical"],
        ["AUTH-003", "Login", "Invalid login - non-existent email", "Application is accessible", "1. Navigate to login page\n2. Enter non-existent email\n3. Enter any password\n4. Click 'Sign In' button", "Error message displayed. User remains on login page", "All Roles", "Critical"],
        ["AUTH-004", "Login", "Login with empty fields", "Application is accessible", "1. Navigate to login page\n2. Leave fields empty\n3. Click 'Sign In' button", "Validation error displayed", "All Roles", "High"],
        ["AUTH-005", "Login", "Login page displays NERV branding", "Application is accessible", "1. Navigate to login page\n2. Observe page layout", "NERV logo visible, motto displayed, Dark theme applied", "All Roles", "Medium"],
        ["AUTH-006", "Logout", "Successful logout", "User is logged in", "1. Click 'Disconnect' button in sidebar", "User is logged out and redirected to login page", "All Roles", "Critical"],
        ["AUTH-007", "Session", "Session persistence after page refresh", "User is logged in", "1. Refresh the browser page", "User remains logged in on the same page", "All Roles", "High"],
      ],
      "Dashboard" => [
        ["DASH-001", "Overview", "Dashboard loads correctly after login", "User is logged in", "1. Login to application\n2. Observe dashboard page", "Dashboard displays: stat cards, Recent Operations, MAGI Status", "All Roles", "Critical"],
        ["DASH-002", "Statistics", "Stat cards display correct counts", "User is logged in, Data exists", "1. Navigate to dashboard\n2. Compare stat card values with database", "All stat cards show accurate counts", "All Roles", "High"],
        ["DASH-003", "Pass Rate Chart", "30-day pass rate trend chart displays", "User is logged in, Test runs exist", "1. Navigate to dashboard\n2. Locate Pass Rate Trend section", "Line chart displays with accurate data points", "All Roles", "Medium"],
        ["DASH-004", "Activity Heatmap", "Activity heatmap displays correctly", "User is logged in, Activity exists", "1. Navigate to dashboard\n2. Locate Activity Heatmap", "GitHub-style heatmap displays with correct intensity", "All Roles", "Medium"],
        ["DASH-005", "Top Failed Tests", "Top failed tests list displays", "User is logged in, Failed tests exist", "1. Navigate to dashboard\n2. Locate Top Failed Tests", "List shows test cases with highest failure rates", "All Roles", "Medium"],
        ["DASH-006", "Team Activity", "Team activity feed displays", "User is logged in, Recent activities exist", "1. Navigate to dashboard\n2. Locate Team Activity", "Recent activities displayed with timestamps", "All Roles", "Medium"],
        ["DASH-007", "Navigation", "Quick navigation links work", "User is logged in", "1. Click on each stat card and list item", "Each link navigates to correct page", "All Roles", "High"],
      ],
      "Projects" => [
        ["PROJ-001", "List", "Projects index displays all projects", "User is logged in, Projects exist", "1. Navigate to Projects (Missions) page", "All projects displayed as cards", "All Roles", "Critical"],
        ["PROJ-002", "Create", "Create new project - Admin", "User is logged in as Admin", "1. Click 'Initialize Mission'\n2. Enter details\n3. Submit", "New project created successfully", "Admin", "Critical"],
        ["PROJ-003", "Create", "Create new project - Manager", "User is logged in as Manager", "1. Click 'Initialize Mission'\n2. Enter details\n3. Submit", "New project created successfully", "Manager", "Critical"],
        ["PROJ-004", "Create", "Create new project - Tester (should fail)", "User is logged in as Tester", "1. Look for 'Initialize Mission' button", "Button not visible or unauthorized", "Tester", "High"],
        ["PROJ-005", "Create", "Create project with duplicate name", "User is logged in as Admin, Project exists", "1. Try to create project with existing name", "Validation error: name must be unique", "Admin", "High"],
        ["PROJ-006", "View", "View project details", "User is logged in, Project exists", "1. Click on a project card", "Project detail page displays", "All Roles", "Critical"],
        ["PROJ-007", "Edit", "Edit project - Owner", "User is logged in as project owner", "1. Click 'Modify Mission'\n2. Change details\n3. Save", "Project updated successfully", "Manager", "High"],
        ["PROJ-008", "Edit", "Edit project - Admin", "User is logged in as Admin", "1. Navigate to any project\n2. Edit and save", "Project updated (Admin can edit any)", "Admin", "High"],
        ["PROJ-009", "Delete", "Delete project - Admin", "User is logged in as Admin", "1. Click 'Terminate Mission'\n2. Confirm", "Project and all data deleted", "Admin", "Critical"],
        ["PROJ-010", "Delete", "Delete project - Non-admin (should fail)", "User is logged in as Manager/Tester", "1. Look for delete button", "Button not visible or unauthorized", "Manager/Tester", "High"],
      ],
      "Test Suites" => [
        ["SUITE-001", "List", "View test suites for project", "User is logged in, Project has suites", "1. Navigate to project\n2. View Protocol Banks section", "All test suites displayed", "All Roles", "Critical"],
        ["SUITE-002", "Create", "Create new test suite", "User is logged in with permissions", "1. Click 'Initialize Bank'\n2. Enter details\n3. Submit", "New test suite created", "Admin/Manager", "Critical"],
        ["SUITE-003", "View", "View test suite details", "User is logged in, Suite exists", "1. Click on a test suite", "Suite page with test cases and actions", "All Roles", "Critical"],
        ["SUITE-004", "Edit", "Edit test suite", "User is logged in with permissions", "1. Click edit\n2. Modify details\n3. Save", "Test suite updated", "Admin/Manager", "High"],
        ["SUITE-005", "Delete", "Delete test suite", "User is logged in as Admin", "1. Click delete\n2. Confirm", "Suite and all test cases deleted", "Admin", "High"],
        ["SUITE-006", "Import CSV", "Import test cases from CSV", "User has permissions, Valid CSV", "1. Click 'Import CSV'\n2. Upload file\n3. Confirm", "Test cases imported", "Admin/Manager", "High"],
        ["SUITE-007", "Export CSV", "Export test cases to CSV", "User is logged in, Suite has cases", "1. Click CSV export button", "CSV file downloaded", "All Roles", "High"],
        ["SUITE-008", "Export PDF", "Export test cases to PDF", "User is logged in, Suite has cases", "1. Click PDF export button", "PDF file downloaded", "All Roles", "High"],
        ["SUITE-009", "Bulk Select", "Select all test cases", "User is logged in, Suite has cases", "1. Click 'Select All' checkbox", "All checkboxes checked", "All Roles", "Medium"],
        ["SUITE-010", "Bulk Delete", "Bulk delete test cases", "User is Admin, Cases selected", "1. Select cases\n2. Click bulk delete\n3. Confirm", "Selected cases deleted", "Admin", "High"],
      ],
      "Test Cases" => [
        ["TC-001", "Create", "Create new test case", "User has permissions, Suite exists", "1. Click 'Initialize Protocol'\n2. Fill all fields\n3. Submit", "New test case created", "Admin/Manager", "Critical"],
        ["TC-002", "Create", "Create test case with template", "User has permissions, Template exists", "1. Create new test case\n2. Select template\n3. Click Apply\n4. Submit", "Test case created with template data", "Admin/Manager", "Medium"],
        ["TC-003", "Create", "Create test case - required fields only", "User has permissions", "1. Enter only title\n2. Submit", "Test case created with minimal data", "Admin/Manager", "High"],
        ["TC-004", "Create", "Create test case - empty title (fail)", "User has permissions", "1. Leave title empty\n2. Submit", "Validation error: title required", "Admin/Manager", "High"],
        ["TC-005", "View", "View test case details", "User is logged in, Case exists", "1. Click on test case", "Detail page with all fields and history", "All Roles", "Critical"],
        ["TC-006", "View", "View execution history", "User is logged in, Case has history", "1. Navigate to test case\n2. View Execution History", "History shows all executions with status", "All Roles", "Medium"],
        ["TC-007", "Edit", "Edit test case", "User has permissions", "1. Click edit\n2. Modify fields\n3. Save", "Test case updated", "Admin/Manager", "High"],
        ["TC-008", "Delete", "Delete test case", "User is Admin", "1. Click delete\n2. Confirm", "Test case deleted", "Admin", "High"],
        ["TC-009", "Cypress ID", "Set Cypress automation ID", "User has permissions", "1. Edit test case\n2. Enter Cypress ID\n3. Save", "Cypress ID saved and visible", "Admin/Manager", "Medium"],
      ],
      "Test Runs" => [
        ["TR-001", "List", "View test runs for project", "User is logged in, Project has runs", "1. Navigate to Operations section", "All test runs displayed with status", "All Roles", "Critical"],
        ["TR-002", "Create", "Create new test run", "User has permissions", "1. Click 'Initialize Operation'\n2. Enter name, select suites\n3. Submit", "New test run created with test cases", "Admin/Manager", "Critical"],
        ["TR-003", "View", "View test run details", "User is logged in, Run exists", "1. Navigate to test run", "Progress bar, status counts, MAGI consensus, case list", "All Roles", "Critical"],
        ["TR-004", "Execute", "Mark test case as Passed", "User is logged in, Run in progress", "1. Find test case row\n2. Click 'Pass' button", "Status changes to NOMINAL, counts update", "All Roles", "Critical"],
        ["TR-005", "Execute", "Mark test case as Failed", "User is logged in, Run in progress", "1. Find test case row\n2. Click 'Fail' button", "Status changes to BREACH, row highlights red", "All Roles", "Critical"],
        ["TR-006", "Execute", "Mark test case as Blocked", "User is logged in, Run in progress", "1. Find test case row\n2. Click 'Block' button", "Status changes to PATTERN BLUE", "All Roles", "Critical"],
        ["TR-007", "Execute", "Add comments to test result", "User is logged in, Run in progress", "1. Expand test case\n2. Enter comments\n3. Save", "Comments saved and visible", "All Roles", "High"],
        ["TR-008", "Execute", "Upload attachment to test result", "User is logged in, Run in progress", "1. Expand test case\n2. Upload image\n3. Save", "Attachment uploaded, thumbnail visible", "All Roles", "High"],
        ["TR-009", "Attachments", "Preview attachment in lightbox", "User is logged in, Result has attachment", "1. Click on attachment thumbnail", "Image opens in lightbox modal", "All Roles", "Medium"],
        ["TR-010", "Progress", "Progress bar updates correctly", "User is logged in, Run in progress", "1. Execute several test cases\n2. Observe progress bar", "Progress percentage matches execution", "All Roles", "High"],
        ["TR-011", "MAGI", "MAGI consensus updates", "User is logged in, Run in progress", "1. Execute cases to various pass rates\n2. Observe MAGI panel", "MAGI votes update based on thresholds", "All Roles", "Medium"],
        ["TR-012", "Export CSV", "Export test run to CSV", "User is logged in, Run exists", "1. Click CSV export button", "CSV downloaded with all results", "All Roles", "High"],
        ["TR-013", "Export PDF", "Export test run to PDF", "User is logged in, Run exists", "1. Click PDF export button", "PDF downloaded with formatted report", "All Roles", "High"],
        ["TR-014", "Real-time", "Real-time status updates", "Two users on same test run", "1. User A executes test case\n2. User B observes", "User B sees update in real-time", "All Roles", "High"],
        ["TR-015", "Edit", "Edit test run details", "User has permissions", "1. Click 'Modify Operation'\n2. Change name\n3. Save", "Test run updated", "Admin/Manager", "High"],
        ["TR-016", "Delete", "Delete test run", "User is Admin", "1. Click 'Terminate Operation'\n2. Confirm", "Test run and results deleted", "Admin", "High"],
      ],
      "Templates" => [
        ["TMPL-001", "List", "View templates for project", "User is logged in, Project has templates", "1. Navigate to Templates section", "All templates displayed", "All Roles", "Medium"],
        ["TMPL-002", "Create", "Create new template", "User has permissions", "1. Click 'Initialize Template'\n2. Fill fields\n3. Submit", "New template created", "Admin/Manager", "Medium"],
        ["TMPL-003", "Edit", "Edit template", "User has permissions", "1. Click edit\n2. Modify fields\n3. Save", "Template updated", "Admin/Manager", "Medium"],
        ["TMPL-004", "Delete", "Delete template", "User has permissions", "1. Click delete\n2. Confirm", "Template deleted", "Admin/Manager", "Medium"],
        ["TMPL-005", "Apply", "Apply template to new test case", "User has permissions, Template exists", "1. Create new test case\n2. Select template\n3. Click Apply", "Form fields populated with template data", "All Roles", "Medium"],
      ],
      "Theme & UI" => [
        ["THEME-001", "Toggle", "Toggle theme from header", "User is logged in", "1. Click theme toggle button", "Theme switches between NERV and light", "All Roles", "High"],
        ["THEME-002", "Persistence", "Theme persists after refresh", "User is logged in, Theme changed", "1. Toggle theme\n2. Refresh page", "Theme remains as set", "All Roles", "High"],
        ["THEME-003", "System Config", "Theme matches system config", "User is logged in", "1. Change theme via toggle\n2. Navigate to System Config", "Theme setting matches", "All Roles", "High"],
        ["UI-001", "Responsive", "Mobile responsive layout", "Mobile viewport", "1. View on mobile device", "All pages display correctly", "All Roles", "Medium"],
        ["UI-002", "NERV Theme", "NERV aesthetic consistency", "User has NERV theme", "1. Navigate through all pages", "Consistent branding and colors", "All Roles", "Medium"],
        ["UI-003", "Animations", "Animations and transitions", "User is logged in", "1. Interact with UI elements", "Smooth animations on interactions", "All Roles", "Low"],
        ["NAV-001", "Sidebar", "Sidebar navigation works", "User is logged in", "1. Click each sidebar menu item", "Each item navigates correctly", "All Roles", "Critical"],
        ["NAV-002", "Breadcrumbs", "Breadcrumb navigation", "User is on nested page", "1. Click each breadcrumb link", "Each navigates to correct page", "All Roles", "High"],
        ["NAV-003", "Search", "Global search functionality", "User is logged in, Data exists", "1. Enter search term\n2. Press Enter", "Search results display", "All Roles", "High"],
        ["NAV-004", "Keyboard", "Keyboard shortcuts J/K", "User is on list page", "1. Press J key\n2. Press K key", "J moves down, K moves up", "All Roles", "Low"],
      ],
      "Notifications" => [
        ["NOTIF-001", "Bell", "Notification bell displays count", "User has unread notifications", "1. Observe notification bell", "Bell shows unread count badge", "All Roles", "Medium"],
        ["NOTIF-002", "Dropdown", "Notification dropdown opens", "User is logged in", "1. Click notification bell", "Dropdown opens with notifications", "All Roles", "Medium"],
        ["NOTIF-003", "View All", "Navigate to all notifications", "User is logged in", "1. Click bell\n2. Click 'View All'", "Navigates to full notifications page", "All Roles", "Medium"],
        ["NOTIF-004", "Mark Read", "Mark notification as read", "User has unread notification", "1. Click 'Mark Read' on notification", "Notification marked, badge decreases", "All Roles", "Medium"],
        ["NOTIF-005", "Mark All", "Mark all as read", "User has multiple unread", "1. Navigate to notifications\n2. Click 'Mark All as Read'", "All marked as read", "All Roles", "Medium"],
        ["RT-001", "Real-time", "Real-time notification received", "Two users logged in", "1. User A triggers notification\n2. User B observes bell", "User B receives notification without refresh", "All Roles", "Medium"],
      ],
      "System Config" => [
        ["SYSCONF-001", "Access", "Access system config page", "User is logged in", "1. Click 'System Config' in sidebar", "System Config page loads", "All Roles", "High"],
        ["SYSCONF-002", "Operators", "View operators list - Admin", "User is Admin", "1. Navigate to Operators section", "List of all users displayed", "Admin", "High"],
        ["SYSCONF-003", "Operators", "View operators - Non-admin (fail)", "User is Tester/Manager", "1. Try to access Operators section", "Access denied or not visible", "Tester/Manager", "High"],
        ["SYSCONF-004", "Operators", "Create new operator - Admin", "User is Admin", "1. Click 'Initialize Operator'\n2. Enter details\n3. Submit", "New user created", "Admin", "High"],
        ["SYSCONF-005", "Operators", "Edit operator - Admin", "User is Admin", "1. Click edit on user\n2. Change role\n3. Save", "User updated", "Admin", "High"],
        ["SYSCONF-006", "Operators", "Delete operator - Admin", "User is Admin", "1. Click delete on user\n2. Confirm", "User deleted", "Admin", "High"],
        ["SYSCONF-007", "Operators", "Cannot delete self", "User is Admin", "1. Try to delete own account", "Error: Cannot terminate your own account", "Admin", "High"],
        ["SYSCONF-008", "API Tokens", "View API tokens", "User is logged in", "1. Navigate to API Tokens section", "User's API tokens displayed", "All Roles", "High"],
        ["SYSCONF-009", "API Tokens", "Create API token", "User is logged in", "1. Enter token name\n2. Click Initialize", "New token created and displayed once", "All Roles", "High"],
        ["SYSCONF-010", "API Tokens", "Delete API token", "User has API tokens", "1. Click delete on token\n2. Confirm", "Token deleted", "All Roles", "High"],
      ],
      "API" => [
        ["API-001", "Auth", "API auth with valid token", "Valid API token exists", "1. Send GET /api/v1/projects with Bearer token", "Returns 200 with projects list", "API", "Critical"],
        ["API-002", "Auth", "API auth fails with invalid token", "No valid token", "1. Send request with invalid token", "Returns 401 Unauthorized", "API", "Critical"],
        ["API-003", "Auth", "API auth fails without token", "No token provided", "1. Send request without Authorization header", "Returns 401 Unauthorized", "API", "Critical"],
        ["API-004", "Projects", "List all projects via API", "Valid API token", "1. Send GET /api/v1/projects", "Returns JSON array of projects", "API", "High"],
        ["API-005", "Projects", "Get single project via API", "Valid token, Project exists", "1. Send GET /api/v1/projects/:id", "Returns JSON with project details", "API", "High"],
        ["API-006", "Test Runs", "List test runs for project", "Valid token, Project has runs", "1. Send GET /api/v1/projects/:id/test_runs", "Returns JSON array of test runs", "API", "High"],
        ["API-007", "Test Runs", "Create test run via API", "Valid API token", "1. Send POST /api/v1/projects/:id/test_runs", "Returns 201 with created test run", "API", "High"],
        ["API-008", "Test Runs", "Get test run details via API", "Valid token, Run exists", "1. Send GET /api/v1/test_runs/:id", "Returns JSON with full test run", "API", "High"],
        ["API-009", "Test Run Cases", "Update test case status via API", "Valid token, Case exists", "1. Send PATCH /api/v1/test_run_cases/:id", "Returns updated test run case", "API", "Critical"],
        ["API-010", "Test Run Cases", "Bulk update test cases via API", "Valid token, Multiple cases", "1. Send POST /api/v1/test_run_cases/bulk_update", "Returns summary of updated cases", "API", "High"],
        ["API-011", "Cypress", "Submit Cypress results", "Valid token, Test run exists", "1. Send POST /api/v1/test_runs/:id/cypress_results", "Returns summary of processed results", "API", "High"],
        ["API-012", "Test Cases", "Get test case by Cypress ID", "Valid token, Case with cypress_id", "1. Send GET /api/v1/test_cases/by_cypress_id/:id", "Returns test case details", "API", "Medium"],
      ],
      "Security" => [
        ["SEC-001", "Authorization", "Tester cannot access admin functions", "User is Tester", "1. Try to access /system_config/operators", "Access denied", "Tester", "Critical"],
        ["SEC-002", "Authorization", "Manager cannot delete projects", "User is Manager", "1. Try to delete a project", "Not authorized", "Manager", "Critical"],
        ["SEC-003", "CSRF", "CSRF protection on forms", "User is logged in", "1. Inspect form for CSRF token\n2. Try submit without token", "CSRF token present, submission fails without", "All Roles", "Critical"],
        ["SEC-004", "XSS", "XSS prevention in user inputs", "User is logged in", "1. Enter <script>alert('xss')</script> in text field\n2. Save and view", "Script is escaped, not executed", "All Roles", "Critical"],
        ["SEC-005", "SQL Injection", "SQL injection prevention", "User is logged in", "1. Enter ' OR '1'='1 in search\n2. Submit", "Query is parameterized", "All Roles", "Critical"],
      ],
    }

    # Create a sheet for each module
    test_modules.each do |module_name, tests|
      workbook.add_worksheet(name: module_name[0..30]) do |sheet|
        # Header row
        sheet.add_row [
          "Test ID", "Feature", "Test Case Title", "Preconditions",
          "Test Steps", "Expected Result", "User Role", "Priority",
          "Status", "Tester", "Date", "Comments"
        ], style: header_style, height: 30

        # Data rows
        tests.each do |test|
          priority_style = case test[7]
                          when "Critical" then critical_style
                          when "High" then high_style
                          when "Medium" then medium_style
                          else low_style
                          end

          sheet.add_row [
            test[0], test[1], test[2], test[3], test[4], test[5], test[6], test[7],
            "", "", "", ""
          ], style: [cell_style, cell_style, cell_style, cell_style, cell_style, cell_style, cell_style, priority_style, cell_style, cell_style, cell_style, cell_style], height: 60
        end

        # Set column widths
        sheet.column_widths 12, 15, 35, 30, 40, 35, 12, 10, 10, 15, 12, 25
      end
    end

    # Summary sheet
    workbook.add_worksheet(name: "Summary") do |sheet|
      sheet.add_row ["MAGI QA - Regression Test Plan Summary"], style: header_style
      sheet.add_row []
      sheet.add_row ["Module", "Total Tests", "Critical", "High", "Medium", "Low"], style: header_style

      test_modules.each do |module_name, tests|
        critical = tests.count { |t| t[7] == "Critical" }
        high = tests.count { |t| t[7] == "High" }
        medium = tests.count { |t| t[7] == "Medium" }
        low = tests.count { |t| t[7] == "Low" }

        sheet.add_row [module_name, tests.count, critical, high, medium, low], style: cell_style
      end

      total_tests = test_modules.values.flatten(1).count
      total_critical = test_modules.values.flatten(1).count { |t| t[7] == "Critical" }
      total_high = test_modules.values.flatten(1).count { |t| t[7] == "High" }
      total_medium = test_modules.values.flatten(1).count { |t| t[7] == "Medium" }
      total_low = test_modules.values.flatten(1).count { |t| t[7] == "Low" }

      sheet.add_row []
      sheet.add_row ["TOTAL", total_tests, total_critical, total_high, total_medium, total_low], style: header_style

      sheet.column_widths 20, 12, 12, 12, 12, 12
    end

    # Save the file
    file_path = Rails.root.join("docs", "MAGI_QA_Regression_Test_Plan.xlsx")
    package.serialize(file_path)

    puts "Excel file generated: #{file_path}"
    puts "Total test cases: #{test_modules.values.flatten(1).count}"
  end
end
