require 'csv'

class TestCasesCsvImporter
  attr_reader :errors, :imported_count, :skipped_count

  # Column mappings for different CSV formats
  COLUMN_MAPPINGS = {
    # Standard Magi format
    'scope_path' => :scope_path,
    'title' => :title,
    'preconditions' => :preconditions,
    'steps' => :steps,
    'expected_result' => :expected_result,
    'cypress_id' => :cypress_id,
    # TestRail/Spreadsheet format
    'test case number' => :cypress_id,
    'test title' => :title,
    'prerequisites' => :preconditions,
    'test steps' => :steps,
    'expected results' => :expected_result,
    # More variations
    'id' => :cypress_id,
    'name' => :title,
    'case number' => :cypress_id,
    'section' => :scope_path,
  }.freeze

  def initialize(test_suite, csv_file)
    @test_suite = test_suite
    @csv_file = csv_file
    @errors = []
    @imported_count = 0
    @skipped_count = 0
    @scope_cache = {}
    @row_number = 0
    @current_scope_path = nil
    @column_map = {}
  end

  def import
    begin
      rows = CSV.read(@csv_file.path, liberal_parsing: true)

      # Find header row and detect format
      header_row_index = find_header_row(rows)

      if header_row_index.nil?
        @errors << "Could not find header row in CSV"
        return result
      end

      headers = rows[header_row_index].map { |h| h&.strip&.downcase }
      build_column_map(headers)

      # Process data rows
      rows[(header_row_index + 1)..].each_with_index do |row, idx|
        @row_number = header_row_index + idx + 2 # 1-based, after header
        process_row(row)
      end
    rescue CSV::MalformedCSVError => e
      @errors << "CSV parsing error: #{e.message}"
    rescue => e
      @errors << "Unexpected error: #{e.message}"
    end

    result
  end

  private

  def result
    {
      success: @errors.empty?,
      imported: @imported_count,
      skipped: @skipped_count,
      errors: @errors
    }
  end

  def find_header_row(rows)
    rows.each_with_index do |row, index|
      row_text = row.map { |c| c&.strip&.downcase }.compact.join(' ')

      # Look for rows that contain typical header keywords
      if row_text.include?('title') || row_text.include?('steps') || row_text.include?('test case')
        return index
      end
    end
    nil
  end

  def build_column_map(headers)
    headers.each_with_index do |header, index|
      next if header.blank?

      mapped_field = COLUMN_MAPPINGS[header]
      @column_map[mapped_field] = index if mapped_field
    end
  end

  def get_value(row, field)
    index = @column_map[field]
    return nil if index.nil?
    row[index]&.strip
  end

  def process_row(row)
    # Skip empty rows
    return if row.nil? || row.all?(&:blank?)

    first_cell = row[0]&.strip
    second_cell = row[1]&.strip

    # Detect section header row (only first column has content, or it looks like a section name)
    if is_section_row?(row, first_cell, second_cell)
      @current_scope_path = first_cell
      @skipped_count += 1
      return
    end

    # Get values using column mapping
    title = get_value(row, :title)

    # Skip rows without title
    if title.blank?
      @skipped_count += 1
      return
    end

    # Determine scope path
    scope_path = get_value(row, :scope_path) || @current_scope_path

    if scope_path.blank?
      # Use a default scope if none defined
      scope_path = "Imported"
    end

    import_test_case(row, scope_path, title)
  end

  def is_section_row?(row, first_cell, second_cell)
    return false if first_cell.blank?

    # If first cell has content but no test case number pattern and rest is mostly empty
    has_tc_pattern = first_cell.match?(/^TC\d+|^\d+$|^[A-Z]+-\d+$/i)

    # Count non-empty cells
    non_empty_count = row.count { |c| c.present? }

    # Section row: has first cell, doesn't look like TC number, and mostly empty
    !has_tc_pattern && non_empty_count <= 2 && second_cell.blank?
  end

  def import_test_case(row, scope_path, title)
    scope = find_or_create_scope(scope_path)
    return unless scope

    cypress_id = get_value(row, :cypress_id)&.gsub(/\s+/, '') # Remove spaces from TC numbers
    preconditions = get_value(row, :preconditions)
    steps = unescape_newlines(get_value(row, :steps))
    expected_result = unescape_newlines(get_value(row, :expected_result))

    # Validate required fields
    if steps.blank? && expected_result.blank?
      @errors << "Row #{@row_number}: steps and expected_result are both empty"
      return
    end

    test_case = scope.test_cases.new(
      title: title,
      preconditions: preconditions,
      steps: steps || "See expected result",
      expected_result: expected_result || "See steps",
      cypress_id: cypress_id.presence
    )

    if test_case.save
      @imported_count += 1
    else
      @errors << "Row #{@row_number}: #{test_case.errors.full_messages.join(', ')}"
    end
  end

  def find_or_create_scope(path)
    return @scope_cache[path] if @scope_cache.key?(path)

    # Clean up path
    path = path.gsub(/\s*[-–—]\s*/, '/').strip # Convert dashes to slashes
    parts = path.split('/').map(&:strip).reject(&:blank?)

    if parts.empty?
      parts = ["Imported"]
    end

    current_scope = nil
    current_path = ""

    parts.each_with_index do |part, index|
      current_path = index == 0 ? part : "#{current_path}/#{part}"

      if @scope_cache.key?(current_path)
        current_scope = @scope_cache[current_path]
        next
      end

      if index == 0
        current_scope = @test_suite.root_test_scopes.find_or_create_by!(name: part)
      else
        current_scope = current_scope.children.find_or_create_by!(
          name: part,
          test_suite: @test_suite
        )
      end

      @scope_cache[current_path] = current_scope
    end

    current_scope
  rescue ActiveRecord::RecordInvalid => e
    @errors << "Row #{@row_number}: Failed to create scope '#{path}': #{e.message}"
    nil
  end

  def unescape_newlines(text)
    return nil if text.blank?
    text.gsub("\\n", "\n")
  end
end
