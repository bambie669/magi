class BackfillTestCaseRefIds < ActiveRecord::Migration[7.1]
  def up
    # Step 1: Generate project keys for existing projects
    projects = execute("SELECT id, name FROM projects WHERE key IS NULL").to_a
    used_keys = Set.new

    projects.each do |project|
      project_id = project['id']
      project_name = project['name'] || 'PROJECT'

      # Generate key from name: "My Project" → "MYPR"
      base = project_name.gsub(/[^A-Za-z]/, '').upcase[0..5]
      base = base.ljust(2, 'X') if base.length < 2

      # Find unique key
      candidate = base[0..3]
      counter = 0
      while used_keys.include?(candidate)
        counter += 1
        candidate = "#{base[0..2]}#{counter}"
      end
      used_keys.add(candidate)

      execute("UPDATE projects SET key = '#{candidate}' WHERE id = #{project_id}")
    end

    # Step 2: For each project, assign ref_ids to test cases
    projects_with_keys = execute("SELECT id, key FROM projects").to_a

    projects_with_keys.each do |project|
      project_id = project['id']
      project_key = project['key']

      # Get all test cases for this project ordered by creation date
      test_cases = execute(<<~SQL).to_a
        SELECT tc.id, tc.cypress_id
        FROM test_cases tc
        JOIN test_scopes ts ON tc.test_scope_id = ts.id
        JOIN test_suites tsu ON ts.test_suite_id = tsu.id
        WHERE tsu.project_id = #{project_id}
          AND tc.ref_id IS NULL
        ORDER BY tc.created_at ASC
      SQL

      sequence = 0
      test_cases.each do |tc|
        sequence += 1
        ref_id = "#{project_key}-#{sequence.to_s.rjust(5, '0')}"
        # Determine source: if cypress_id exists, likely imported (1), otherwise manual (0)
        source = tc['cypress_id'].present? ? 1 : 0

        execute(<<~SQL)
          UPDATE test_cases
          SET ref_id = '#{ref_id}', source = #{source}
          WHERE id = #{tc['id']}
        SQL
      end

      # Update project sequence counter
      execute("UPDATE projects SET test_case_sequence = #{sequence} WHERE id = #{project_id}")
    end

    # Step 3: Add NOT NULL constraint to ref_id now that all values are set
    change_column_null :test_cases, :ref_id, false
  end

  def down
    change_column_null :test_cases, :ref_id, true
    execute("UPDATE test_cases SET ref_id = NULL, source = 0")
    execute("UPDATE projects SET key = NULL, test_case_sequence = 0")
  end
end
