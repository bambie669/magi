require 'csv'

class TestCasesCsvExporter
  HEADERS = %w[scope_path title preconditions steps expected_result cypress_id].freeze

  def initialize(test_suite)
    @test_suite = test_suite
  end

  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << HEADERS
      collect_test_cases_with_paths.each do |test_case, scope_path|
        csv << build_row(test_case, scope_path)
      end
    end
  end

  def self.headers_only
    CSV.generate do |csv|
      csv << HEADERS
    end
  end

  private

  def collect_test_cases_with_paths
    results = []
    @test_suite.root_test_scopes.order(:name).each do |root_scope|
      collect_from_scope(root_scope, root_scope.name, results)
    end
    results
  end

  def collect_from_scope(scope, path, results)
    scope.test_cases.order(:title).each do |test_case|
      results << [test_case, path]
    end

    scope.children.order(:name).each do |child_scope|
      child_path = "#{path}/#{child_scope.name}"
      collect_from_scope(child_scope, child_path, results)
    end
  end

  def build_row(test_case, scope_path)
    [
      scope_path,
      test_case.title,
      test_case.preconditions,
      escape_newlines(test_case.steps),
      escape_newlines(test_case.expected_result),
      test_case.cypress_id
    ]
  end

  def escape_newlines(text)
    return nil if text.blank?
    text.gsub("\r\n", "\\n").gsub("\n", "\\n")
  end
end
