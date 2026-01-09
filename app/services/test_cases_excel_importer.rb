require 'roo'
require 'cgi'

class TestCasesExcelImporter
  attr_reader :errors, :imported_count, :skipped_count, :duplicate_count

  # Column mappings for Excel format (case-insensitive)
  COLUMN_MAPPINGS = {
    # MedPlanner/TestRail format
    'test case number' => :cypress_id,
    'test title' => :title,
    'prerequisites' => :preconditions,
    'test steps' => :steps,
    'expected results' => :expected_result,
    # Standard Magi format
    'scope_path' => :scope_path,
    'title' => :title,
    'preconditions' => :preconditions,
    'steps' => :steps,
    'expected_result' => :expected_result,
    'cypress_id' => :cypress_id,
    # Additional variations
    'id' => :cypress_id,
    'name' => :title,
    'case number' => :cypress_id,
    'section' => :scope_path,
    'tc' => :cypress_id,
    'test case' => :cypress_id,
    'test name' => :title,
    'description' => :title,
    'pre-conditions' => :preconditions,
    'precondition' => :preconditions,
    'expected result' => :expected_result,
    'expected outcome' => :expected_result,
  }.freeze

  # Sheets to skip (summary/metadata sheets)
  SKIP_SHEETS = ['medplanner_tabs', 'summary', 'overview', 'index'].freeze

  def initialize(test_suite, excel_file)
    @test_suite = test_suite
    @excel_file = excel_file
    @errors = []
    @imported_count = 0
    @skipped_count = 0
    @duplicate_count = 0
    @scope_cache = {}
  end

  def import
    begin
      spreadsheet = open_spreadsheet

      spreadsheet.sheets.each do |sheet_name|
        next if should_skip_sheet?(sheet_name)

        process_sheet(spreadsheet, sheet_name)
      end
    rescue Roo::HeaderRowNotFoundError => e
      @errors << "Header row error: #{e.message}"
    rescue => e
      @errors << "Unexpected error: #{e.message}"
      Rails.logger.error "Excel import error: #{e.message}\n#{e.backtrace.first(5).join("\n")}"
    end

    result
  end

  private

  def result
    {
      success: @errors.empty? || @imported_count > 0,
      imported: @imported_count,
      skipped: @skipped_count,
      duplicates: @duplicate_count,
      errors: @errors
    }
  end

  def open_spreadsheet
    case File.extname(@excel_file.original_filename).downcase
    when '.xlsx'
      Roo::Excelx.new(@excel_file.path)
    when '.xls'
      Roo::Excel.new(@excel_file.path)
    when '.csv'
      Roo::CSV.new(@excel_file.path)
    else
      raise "Unknown file type: #{@excel_file.original_filename}"
    end
  end

  def should_skip_sheet?(sheet_name)
    normalized = sheet_name.downcase.strip
    SKIP_SHEETS.any? { |skip| normalized.include?(skip) }
  end

  def process_sheet(spreadsheet, sheet_name)
    spreadsheet.default_sheet = sheet_name

    # Find header row
    header_row_index = find_header_row(spreadsheet)

    if header_row_index.nil?
      @errors << "Sheet '#{sheet_name}': Could not find header row"
      return
    end

    # Build column mapping for this sheet
    headers = spreadsheet.row(header_row_index).map { |h| h.to_s.strip.downcase }
    column_map = build_column_map(headers)

    if column_map[:title].nil?
      @errors << "Sheet '#{sheet_name}': Could not find title column"
      return
    end

    # Use sheet name as scope path
    scope_path = sanitize_scope_name(sheet_name)
    current_subscope = nil

    # Process data rows
    ((header_row_index + 1)..spreadsheet.last_row).each do |row_num|
      row = spreadsheet.row(row_num)

      # Skip empty rows
      next if row.nil? || row.all? { |cell| cell.nil? || cell.to_s.strip.empty? }

      first_cell = row[0].to_s.strip
      second_cell = row[1].to_s.strip if row.length > 1

      # Detect section/subscope row
      if is_section_row?(row, first_cell, second_cell, column_map)
        current_subscope = first_cell
        @skipped_count += 1
        next
      end

      # Get title - skip if empty
      title = get_value(row, column_map, :title)
      next if title.blank?

      # Build full scope path
      full_scope_path = if current_subscope.present?
        "#{scope_path}/#{sanitize_scope_name(current_subscope)}"
      else
        scope_path
      end

      import_test_case(row, column_map, full_scope_path, title, sheet_name, row_num)
    end
  end

  def find_header_row(spreadsheet)
    (1..[spreadsheet.last_row, 10].min).each do |row_num|
      row = spreadsheet.row(row_num)
      next if row.nil?

      row_text = row.map { |c| c.to_s.strip.downcase }.join(' ')

      # Look for typical header keywords
      if row_text.include?('title') || row_text.include?('steps') ||
         row_text.include?('test case') || row_text.include?('expected')
        return row_num
      end
    end
    nil
  end

  def build_column_map(headers)
    map = {}
    headers.each_with_index do |header, index|
      next if header.blank?

      mapped_field = COLUMN_MAPPINGS[header]
      map[mapped_field] = index if mapped_field && !map.key?(mapped_field)
    end
    map
  end

  def get_value(row, column_map, field)
    index = column_map[field]
    return nil if index.nil? || index >= row.length

    value = row[index]
    return nil if value.nil?

    sanitize_cell_value(value.to_s)
  end

  def sanitize_cell_value(value)
    return nil if value.nil?

    text = value.to_s

    # Remove HTML tags if present
    if text.include?('<') && text.include?('>')
      # Strip all HTML tags
      text = text.gsub(/<[^>]*>/, ' ')
      # Clean up extra whitespace
      text = text.gsub(/\s+/, ' ')
    end

    # Decode HTML entities
    text = CGI.unescapeHTML(text) rescue text

    text.strip
  end

  def is_section_row?(row, first_cell, second_cell, column_map)
    return false if first_cell.blank?

    # If first cell has content but doesn't look like a test case number
    has_tc_pattern = first_cell.match?(/^TC\s*\d+|^\d+$|^[A-Z]+-\d+$/i)

    # Count non-empty cells
    non_empty_count = row.count { |c| c.present? && c.to_s.strip.present? }

    # Section row: has first cell, doesn't look like TC number, and mostly empty
    # Also check if there's no title in the expected column
    title_index = column_map[:title]
    has_title = title_index && row[title_index].to_s.strip.present?

    !has_tc_pattern && non_empty_count <= 2 && !has_title
  end

  def sanitize_scope_name(name)
    # Remove special characters but keep spaces and basic punctuation
    name.to_s.strip.gsub(/[\/\\]/, '-').gsub(/\s+/, ' ')
  end

  def import_test_case(row, column_map, scope_path, title, sheet_name, row_num)
    scope = find_or_create_scope(scope_path)
    return unless scope

    cypress_id = get_value(row, column_map, :cypress_id)

    # Normalize cypress_id - extract number if it's "TC X" format
    if cypress_id.present?
      cypress_id = cypress_id.to_s.strip.upcase
      # If it's just a number, prefix with TC
      cypress_id = "TC#{cypress_id}" if cypress_id.match?(/^\d+$/)
      # Normalize various TC formats (TC 1, TC-1, TC1) to TC1
      cypress_id = cypress_id.gsub(/^TC[\s\-]*(\d+).*$/i, 'TC\1')
    end

    preconditions = get_value(row, column_map, :preconditions)
    steps = get_value(row, column_map, :steps)
    expected_result = get_value(row, column_map, :expected_result)

    # Store original ID from Excel in import_ref for traceability
    original_id = get_value(row, column_map, :cypress_id)

    # Skip if both steps and expected result are empty
    if steps.blank? && expected_result.blank?
      @skipped_count += 1
      return
    end

    # Check for duplicates
    if duplicate_exists?(scope, title, cypress_id, original_id)
      @duplicate_count += 1
      return
    end

    test_case = scope.test_cases.new(
      title: truncate_title(title),
      preconditions: preconditions,
      steps: steps || "See expected result",
      expected_result: expected_result || "See steps",
      cypress_id: cypress_id.presence,
      source: :imported,
      import_ref: original_id.presence
    )

    if test_case.save
      @imported_count += 1
    else
      @errors << "Sheet '#{sheet_name}' Row #{row_num}: #{test_case.errors.full_messages.join(', ')}"
    end
  end

  def truncate_title(title)
    # Truncate very long titles but keep them meaningful
    return title if title.length <= 255
    title[0..251] + "..."
  end

  def duplicate_exists?(scope, title, cypress_id, import_ref = nil)
    # Check by cypress_id first (if present) - search across entire test suite
    if cypress_id.present?
      return true if @test_suite.test_cases.exists?(cypress_id: cypress_id)
    end

    # Check by import_ref for re-imports
    if import_ref.present?
      return true if @test_suite.test_cases.exists?(import_ref: import_ref)
    end

    # Check by title within the same scope
    scope.test_cases.exists?(title: truncate_title(title))
  end

  def find_or_create_scope(path)
    return @scope_cache[path] if @scope_cache.key?(path)

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
    @errors << "Failed to create scope '#{path}': #{e.message}"
    nil
  end
end
